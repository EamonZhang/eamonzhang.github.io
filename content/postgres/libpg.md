---
title: "客户端故障转移"
date: 2021-07-22T11:04:27+08:00
draft: false
toc: false
categories: ["postgres"]
tags: []
---

##  多主机连接
PostgreSQL libpq 是数据库的一个连接驱动，支持多主机配置，同时支持target_session_attrs 主机角色判断配置。

当配置了多个主机时，会按顺序尝试连接，之道获取到成功的连接为止。

利用libpq的这个特性，结合数据库自动HA的一些软件，可以实现在不引入VIP以及中间路由节点的情况下实现数据库应用系统层级的高可用。

## 连接成功判断

- 成功建立连接
- target_session_attrs配置

```
 read-write 含义。 连接到的节点为可读写。如果连接的是从节点，只具备可读性则不能连接成功。

 根据show transaction_read_only ; 判断节点的可读写性
```

## 具体示例

psql
```
psql 'postgres://192.168.6.15:65432,192.168.6.16:65432/postgres?target_session_attrs=read-write'

```

python

```
import psycopg2
conn = psycopg2.connect(database="postgres",host="192.168.6.15,192.168.6.16", user="postgres", password="sqlite123", port="5432", target_session_attrs="read-write")
cur = conn.cursor()
cur.execute("select pg_is_in_recovery(),now(),inet_server_addr()")
row = cur.fetchone()
```
