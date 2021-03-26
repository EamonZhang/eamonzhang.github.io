---
title: "数据库日志"
date: 2018-12-04T15:45:33+08:00
draft: false
---

#### 介绍

PostgreSQL有3种日志，分别是pg_log（数据库运行日志）、pg_xlog（WAL 日志，即重做日志）、pg_clog（事务提交日志，记录的是事务的元数据）
postgres 10 版本将文件目录结构改为 log，pg_wal，pg_xact
log默认是关闭的，需要设置其参数。wal和xact都是强制打开的，无法关闭。
本文主要介绍　log 能

#### 配置

语法:    
修改　ALTER SYSTEM SET 参数=值;    
查看　show 参数;  
重新启动数据库生效;  

启用pg_log并配置日志参数
```
ALTER SYSTEM SET
 log_destination = 'csvlog';
ALTER SYSTEM SET
 logging_collector = on;
ALTER SYSTEM SET
 log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log';
ALTER SYSTEM SET
 log_rotation_age = '1d';
ALTER SYSTEM SET
 log_rotation_size = '100MB';
ALTER SYSTEM SET
 log_min_messages = 'info';
```

记录日志信息
```
ALTER SYSTEM SET
 log_checkpoints = on;
ALTER SYSTEM SET
 log_connections = on;
ALTER SYSTEM SET
 log_disconnections = on;
ALTER SYSTEM SET
 log_duration = on;
ALTER SYSTEM SET
 log_line_prefix = '%m';
```

##### 记录执行慢的SQL
记录超过该时长的所有SQL，对找出当前数据库的慢查询很有效。时间单位ms

全局级
```
ALTER SYSTEM SET
 log_min_duration_statement = 60;
```

数据库级
```
ALTER DATABASE test SET log_min_duration_statement TO 60;
```

测试
```
postgres=# select now(), pg_sleep(66);
```

##### 监控数据库中长时间的锁

数据库的锁通常可以在pg_locks这个系统表里找，但这只是当前的锁表/行信息，如果你想看一天内有多少个超过死锁时间的锁发生，可以在日志里设置并查看，log_lock_waits 默认是off，可以设置开启。这个可以区分SQL慢是资源紧张还是锁等待的问题。
```
ALTER SYSTEM SET
 log_lock_waits = on;
```

测试
```
postgres=# show log_lock_waits ;
 log_lock_waits 
----------------
 on
(1 row)

postgres=# show deadlock_timeout ;
 deadlock_timeout 
------------------
 1s
(1 row)

--模拟锁
postgres=# begin;
BEGIN
postgres=# SELECT * FROM t_ken_yon ;
 id 
----
 11
(1 row)

postgres=# delete from t_ken_yon ;
DELETE 1

--另一个session
postgres=# begin;
BEGIN
postgres=# delete from t_ken_yon;

```

##### 审计
postgres日志里分成了3类，通过参数pg_statement来控制，

- 默认的pg_statement参数值是none，即不记录  
- 可以设置ddl(记录create,drop和alter)  
- mod(记录ddl+insert,delete,update和truncate)和all(mod+select)

```
ALTER SYSTEM SET
 log_statement = 'ddl';
```
#### 将日志导入到数据库表中并进行查询分析

创建数据库表
```
CREATE TABLE postgres_log
(
  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  application_name text,
  PRIMARY KEY (session_id, session_line_num)
);
```

将日志文件导入数据库表中
```
COPY postgres_log FROM 'log/postgresql-2018-12-05_103141.csv' WITH csv;
```

查询分析

自由发挥

日志分析报表 [PGBADGER](http://pgbadger.darold.net/documentation.html)

拓展 pgaudit

[参考学习](https://mp.weixin.qq.com/s/PYHhOt6uHdUkZXyBs7Vndw)
