---
title: "pgbench 压力测试"
date: 2019-01-09T16:36:47+08:00
draft: false
---

#### 介绍

pgbench是一种在PostgreSQL上运行基准测试的简单程序。  
[官方文档](http://www.postgres.cn/docs/9.6/pgbench.html) 

- 默认测试
- 自定义测试

#### 默认测试

pgbench中默认自带一套测试数据库和测试sql脚本。

###### 初始化默认数据库

```
使用 -i 初始化数据库

#pgbench -U postgres -i -s 10 pgbenchdb
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
creating tables...
100000 of 1000000 tuples (10%) done (elapsed 0.14 s, remaining 1.23 s)
200000 of 1000000 tuples (20%) done (elapsed 0.27 s, remaining 1.06 s)
300000 of 1000000 tuples (30%) done (elapsed 0.42 s, remaining 0.99 s)
400000 of 1000000 tuples (40%) done (elapsed 0.51 s, remaining 0.77 s)
500000 of 1000000 tuples (50%) done (elapsed 0.72 s, remaining 0.72 s)
600000 of 1000000 tuples (60%) done (elapsed 0.87 s, remaining 0.58 s)
700000 of 1000000 tuples (70%) done (elapsed 0.97 s, remaining 0.42 s)
800000 of 1000000 tuples (80%) done (elapsed 1.15 s, remaining 0.29 s)
900000 of 1000000 tuples (90%) done (elapsed 1.30 s, remaining 0.14 s)
1000000 of 1000000 tuples (100%) done (elapsed 1.46 s, remaining 0.00 s)
set primary keys...
done.

参数说明：
-i --initialize 表示初始化数据,注意原来的数据如果存在将被覆盖。
-s scale_factor 规模因子 数据量规模

查看初始化后的数据库

psql -U postgres -d pgbenchdb
pgbenchdb=# \d+
                               关联列表
 架构模式 |        名称        |  类型  |  拥有者  |    大小    | 描述 
----------+--------------------+--------+----------+------------+------
 public   | pg_stat_statements | 视图   | postgres | 0 bytes    | 
 public   | pgbench_accounts   | 数据表 | postgres | 128 MB     | 
 public   | pgbench_branches   | 数据表 | postgres | 8192 bytes | 
 public   | pgbench_history    | 数据表 | postgres | 0 bytes    | 
 public   | pgbench_tellers    | 数据表 | postgres | 8192 bytes | 
(5 行记录)

```

##### 开始测试

```
pgbench -M prepared -r -n -c 100 -j 100 -T 100 -U postgres   pgbenchdb 
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 10
query mode: prepared
number of clients: 100
number of threads: 100
duration: 100 s
number of transactions actually processed: 375474
latency average = 26.667 ms
tps = 3749.964314 (including connections establishing)
tps = 3754.003534 (excluding connections establishing)
script statistics:
 - statement latencies in milliseconds:
         0.002  \set aid random(1, 100000 * :scale)
         0.000  \set bid random(1, 1 * :scale)
         0.000  \set tid random(1, 10 * :scale)
         0.000  \set delta random(-5000, 5000)
         0.252  BEGIN;
         0.299  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
         0.199  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
        13.609  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
         9.879  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
         0.252  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
         2.100  END;

参数说明：
-M 模式 simple extended prepared
-r 每一个语句花费的事务时间
-n 运行前不执行vaccumun ,自定义的脚本运行中必须要使用
-c 客户端数量
-j 线程数量 客户端共用所有的线程 -j <= -c 
-T 运行的时间 单位秒 。 时间太短会导致结果不是很准确，至少要运行几分钟，消除噪声对结果的影响。
-t 运行的事务数 每个客户端
```

##### 结果解读

略 ，一看就懂

#### 自定义测试

示例说明
```
pgbench -M prepared -n -r -c 32 -j 32 -P 5 -C -f ./test.sql -U postgres pgbenchdb -T 300
```

注意事项: pgbench与pg不要在同一台机器上

各种场景压力测试
https://github.com/digoal/blog/blob/362b84417ca8b7aaf1add31fe7689c347642bb9a/201706/20170601_02.md

#### 遇见问题

测试 -C 参数时 使用的pgbouncer作为连接池出现如下错误
```
Cannot assign requested address
```
原因客户端频繁的连服务器，由于每次连接都在很短的时间内结束，导致很多的TIME_WAIT，以至于用光了可用的端口号，所以新的连接没办法绑定端口，即“Cannot assign requested address”。  
是客户端的问题不是服务器端的问题。通过netstat，的确看到很多TIME_WAIT状态的连接。 

client端频繁建立连接，而端口释放较慢，导致建立新连接时无可用端口。

解决方法：

执行命令修改如下2个内核参数 （需要root权限）  
sysctl -w net.ipv4.tcp_timestamps=1  开启对于TCP时间戳的支持,若该项设置为0，则下面一项设置不起作用   
sysctl -w net.ipv4.tcp_tw_recycle=1  表示开启TCP连接中TIME-WAIT sockets的快速回收   
