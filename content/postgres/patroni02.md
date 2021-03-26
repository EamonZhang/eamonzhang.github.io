---
title: "Patroni 高可用管理进阶"
date: 2021-03-05T17:06:18+08:00
draft: false
---

##### 完成目标

- [主从同步策略](postgres/patroni02/#主从同步策略)
- [异地多机房策略](postgres/patroni02/#异地多机房策略)
- [failover 触发详情](.)
- [访问认证](postgres/patroni02/#访问认证)
- [watch-dog](postgres/patroni02/#watch-dog)
- 配置文件详情
- [fencing](postgres/patroni02/#fencing)
- [DCS 失效处理](postgres/patroni02/#dcs失效处理)
- [加入节点复制数据限流](postgres/patroni02/#加入节点复制数据限流)
- 主从切换流量,避免重新拉取
- 级联复制
- callback
- 日志&监控

##### 主从同步策略

数据库主从之间同步类型
```
Synchronous state of this standby server. Possible values are:
async: This standby server is asynchronous.
potential: This standby server is now asynchronous, but can potentially become synchronous if one of current synchronous ones fails.
sync: This standby server is synchronous.
quorum: This standby server is considered as a candidate for quorum standbys.
```

数据库级同步配置
```
synchronous_standby_names: '*'
synchronous_commit = on 
```
patroni同步管理

```
patronictl edit-config -s 'synchronous_mode=true'加入节点复制数据限流
patronictl edit-config -s 'synchronous_mode_strict:true'

参数说明:

synchronous_mode = true , 

为同步模式，只有一个从节点为sync。在failover时sync节点才有资格选为新主。
与原来的pg同步不同，原pg服务当所有的从节点不可用是写操作会被堵塞。
由patroni 管理的pg 设置为synchronous_mode = true ，当同步从库不可用时主库发生降级。不会影响业务写操作。

synchronous_mode_strict:true
如果不想发生主库降级，设置此参数。数据安全性会更高。建议一主多从。

```

```
patronictl edit-config -s 'synchronous_mode=true'
patronictl -c /etc/patroni.yml list
+ Cluster: postgres (6935302809216505755) +---------+----+-----------+------------------+
| Member      | Host       | Role         | State   | TL | Lag in MB | Tags             |
+-------------+------------+--------------+---------+----+-----------+------------------+
| postgresql0 | 10.10.1.11 | Replica      | running | 31 |         0 | nofailover: true |
|             |            |              |         |    |           | nosync: true     |
+-------------+------------+--------------+---------+----+-----------+------------------+
| postgresql2 | 10.10.1.12 | Sync Standby | running | 31 |         0 |                  |
+-------------+------------+--------------+---------+----+-----------+------------------+
| postgresql3 | 10.10.1.13 | Leader       | running | 31 |           |                  |
+-------------+------------+--------------+---------+----+-----------+------------------+
```

##### 异地多机房策略

A. 当异地节点为一个节点。

- 备用机房节点在failover时不能选做主
- 备用机房节点主从复制采用异步方式

实现方法： 在yml 中的tag配置如下
```
tags: 
  nofailover: true # failover 时不能选为主节点
  nosync: true # 异步
```

```
patronictl -c /etc/patroni.yml list
+ Cluster: postgres (6935302809216505755) -----+----+-----------+------------------+
| Member      | Host       | Role    | State   | TL | Lag in MB | Tags             |
+-------------+------------+---------+---------+----+-----------+------------------+
| postgresql0 | 10.10.1.11 | Replica | running | 20 |         0 | nofailover: true |
|             |            |         |         |    |           | nosync: true     |
+-------------+------------+---------+---------+----+-----------+------------------+
| postgresql2 | 10.10.1.12 | Replica | running | 20 |         0 |                  |
+-------------+------------+---------+---------+----+-----------+------------------+
| postgresql3 | 10.10.1.13 | Leader  | running | 20 |           |                  |
+-------------+------------+---------+---------+----+-----------+------------------+
```

B. 当异地节点为多个节点时

如果多个节点都从主节点机房同步

1 机房间带宽

2 机房间网络延迟

更合理的结构拓扑应该采用数据库级联复制模式

 Standby cluster

##### 访问认证

- [DSC 访问认证管理](middleware/etcd_auth/)

DSC 作为集群的配置管理中心，虽然不存储业务数据，但是安全性也是至关重要。

- API 访问认证

用于patroni可通过API 访问来进行管理，将端口暴露出来不加防护无疑是将管理权拱手相让。

##### watch-dog 

基本原理： 当patroni启动后会不停的向watch-dog发送心跳。当watch dog超过一定时间间隔没有收到心跳则认为patroni进程发生意外，watch dog重新系统。

基本配置： 

```
安装watchdog
yum install watchdog -y
systemctl start watchdog
```

patroni.service
```
ExecStartPre=-/usr/bin/sudo /sbin/modprobe softdog
ExecStartPre=-/usr/bin/sudo /bin/chown postgres /dev/watchdog
```

patroni.yml
```
watchdog:
  mode: automatic # Allowed values: off, automatic, required
  device: /dev/watchdog
  safety_margin: 5
```

##### fencing

避免双主问题

patroni 在主节点网络与dcs不通信发生故障时会降级为只读。但可能存在一个心跳周期的双主。

更严格的方式是采用pg的同步模式，当主节点发现无任何可用的从库时写操作被hang住。
```
patronictl edit-config -s 'synchronous_mode=true'
patronictl edit-config -s 'synchronous_mode_strict:true'
```

当集群是一主多从，比如一主4从。可能发生2节点之间互通， 另外3节点之间互通的情况。

pg 实现请自行结合 pg 'quorum' 参数进行考量。具体结合业务数据安全等级要求。 

patroni 
```
synchronous_node_count = 1 # default 1
```

##### dcs失效处理

首先当DCS失效后集群的反应：

集群变为只读模式，原来集群中的所有pg服务都变为只读。主节点pg也被降级为只读。

发生上述现在主要是patroni的failover机制。 

- 主动方式，dcs失效后对现有集群不造成影响。同时也失去了failover能力。 

思路 failover 关闭或延长生效
```
方法一 ： 关闭集群的failover
 patronictl -c /etc/patroni.yml pause
```
```
方法二 ： 
retry_timeout: timeout for DCS and PostgreSQL operation retries (in seconds). DCS or network issues shorter than this will not cause Patroni to demote the leader. Default value: 10
将这个参数的值设置大一些，比如一天。
```

- 被动方式，DSC已经失效并且短时间内不能修复。已对现有生产造成影响的紧急处理方式。

思路 pg 脱离patroi 的管理，采用自身流复制

```

具体方法 

```

##### 加入节点复制数据限流

pg 流复制新加入节点限流 

```
pg_basebackup -r
```


https://zhuanlan.zhihu.com/p/260958352
