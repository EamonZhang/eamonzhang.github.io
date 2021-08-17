---
title: "PG高可用Patroni"
date: 2019-01-30T10:14:55+08:00
draft: false
toc: true
categories: ["postgres"]
tags: ["高可用"]
---

## 环境

- 操作系统 Centos 7
- patroni 版本 2.0.2
- postgres 版本 13

## 实现目标

- [高可用方案对比](/postgres/patroni/#高可用方案对比)
- [patroni 结构分析](/postgres/patroni/#patroni结构分析)
- [patroni 搭建新集群](/postgres/patroni/#patroni搭建新集群)
- patroni 接管现有集群
- [patroni 管理pg配置](/postgres/patroni/#patroni管理pg配置)
- [手动swithover](/postgres/patroni/#手动swithover)
- [自动failover](/postgres/patroni/#自动failover)
- [维护模式](/postgres/patroni/#维护模式)
- [弹性扩容，缩容](/postgres/patroni/#弹性扩容缩容)
- [对外提供统一服务](/postgres/patroni/#对外提供统一服务)
- [RestFULLAPI](/postgres/patroni/#restFULLAPI)
- [备份恢复](/postgres/patroni/#备份恢复)
- [监控](/postgres/patroni/#监控)
- [日志](/postgres/patroni/#日志)
- [升级](/postgres/patroni/#升级)



## 高可用方案对比

pg的高可用方案都是基于流复制来实现

- [PAF](https://github.com/clusterlabs/PAF/)  
pacemaker + corosyns  

- [repmgr](https://github.com/2ndQuadrant/repmgr)  
repmgr 手动流复制管理  
repmgrd 自动流复制管理 守护进程  
主+从  
主+从+见证节点

[更多介绍](https://scalegrid.io/blog/managing-high-availability-in-postgresql-part-1/)


## patroni架构分析
- DCS[etcd] 外部依赖 ，集群通信选主
- patroni 与pg在同一个节点， 守护进程


## patroni搭建新集群
1 [虚拟机环境](/kvm/vagrant.html)

```
10.10.1.10 node0 外部节点etcd
10.10.1.11 - 13 node1-node3 集群节点
```

2 node0 安装etcd

单节点etcd 安装
```
yum install etcd 
```
配置其他节点可访问
etc/etcd/etcd.conf
```
ETCD_LISTEN_CLIENT_URLS="http://10.10.1.10:2379"
```

[etcd 集群管理](./)

3 node1-node3 安装配置patroni

python3 环境
```
yum install gcc python3 python3-devel
```
依赖安装
```
pip3 install psycopg2-binary
pip3 install patroni[etcd]
```
服务安装
```
yum install ntp
systemctl start ntpd
systemctl enable ntpd
```
数据库安装

[参考](/postgres/install01/)

不需要初始化

4 基础配置

vi /etc/patroni.yml
```
scope: postgres          # 集群名称 
namespace: /db002/       # 名称空间，对应etcd 根目录
name: postgresql0        # 节点名称

restapi:
    listen: 10.10.1.11:8008             #对外restfull 接口
    connect_address: 10.10.1.11:8008

etcd:
    host: 10.10.1.10:2379             # etcd服务地址

bootstrap:                            # 心跳 
    dcs:
        ttl: 30
        loop_wait: 10
        retry_timeout: 10      # 访问etcd 超时多久后重试
        maximum_lag_on_failover: 1048576  #从库落后主库多少bytes后failover时不能被选为主
        postgresql:                 # 流复制
          use_pg_rewind: true
          use_slots: false          # 默认true  主从数据库wal保留策略
          parameters:                # 以下为设置数据库参数，多个节点配置统一 
#           synchronous_standby_names: "*" # 流复制 同步
#           synchronous_commit: "on"  # 同步等级
#           wal_level: hot_standby
#           hot_standby: "on"
#           wal_keep_segments: 8
#           max_wal_senders: 10
#           max_replication_slots: 10
#           wal_log_hints: "on"
#           archive_mode: "on"
#           archive_timeout: 1800s
#           archive_command: mkdir -p ../wal_archive && test ! -f ../wal_archive/%f && cp %p ../wal_archive/%f
#        recovery_conf:
#          restore_command: cp ../wal_archive/%f %p

    initdb:                           #初始化数据库
    - encoding: UTF8
    - data-checksums

    pg_hba:                           # 数据库访问验证配置
    - host replication replicator 0.0.0.0/0 md5
    - host all all 0.0.0.0/0 md5

    users:                            #初始化数据库时创建应用用户
        admin:
            password: admin
            options:
                - createrole
                - createdb

postgresql:                           #数据库设置
    listen: 0.0.0.0:5432
    connect_address: 10.10.1.11:5432
    data_dir: /var/lib/pgsql/13/data/
    pgpass: /tmp/pgpass
    authentication:
        replication:
            username: replicator
            password: rep-pass
        superuser:
            username: postgres
            password: secretpassword
    parameters:
        unix_socket_directories: '.'

tags:
    nofailover: false
    noloadbalance: false
    clonefrom: false
    nosync: false

```

5 启动服务

服务管理
cat /usr/lib/systemd/system/patroni.service 
```
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Type=simple

User=postgres
Group=postgres

# Note: avoid inserting whitespace in these Environment= lines, or you may
# break postgresql-setup.

# Location of database directory
Environment=PATH=$PATH:/usr/pgsql-13/bin

# Where to send early-startup messages from the server (before the logging
# options of postgresql.conf take effect)
# This is normally controlled by the global default set by systemd
# StandardOutput=syslog

# Disable OOM kill on the postmaster
OOMScoreAdjust=-1000
Environment=PG_OOM_ADJUST_FILE=/proc/self/oom_score_adj
Environment=PG_OOM_ADJUST_VALUE=0

ExecStart=/usr/local/bin/patroni /etc/patroni.yml
ExecReload=/bin/kill -HUP $MAINPID

KillMode=process
KillMode=mixed
KillSignal=SIGINT

# Do not set any timeout value, so that systemd will not kill postmaster
# during crash recovery.
TimeoutSec=0
[Install]
WantedBy=multi-user.target
```

验证
```
 sudo systemd-analyze verify patroni.service
```

启动
```
systemctl start patroni
```

查看启动日志
```
journalctl -u patroni.service -f -n 1000
```

查看patroni

```
#patronictl -c /etc/patroni.yml list
+ Cluster: postgres (6935229608238737808) ----+----+-----------+
| Member      | Host       | Role   | State   | TL | Lag in MB |
+-------------+------------+--------+---------+----+-----------+
| postgresql0 | 10.10.1.11 | Leader | running |  2 |           |
+-------------+------------+--------+---------+----+-----------+
```
6 其他节点重复以上操作, 在集群中加入新节点

注意事项 patroni.yml 中的配置不同的节点修改成相应的值

name: postgresql0
  
IP写成节点的IP

```
#patronictl -c /etc/patroni.yml list -e
+ Cluster: postgres (6935302809216505755) -----+----+-----------+-----------------+-------------------+------+
| Member      | Host       | Role    | State   | TL | Lag in MB | Pending restart | Scheduled restart | Tags |
+-------------+------------+---------+---------+----+-----------+-----------------+-------------------+------+
| postgresql0 | 10.10.1.11 | Leader  | running | 14 |           |                 |                   |      |
| postgresql2 | 10.10.1.12 | Replica | running | 14 |         0 |                 |                   |      |
| postgresql3 | 10.10.1.13 | Replica | running | 14 |         0 |                 |                   |      |
+-------------+------------+---------+---------+----+-----------+-----------------+-------------------+------+
```

## patroni管理pg配置

1 多节点统一配置

以下修改后集群中每个节点都生效，并且保持一致。
```
修改集群配置
# patronictl -c /etc/patroni.yml edit-config

```
```
查看集群配置 
#patronictl -c /etc/patroni.yml show-config

loop_wait: 10
maximum_lag_on_failover: 1048576
postgresql:
  parameters:
    max_connections: 1000
    synchronous_standby_names: '*'
  use_pg_rewind: true
  use_slots: false
retry_timeout: 10
ttl: 30
```

```
修改后待生效
#patronictl -c /etc/patroni.yml list 
+ Cluster: postgres (6935302809216505755) -----+----+-----------+-----------------+
| Member      | Host       | Role    | State   | TL | Lag in MB | Pending restart |
+-------------+------------+---------+---------+----+-----------+-----------------+
| postgresql0 | 10.10.1.11 | Leader  | running | 14 |           | *               |
| postgresql2 | 10.10.1.12 | Replica | running | 14 |         0 | *               |
| postgresql3 | 10.10.1.13 | Replica | running | 14 |         0 | *               |
+-------------+------------+---------+---------+----+-----------+-----------------+
```
```
重启集群生效, 可指定执行计划。定时自动执行
#patronictl -c /etc/patroni.yml restart postgres(集群名)
```

以上修改的文件为 postgres.conf

2 单节点数据库配置

有些参数只想在特定节点生效，配置方式与单节点数据库一致

vi postgres.base.conf

对应节点执行 restart 或 reload 生效

```
systemctl restart patroni 
systemctl reload patroni 
```

3 REFTFULL API 接口访问

## 手动swithover

计划内调整主节点，集群拓扑关系
```
将原主postgresql0切换为postgresql2
#patronictl -c /etc/patroni.yml switchover
Master [postgresql0]: 
Candidate ['postgresql2', 'postgresql3'] []: postgresql2
When should the switchover take place (e.g. 2021-03-04T08:50 )  [now]: 
Current cluster topology
+ Cluster: postgres (6935302809216505755) -----+----+-----------+
| Member      | Host       | Role    | State   | TL | Lag in MB |
+-------------+------------+---------+---------+----+-----------+
| postgresql0 | 10.10.1.11 | Leader  | running | 14 |           |
| postgresql2 | 10.10.1.12 | Replica | running | 14 |         0 |
| postgresql3 | 10.10.1.13 | Replica | running | 14 |         0 |
+-------------+------------+---------+---------+----+-----------+
Are you sure you want to switchover cluster postgres, demoting current master postgresql0? [y/N]: y
2021-03-04 07:50:08.99426 Successfully switched over to "postgresql2"
+ Cluster: postgres (6935302809216505755) -----+----+-----------+
| Member      | Host       | Role    | State   | TL | Lag in MB |
+-------------+------------+---------+---------+----+-----------+
| postgresql0 | 10.10.1.11 | Replica | stopped |    |   unknown |
| postgresql2 | 10.10.1.12 | Leader  | running | 14 |           |
| postgresql3 | 10.10.1.13 | Replica | running | 14 |         0 |
+-------------+------------+---------+---------+----+-----------+
```
## 自动failover

- 节点断网，通信失败，服务不停
- 节点断电，通信失败，停服
- 通信成功，服务停
- dcs 失效, 集群变为只读
- 失联节点重新加入集群

## 维护模式

维护模式： 集群对外提供服务。但集群关系不在接受patroni管理。此时的集群为原生的流复制。

主动维护模式： 集群正常的情况下开启维护模式, 集群不在拥有autofailover 能力。当DCS 失效集群不受影响.
```
# 进入维护模式
patronictl -c /etc/patroni.yml pause
Success: cluster management is paused

# 退出维护模式
patronictl -c /etc/patroni.yml resume
Success: cluster management is resumed

# 当前状态 是否为维护模式
1 可查看在DSC 中的config信息
2 API 接口信息
```
被动维护模式： 当DCS 失效时集群变为只读模式

处理方法 TODO 

## 弹性扩容缩容

- 扩容 :

将patroni.yml 拷贝到新节点 修改对应的内容后 启动自动加入集群

- 缩容 :

关闭 节点patroni 服务自动退出集群

## 对外提供统一服务

- 二层 VIP [vip-manager](https://github.com/cybertec-postgresql/vip-manager)
- 四层 haproxy
- 七层 DNS

服务发现参考下面的 restfullapi

## restFULLAPI

```
-- 读取配置文件
# curl -s http://10.10.1.11:8008/config | jq .
{
  "loop_wait": 10,
  "maximum_lag_on_failover": 1048576,
  "postgresql": {
    "parameters": {
      "max_connections": 1001,
      "synchronous_standby_names": "*"
    },
    "use_pg_rewind": true,
    "use_slots": false
  },
  "retry_timeout": 10,
  "ttl": 30
}
-- 读取集群信息
curl -s http://10.10.1.11:8008/cluster | jq .
{
  "members": [
    {
      "name": "postgresql0",
      "role": "leader",
      "state": "running",
      "api_url": "http://10.10.1.11:8008/patroni",
      "host": "10.10.1.11",
      "port": 5432,
      "timeline": 16
    },
    {
      "name": "postgresql2",
      "role": "replica",
      "state": "running",
      "api_url": "http://10.10.1.12:8008/patroni",
      "host": "10.10.1.12",
      "port": 5432,
      "timeline": 16,
      "lag": 0
    },
    {
      "name": "postgresql3",
      "role": "replica",
      "state": "running",
      "api_url": "http://10.10.1.13:8008/patroni",
      "host": "10.10.1.13",
      "port": 5432,
      "timeline": 16,
      "lag": 0
    }
  ]
}
-- 获取节点角色信息
curl -s http://10.10.1.12:8008/health | jq .role
"replica"

curl -s http://10.10.1.11:8008/health | jq .role
"master"

-- 根据response code status
主节点 200 , 从节点503 
curl -si http://10.10.1.13:8008/master
从节点 200 ,主节点503
curl -si http://10.10.1.13:8008/replica

```

## 备份恢复
- etcd 备份恢复

1. patroni 节点关闭后删除etcd数据 ，重新启动后数据再次生成

2. 正在运行的集群删除etcd数据 , 数据再次自动生成。

- pg 备份恢复

1. 全量备份
2. wal 备份

官方方案 wal-e

## 监控

- patroni_exporter 
- etcd_exporter
- postgres_exporter

## 日志

- FLK

## 升级


[参考]


https://www.cnblogs.com/zhangeamon/p/9772118.html

https://www.linode.com/docs/databases/postgresql/create-a-highly-available-postgresql-cluster-using-patroni-and-haproxy

[ansible 管理](https://github.com/vitabaks/postgresql_cluster)

[实践](https://mp.weixin.qq.com/s/edvWkTb-WF7YyVAFz5GCfw)
