---
title: "rabbitmq 简单应用"
date: 2019-02-26T14:57:21+08:00
draft: false
---

#### 启动
```
rabbitmq-server &
```

#### 队列重置（清空队列、用户等）
```
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl stop
```
#### 关闭
```
rabbitmqctl stop
```
#### 列举所有用户
```
rabbitmqctl list_users
```
#### 列举所有队列
```
rabbitmqctl list_queues
```
#### 添加用户
```
rabbitmqctl add_user user_name user_passwd
```
#### 设置用户角色为管理员
```
rabbitmqctl set_user_tags user_name administrator
```
#### 权限设置
```
rabbitmqctl set_permissions -p / user_name ".*" ".*" ".*"
```
操作举例（添加用户admin）
```
sudo rabbitmqctl add_user admin admin
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```
#### 查看状态
```
rabbitmqctl status
```
#### 安装 RabbitMQWeb管理插件
```
rabbitmq-plugins enable rabbitmq_management 
可以利用http://ip:15672查看界面状态
```
#### Rabbitmq的mnesia数据地址
```
1. 停止消息队列
sudo rabbitmqctl stop 

2. 创建mnesia目录，修改用户属性
mkdir mnesia
sudo chown rabbitmq:rabbitmq /home/test/mnesia

3. 修改默认MNESIA_BASE地址
vim /usr/lib/rabbitmq/bin/rabbitmq-defaults
MNESIA_BASE=${SYS_PREFIX}/var/lib/rabbitmq/mnesia
改为 MNESIA_BASE=${SYS_PREFIX}/home/test/mnesia

4. 启动消息队列
sudo rabbitmq-server &

5. 建立admin用户
sudo rabbitmqctl add_user admin admin
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
```

应用举例
```
rabbitmqctl list_users
rabbitmqctl list_vhosts
rabbitmqctl add_user rabbit rabbit
rabbitmqctl set_user_tags rabbit administrator
rabbitmqctl add_vhost /test
rabbitmqctl set_permissions -p /test rabbit ".*" ".*" ".*"
```


https://www.cnblogs.com/knowledgesea/p/6535766.html
