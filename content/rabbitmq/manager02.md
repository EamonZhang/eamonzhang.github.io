---
title: "Rabbitmq 基础"
date: 2021-05-22T14:52:35+08:00
draft: false
toc: true 
categories: ['rabbitmq']
tags: []
---

## AMQP 协议

AMQP，即Advanced Message Queuing Protocol，高级消息队列协议。

AMQP的主要特征是面向消息、队列、路由（包括点对点和发布/订阅）、可靠性、安全。 

RabbitMQ是一个开源的AMQP实现，服务器端用Erlang语言编写，支持多种客户端。

## 组件

- Broker：标识消息队列服务器实体。

- Virtual Host：虚拟主机，标识一批交换机、消息队列和相关对象。RabbitMQ默认的vhost是"/"。 理解为数据库中的database 

- Exchange：交换机，用来接收生产者发送的消息并将这些消息路由给服务器中的队列。 高级消息队列。

- Queue：消息队列，用来保存消息直到发送给消费者。它是消息的容器，也是消息的终点。一个消息可投入一个或多个队列。消息一直在队列里面，等待消费者连接到这个队列将其取走。

- Binding：绑定，用于消息队列和交换机之间的关联。一个绑定就是基于绑定键(bing-Key)将交换机和消息队列连接起来的路由规则，所以可以将交换器理解成一个由绑定构成的路由表。

- Channel：信道，多路复用连接中的一条独立的双向数据流通道。复用一条TCP连接。理解jdbc连接中的statement

- Connection：网络连接，比如一个TCP连接。

- Publisher：消息的生产者，表示一个向交换器发布消息的客户端应用程序。

- Consumer：消息的消费者，表示一个从一个消息队列中取得消息的客户端应用程序。

- Message：消息，消息包括消息内容及一系列的可选属性组成，这些属性包括routing-key(路由键)、priority(优先级)、headers(消息头)等。

## 交换机模式

https://www.rabbitmq.com/getstarted.html
#### 无交换机模式

- simple
 端对端  

- worker 
  多个消费端

  默认多个worker平均消费

  设置消费端手动确认，且预取为1

#### 交换机路由模式

- fanout

  fanout类型的exchange会忽略路由键的设置，直接将Message广播到所有绑定的Queue中

- direct
 
  交换机通过消息上的路由键匹配具有相同值的绑定键来路由消息到对应的队列上。

- topic 

  与direct基本相同，唯一区别在于绑定键；topic的绑定键可以设置表达式，用来模糊匹配；表达式里的通配符可以是"*"或"#"

#### 其他模式

- rpc 

  远程方法调用，双向传递。生产端传入方法的参数。消费端返回方法的结果。

- confirms

  生产者与队列之间的消息确认

## Rabbitmq 可靠性保证

1. 生产者与队列之间 confirm 确认机制
2. rabbitmq 队列镜像复制
3. rabbitmq 与消费者之间的ack机制


## 消息 Pull/Push

队列与消费者之间的消息传输的两种方式：Pull / Push

```
// push 
channel.basicConsume

// pull
channel.basicGet
```
通常都是采用push 模式。消息队列主动向worker 推送消息，worker 设置预留位channel.basicQos(1)。提高效率。

pull 模式则需要消费端不断的轮询

## Rabbitmq 集群

#### 默认集群

 集群模式下多节点只复制元数据。包括Exchange 但不包括messages , Queue只会存在于它所创建的那个节点上。

#### 镜像队列

 由于默认集群存在丢失数据的风险。使用镜像队列将会在所有其他节点上创建同样的队列。

 可以通过设置策略来设置镜像队列。设置策略时有两个关键参数：ha-mode和ha-params

| ha-mode | ha-params | Result |  
| :------------:| :----: | :----: |
| all | |在集群中的每个节点都有镜像。当一个节点添加到集群中时，这个节点同样会有相应的镜像 |  
| exactly | count | 指定在集群中镜像的个数。如果集群中节点的个数小于count的值，那么所有的节点都会配置镜像。如果其中一个镜像挂掉，那么会在另一个节点生成新的镜像。 |  
| nodes | node names | 在指定的节点列表中配置镜像。如果这些指定的节点都处于不可用状态(宕机或者关闭服务等)，那么客户端程序会在自己所连接的那么节点上创建queue。 |  


##### 设置策略

a、ha.开头的队列在所有节点上设置为镜像队列
```
rabbitmqctl set_policy ha-all "^ha\." '{"ha-mode":"all"}'
```
b、two.开头的队列设置镜像数为2，数据自动同步(默认为手动)
```
rabbitmqctl set_policy ha-two "^two\." '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'
```
c、nodes.开头的队列镜像设置在节点rabbit@pxc1,rabbit@pxc2上
```
rabbitmqctl set_policy ha-nodes "^nodes\." '{"ha-mode":"nodes","ha-params":["rabbit@pxc1", "rabbit@pxc2"]}'
```

#### Quorum Queues(仲裁队列)

仲裁队列是镜像队列(又称为HA队列)的替代方案，该队列把数据安全作为首要目标，在3.8.0版本可以使用。声明仲裁队列和声明普通队列方法一样，只需要把x-queue-type设置为`quorum`即可。 

x-queue-type(quorum、classic)，默认为classic

仲裁队列有一个leader、多个成员；管理成员：
```
rabbitmq-queues add_member [-p <vhost>] <queue-name> <node> #增加成员
rabbitmq-queues delete_member [-p <vhost>] <queue-name> <node> #删除成员
```
如：
```
./rabbitmq-queues add_member quorum.1 rabbit@pxc2
./rabbitmq-queues delete_member quorum.1 rabbit@pxc2
```


https://www.cnblogs.com/wuyongyin/p/13891450.html


