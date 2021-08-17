---
title: "Logical Replication 逻辑复制"
date: 2019-01-30T15:42:25+08:00
draft: false
---

#### 逻辑复制

Postgres 10 版本开始， 在内核层面支持基于REDO流的逻辑复制。

控制粒度为表级别

物理复制相同都是基于wal 

可指定多个上游数据源

下游数据可读可写

可用于数据汇总，无停服数据迁移,大版本升级等。

#### 基本概念

###### 发布者（publication）， 上游数据

###### 订阅者 (subscrition)， 下游数据

###### 复制槽 (slot), 保存逻辑复制的信息

#### 简单实践

- 将10中的一张表同步到12中

发布者服务器配置

postgresql.conf
```
wal_level = logical
max_replication_slots = 10 # 每个slot 需要一个
max_wal_senders = 10 # 每个slot 需要一个
max_worker_processes = 128 
 
```
pg_hba.conf

```
host replication postgres 10.1.0.0/16 md5
```

订阅者服务器配置

postgresql.conf
```
max_replication_slots = 10 # 每个slot 需要一个
max_logical_replication_workers = 10 # 每个slot 需要一个
max_worker_processes = 128
```

在发布端创建发布

```
create publication test01 for table test01 ;
```

在订阅端创建表结构

```
pg_dump -U postgres -s -t test01 pglogicaltestdb
```

在订阅端创建订阅
```
create subscription sub1 connection 'host=10.1.7.55 port=25432 dbname=pglogicaltestdb password=123456' publication test01;
```

##### 常用视图查看

发布端视图
```
 select * from pg_stat_replication ;

 select * from pg_publication;

 select * from pg_publication_tables ;
```

订阅端视图

```
 select * from pg_stat_subscription;

 select * from pg_subscription
```

[更多](./book/PostgreSQL逻辑复制探究.pdf)
