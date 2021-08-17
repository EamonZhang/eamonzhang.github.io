---
title: "pg_stat_statements 数据库统计信息"
date: 2018-11-29T11:08:27+08:00
draft: false
---
#### pg_stat_statements 扩展

##### 安装　

```
yum install postgresql10-contrib.x86_64

```
##### 修改配置参数

```
vi $PGDATA/postgresql.conf  

shared_preload_libraries='pg_stat_statements'  # 加载模块　需要重启 , 近期测试不需要添加也可以。自带扩展

track_io_timing = on  # 跟踪IO耗时 (可选)

track_activity_query_size = 2048 # 设置单条SQL的最长长度，超过被截断显示（可选)

pg_stat_statements.max = 10000  #在pg_stat_statements中最多保留多少条统计信息，通过LRU算法，覆盖老的记录。

pg_stat_statements.track = all  # all - (所有SQL包括函数内嵌套的SQL), top - 直接执行的SQL(函数内的sql不被跟踪), none - (不跟踪)

pg_stat_statements.track_utility = off  #是否跟踪非DML语句 (例如DDL，DCL)，on表示跟踪, off表示不跟踪 

pg_stat_statements.save = on #重启后是否保留统计信息  
 
```
##### 重启数据库

```
systemctl restart postgresql-10
```
##### 创建扩展

```
create extension pg_stat_statements;

\d pg_stat_statements
                    View "public.pg_stat_statements"
       Column        |       Type       | Collation | Nullable | Description 
---------------------+------------------+-----------+----------+---------
 userid              | oid              |           |          | 执行该语句的用户的 OID
 dbid                | oid              |           |          | 在其中执行该语句的数据库的 OID
 queryid             | bigint           |           |          | 内部哈希码，从语句的解析树计算得来 
 query               | text             |           |          | 语句的文本形式 
 calls               | bigint           |           |          | 被执行的次数 
 total_time          | double precision |           |          | 在该语句中花费的总时间，以毫秒计 
 min_time            | double precision |           |          | 在该语句中花费的最小时间，以毫秒计 
 max_time            | double precision |           |          | 在该语句中花费的最大时间，以毫秒计
 mean_time           | double precision |           |          | 在该语句中花费的平均时间，以毫秒计 
 stddev_time         | double precision |           |          | 在该语句中花费时间的总体标准偏差，以毫秒计 
 rows                | bigint           |           |          | 该语句检索或影响的行总数 
 shared_blks_hit     | bigint           |           |          | 该语句造成的共享块缓冲命中总数 
 shared_blks_read    | bigint           |           |          | 该语句读取的共享块的总数 
 shared_blks_dirtied | bigint           |           |          | 该语句弄脏的共享块的总数 
 shared_blks_written | bigint           |           |          | 
 local_blks_hit      | bigint           |           |          | 
 local_blks_read     | bigint           |           |          | 该语句读取的本地块的总数 
 local_blks_dirtied  | bigint           |           |          | 该语句弄脏的本地块的总数 
 local_blks_written  | bigint           |           |          | 该语句写入的本地块的总数 
 temp_blks_read      | bigint           |           |          | 
 temp_blks_written   | bigint           |           |          | 
 blk_read_time       | double precision |           |          | 该语句花在读取块上的总时间，以毫秒计（如果track_io_timing被启用，否则为零) 
 blk_write_time      | double precision |           |          | 该语句花在写入块上的总时间，以毫秒计（如果track_io_timing被启用，否则为零) 

```
在数据库中生成了一个名为 pg_stat_statements 的视图,对数据库的跟踪也是基于这个视图展开。


#### 分析TOP SQL

最耗IO SQL

单次调用最耗IO SQL TOP 5

```
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time)/calls desc limit 5;  
```

总最耗IO SQL TOP 5

```
select userid::regrole, dbid, query from pg_stat_statements order by (blk_read_time+blk_write_time) desc limit 5;  
```

最耗时 SQL

单次调用最耗时 SQL TOP 5

```
select userid::regrole, dbid, query from pg_stat_statements order by mean_time desc limit 5;  
```

总最耗时 SQL TOP 5

```
select userid::regrole, dbid, query from pg_stat_statements order by total_time desc limit 5;  
```

响应时间抖动最严重 SQL

```
select userid::regrole, dbid, query from pg_stat_statements order by stddev_time desc limit 5;  
```

最耗共享内存 SQL

```
select userid::regrole, dbid, query from pg_stat_statements order by (shared_blks_hit+shared_blks_dirtied) desc limit 5;  
```

最耗临时空间 SQL

```
select userid::regrole, dbid, query from pg_stat_statements order by temp_blks_written desc limit 5;  
```

最访问频繁 SQL 

```
select userid::regrole, dbid, query ,calls from pg_stat_statements order by calls desc limit 5;
```

#### 重置统计信息
pg_stat_statements是累积的统计，如果要查看某个时间段的统计，需要打快照

```
建快照表
create table stat_pg_stat_statements as select now() ,* from pg_stat_statements where 1=2;
插入数据
insert into stat_pg_stat_statements select now() ,* from pg_stat_statements;
```

用户也可以定期清理历史的统计信息，通过调用如下SQL

```
select pg_stat_statements_reset();  
```
#### 

https://github.com/cybertec-postgresql/pgwatch2

https://github.com/wrouesnel/postgres_exporter
