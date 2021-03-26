---
title: "Redis 6.0安装配置管理"
date: 2020-06-12T14:48:56+08:00
draft: false
---

#### 安装

yum 方式
```
yum install -y http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

yum --enablerepo=remi install redis

```

make 方式

```
升级gcc 版本临时生效,否则编译错误

yum -y install centos-release-scl

yum -y install devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils

scl enable devtoolset-9 bash
```

```
wget http://download.redis.io/releases/redis-6.0.1.tar.gz

tar -xvf redis-6.0.1.tar.gz

cd /usr/local/redis-6.0.1/

make PREFIX=/usr/local/redis install
```

#### 启动

```
systemctl start redis 

systemctl enalbe redis
```

#### 配置

##### 系统参数

vi /etc/sysctl.conf
```
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
kernel.shmmax = 68719476736
kernel.shmall = 4294967296
net.core.netdev_max_backlog = 262144
net.core.somaxconn = 40960
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
```

##### 服务参数

vi /etc/redis.conf
```
daemonize yes
pidfile /var/run/redis.pid
bind 0.0.0.0
timeout 300 #当客户端闲置多长时间后关闭连接，如果指定为0，表示永不关闭
tcp-keepalive 60 #设置检测客户端网络中断时间间隔，单位为秒
databases 16 #设置数据库数量，默认值为16
save 300 10  #300秒内有10个更改就将数据同步到数据文件
rdbcompssion yes #指定存储至本地数据库时是否压缩数据，默认为yes，redis采用LZF压缩，如果为了节省CPU时间，可以关闭该选项，但会导致数据库文件0  
dbfilename dump.rdb  #指定本地数据库文件名
dir /data/redis6/  #指定本地数据库存放目录
maxclients 1000 #设置同一时间最大客户端连接数，默认无限制
maxmemory <bytes> #指定redis最大内存限制  1/4 
```

##### 慢查询日志
```
slowlog-max-len 
slowlog-log-slower-than 
```

###### 密码认证

永久生效
```
requirepass foopassword # 设置redis连接密码默认关闭
masterauth <master-password> # 当master设置密码时，slave 需要设置
```
临时生效

```
config set requirepass foopassword 
```

[更多](https://blog.csdn.net/gfl1427097103/article/details/106256691)


https://www.cnblogs.com/richiewlq/p/12191278.html

##### 压测 

```
 redis-benchmark -h 127.0.0.1 -p 6379 -t set,lpush -n 10000 -q
```
