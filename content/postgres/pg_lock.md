---
title: "锁机制"
date: 2019-01-24T11:26:16+08:00
draft: false
---
https://blog.csdn.net/pg_hgdb/article/details/79403651

https://habr.com/en/company/postgrespro/blog/500714/

表锁 https://www.modb.pro/db/26462
```
查看被堵塞的任务
select * from pg_locks where not granted;
 locktype | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid | mode | granted | fastpath 
----------+----------+----------+------+-------+------------+---------------+---------+-------+----------+--------------------+-----+------+---------+----------
(0 行记录)

查看等待锁信息，是被谁堵塞了
select pg_blocking_pids(pid);
 pg_blocking_pids 
------------------
 {}

终止进程

select pg_cancel_backend(pid);  # select 

select pg_terminate_backend(pid); # update insert delete 
```


##### 事务的隔离级别

Postgres 数据库共有三种数据隔离级别。

- Read Commit 读看提交  默认级别 在读开始的时候建立数据快照
- Repeat Read 可重复读。在事务开始的时候建立数据快照
- SSI Serializable 序列化 理解为只有一个用户使用的情况

使用举例

```
postgres=# \h lock
Command:     LOCK
Description: lock a table
Syntax:
LOCK [ TABLE ] [ ONLY ] name [ * ] [, ...] [ IN lockmode MODE ] [ NOWAIT ]

where lockmode is one of:

    ACCESS SHARE | ROW SHARE | ROW EXCLUSIVE | SHARE UPDATE EXCLUSIVE
    | SHARE | SHARE ROW EXCLUSIVE | EXCLUSIVE | ACCESS EXCLUSIVE
```

锁定一张表

```
postgres=# begin ;
BEGIN
postgres=# lock TABLE wt IN access exclusive mode ;
LOCK TABLE

```


