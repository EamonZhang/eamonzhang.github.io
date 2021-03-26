---
title: "auto vacuum 触发机制"
date: 2021-01-08T09:20:56+08:00
draft: false
---

#### 数据库自动垃圾回收触发条件分析

 在postgres 中 垃圾回收的重要意义及在执行垃圾回收时具体都做了些什么很多地方都有介绍。
 
 但是何时触发垃圾回收，即垃圾回收的触发条件是什么。

 官网的介绍一般是有如下几个参数决定

```
#autovacuum = on                        # Enable autovacuum subprocess?  'on'
#autovacuum_vacuum_threshold = 50       # min number of row updates before vacuum
#autovacuum_analyze_threshold = 50      # min number of row updates before analyze
#autovacuum_vacuum_scale_factor = 0.2   # fraction of table size before vacuum
#autovacuum_analyze_scale_factor = 0.1  # fraction of table size before analyze
#autovacuum_freeze_max_age = 200000000 # maximum XID age before forced vacuum
```

大概意思 当表中的数据更新为总数量的20% 是触发垃圾回收，但是当表中总数量小于50的时候20%来的太容易了，

这样就会过于频繁的满足触发条件。于是50就相当于一个最低门槛。表中总数量在50以内的就暂时不触发垃圾回收了。

  * threshold = pg_class.reltuples*autovacuum_vacuum_scale_factor+autovacuum_vacuum_threshold

即：if (当前表更新数> 触发阀值) do ...

###### 等号右边的理解

```
-- 触发自动analyze
pg_class.reltuples*autovacuum_analyze_scale_factor+autovacuum_analyze_threshold
-- 触发自动autovacuum
pg_class.reltuples*autovacuum_vacuum_scale_factor+autovacuum_vacuum_threshold
```
两个公式相似。其中的值都除了pg_class.reltuples 以外都是来自于配置

pg_class.reltuples 来自系统统计表，在analyze 后更新。

所以通常配置触发参数时，尽量将analyze 触发条件要更敏感性。

[测试参考](https://blog.csdn.net/cmzhuang/article/details/84643618)

###### 思考的是等号左边的事情

数据库是如何知道当前更的数量, 按照已有的经验（经验不足）。

一般数据库中这种信息是存在的统计类信息中。但是统计信息通常是在analyze后更新的。根据上面的公式触发analyze的条件又是由当前表更新数有关。

于是乎就陷入了一种循环♻️   。

1 表更新数量 -> analyze

2 analyze  —> 统计信息 

3 统计信息 -> 表更新数量  

那是先有鸡还是先有蛋呢？

只有继续思考才能找到事情的真相。。。

首先表中更新的数据量统计应该是一个很轻量快速的方法。类似于计数器实现,并且独立于传统的统计信息。接下来在数据库开始寻找这种计数器。


##### 真相

‘计数器’ 是有stats collector 进程来维护。 当数据库进行dml操作时，stats collector 进行实时计数统计。该值存在于pg_stat_all_table 中


查看pg_stats_all_table 表定义
```
postgres=# \d+ pg_stat_all_tables 
                           视图 "pg_catalog.pg_stat_all_tables"
        栏位         |           类型           | 校对规则 | 可空的 | 预设 | 存储  | 描述 
---------------------+--------------------------+----------+--------+------+-------+------
 relid               | oid                      |          |        |      | plain | 
 schemaname          | name                     |          |        |      | plain | 
 relname             | name                     |          |        |      | plain | 
 seq_scan            | bigint                   |          |        |      | plain | 
 seq_tup_read        | bigint                   |          |        |      | plain | 
 idx_scan            | bigint                   |          |        |      | plain | 
 idx_tup_fetch       | bigint                   |          |        |      | plain | 
 n_tup_ins           | bigint                   |          |        |      | plain | 
 n_tup_upd           | bigint                   |          |        |      | plain | 
 n_tup_del           | bigint                   |          |        |      | plain | 
 n_tup_hot_upd       | bigint                   |          |        |      | plain | 
 n_live_tup          | bigint                   |          |        |      | plain | 
 n_dead_tup          | bigint                   |          |        |      | plain | 
 n_mod_since_analyze | bigint                   |          |        |      | plain | 
 last_vacuum         | timestamp with time zone |          |        |      | plain | 
 last_autovacuum     | timestamp with time zone |          |        |      | plain | 
 last_analyze        | timestamp with time zone |          |        |      | plain | 
 last_autoanalyze    | timestamp with time zone |          |        |      | plain | 
 vacuum_count        | bigint                   |          |        |      | plain | 
 autovacuum_count    | bigint                   |          |        |      | plain | 
 analyze_count       | bigint                   |          |        |      | plain | 
 autoanalyze_count   | bigint                   |          |        |      | plain | 
视图定义:
 SELECT c.oid AS relid,
    n.nspname AS schemaname,
    c.relname,
    pg_stat_get_numscans(c.oid) AS seq_scan,
    pg_stat_get_tuples_returned(c.oid) AS seq_tup_read,
    sum(pg_stat_get_numscans(i.indexrelid))::bigint AS idx_scan,
    sum(pg_stat_get_tuples_fetched(i.indexrelid))::bigint + pg_stat_get_tuples_fetched(c.oid) AS idx_tup_fetch,
    pg_stat_get_tuples_inserted(c.oid) AS n_tup_ins,
    pg_stat_get_tuples_updated(c.oid) AS n_tup_upd,
    pg_stat_get_tuples_deleted(c.oid) AS n_tup_del,
    pg_stat_get_tuples_hot_updated(c.oid) AS n_tup_hot_upd,
    pg_stat_get_live_tuples(c.oid) AS n_live_tup,
    pg_stat_get_dead_tuples(c.oid) AS n_dead_tup,
    pg_stat_get_mod_since_analyze(c.oid) AS n_mod_since_analyze,
    pg_stat_get_last_vacuum_time(c.oid) AS last_vacuum,
    pg_stat_get_last_autovacuum_time(c.oid) AS last_autovacuum,
    pg_stat_get_last_analyze_time(c.oid) AS last_analyze,
    pg_stat_get_last_autoanalyze_time(c.oid) AS last_autoanalyze,
    pg_stat_get_vacuum_count(c.oid) AS vacuum_count,
    pg_stat_get_autovacuum_count(c.oid) AS autovacuum_count,
    pg_stat_get_analyze_count(c.oid) AS analyze_count,
    pg_stat_get_autoanalyze_count(c.oid) AS autoanalyze_count
   FROM pg_class c
     LEFT JOIN pg_index i ON c.oid = i.indrelid
     LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind = ANY (ARRAY['r'::"char", 't'::"char", 'm'::"char"])
  GROUP BY c.oid, n.nspname, c.relname;
```

原来是表oid上各种维度的计数器，

查看pg_class 结构
```
postgres=# \d+ pg_class
                                 数据表 "pg_catalog.pg_class"
        栏位         |     类型     | 校对规则 |  可空的  | 预设 |   存储   | 统计目标 | 描述 
---------------------+--------------+----------+----------+------+----------+----------+------
 relname             | name         |          | not null |      | plain    |          | 
 relnamespace        | oid          |          | not null |      | plain    |          | 
 reltype             | oid          |          | not null |      | plain    |          | 
 reloftype           | oid          |          | not null |      | plain    |          | 
 relowner            | oid          |          | not null |      | plain    |          | 
 relam               | oid          |          | not null |      | plain    |          | 
 relfilenode         | oid          |          | not null |      | plain    |          | 
 reltablespace       | oid          |          | not null |      | plain    |          | 
 relpages            | integer      |          | not null |      | plain    |          | 
 reltuples           | real         |          | not null |      | plain    |          | 
 relallvisible       | integer      |          | not null |      | plain    |          | 
 reltoastrelid       | oid          |          | not null |      | plain    |          | 
 relhasindex         | boolean      |          | not null |      | plain    |          | 
 relisshared         | boolean      |          | not null |      | plain    |          | 
 relpersistence      | "char"       |          | not null |      | plain    |          | 
 relkind             | "char"       |          | not null |      | plain    |          | 
 relnatts            | smallint     |          | not null |      | plain    |          | 
 relchecks           | smallint     |          | not null |      | plain    |          | 
 relhasoids          | boolean      |          | not null |      | plain    |          | 
 relhaspkey          | boolean      |          | not null |      | plain    |          | 
 relhasrules         | boolean      |          | not null |      | plain    |          | 
 relhastriggers      | boolean      |          | not null |      | plain    |          | 
 relhassubclass      | boolean      |          | not null |      | plain    |          | 
 relrowsecurity      | boolean      |          | not null |      | plain    |          | 
 relforcerowsecurity | boolean      |          | not null |      | plain    |          | 
 relispopulated      | boolean      |          | not null |      | plain    |          | 
 relreplident        | "char"       |          | not null |      | plain    |          | 
 relispartition      | boolean      |          | not null |      | plain    |          | 
 relfrozenxid        | xid          |          | not null |      | plain    |          | 
 relminmxid          | xid          |          | not null |      | plain    |          | 
 relacl              | aclitem[]    |          |          |      | extended |          | 
 reloptions          | text[]       |          |          |      | extended |          | 
 relpartbound        | pg_node_tree |          |          |      | extended |          | 
索引：
    "pg_class_oid_index" UNIQUE, btree (oid)
    "pg_class_relname_nsp_index" UNIQUE, btree (relname, relnamespace)
    "pg_class_tblspc_relfilenode_index" btree (reltablespace, relfilenode)
有 OIDs:yes
```

pg_class 中的信息是analyze 操作后更新，而计数器是oid上不同维度的统计。

统计维度设置

```
#------------------------------------------------------------------------------
# STATISTICS
#------------------------------------------------------------------------------

# - Query and Index Statistics Collector -

#track_activities = on
#track_counts = on
#track_io_timing = off
#track_functions = none                 # none, pl, all
#track_activity_query_size = 1024       # (change requires restart)
#stats_temp_directory = 'pg_stat_tmp  统计信息存放位置
```
```
tree pg_stat_tmp/
pg_stat_tmp/
├── db_0.stat
├── db_14187.stat
├── db_16384.stat
├── db_20579.stat
└── global.stat
```

思考->迷惑->寻找答案->日渐清晰 ，日进一步

pg_statistic 里面的内容太丰富了...
