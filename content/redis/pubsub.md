---
title: "发布订阅"
date: 2021-08-12T10:44:01+08:00
draft: false
toc: false
categories: ['redis','python']
tags: []
---

## 发布订阅

 消息多播，一个发布消息可以同时被多个订阅者收听

## 常用命令

 发布
```
PUBLISH channel message
```

订阅
```
SUBSCRIBE channel [channel ...]

PSUBSCRIBE pattern [pattern ...]
```

## python demo
```
#!/usr/bin/env python

import redis
import time

redis_pool = redis.ConnectionPool(host="192.168.6.14",port="6379")
redis_client = redis.Redis(connection_pool=redis_pool)

#生产者
def publishMessages():
    while True:
        redis_client.publish("channel.shenyang","hello news "+time.asctime(time.localtime(time.time())))
        time.sleep(2)

#消费者
def subscibeMessages():
    p = redis_client.pubsub()
    p.subscribe("channel.shenyang")
    while True:
        message = p.get_message()
        if not message:
            time.sleep(1)
            continue
        print(message)
#阻塞消费者
def subscibeBlockMessages():
    p = redis_client.pubsub()
    p.subscribe("channel.shenyang")
    for item in p.listen():
        print(item['type'])
        if item['type'] == 'message':
            print(item['channel'])
            print(item['data'])

if __name__ == '__main__':

    publishMessages()
    # subscibeMessages()
    # subscibeBlockMessages()
```

## Stream 一个可靠的消息队列

Redis 5.0 引入了新的数据类型，Stream。 来打造可靠的redis消息队列 。

Stream 的消息模型借鉴了Kafka的消费分组的概念，弥补了PubSub不能持久化的缺陷。

#### 常用命令
```
向Stream 追加消息 * 自动分配ID
XADD key [NOMKSTREAM] [MAXLEN|MINID [=|~] threshold [LIMIT count]] *|ID field value [field value ...] 

向Stream 设置标记删除
XDEL key ID [ID ...]

获取Stream中的消息列表 - 最小ID + 最大ID
XRANGE key start end [COUNT count]

获取Stream长度，包括删除标记
XLEN key

删除整个Stream
DEL key [key ...]
```


#### 单独消费
```
从Stream 中读取消息 count 读取消息个数， block 堵塞，$ 跳过之前所有的只读取最新的。
XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] ID [ID ...]

```

#### 消费组
```
创建消费组
XGROUP [CREATE key groupname ID|$ [MKSTREAM]] [SETID key groupname ID|$] [DESTROY key groupname] [CREATECONSUMER key groupname consumername] [DELCONSUMER key groupname consumername]

XGROUP CREATE key1 group1 0-0

获取 Stream 信息
XINFO [CONSUMERS key groupname] [GROUPS key] [STREAM key] [HELP]

消费 Stream 信息
XREAD [COUNT count] [BLOCK milliseconds] STREAMS key [key ...] ID [ID ...]

ACK Stream 信息 
XACK key group ID [ID ...]

```

#### 消息过多

如果消息积压过多，Stream 链表过长，XDEL指令只标记删除。会不会爆掉。

Redis提供一个定长Stream功能

`XADD key maxlen 300 `

消息积压超过定长maxlen，老旧消极被砍掉。
