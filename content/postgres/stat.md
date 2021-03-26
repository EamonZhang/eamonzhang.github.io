---
title: "Postgresql指标查看&stat统计信息"
date: 2018-11-06T10:53:52+08:00
draft: false
---

- 当前连接数

```
SELECT count(*) FROM pg_stat_activity WHERE NOT pid=pg_backend_pid();
 count 
-------
     3
(1 row)

```

- 数据库占用空间

```
select pg_size_pretty(pg_database_size('postgres'));
 pg_size_pretty 
----------------
 14 MB
(1 row)

or

\l+

```

- 数据库表(不包括索引)或单条索引占用空间

```
select pg_size_pretty(pg_relation_size('t_name'));
 pg_size_pretty 
----------------
 24 kB
(1 行记录)

or

\d+
```

- 表中所有索引占有的空间

```
select pg_size_pretty(pg_indexes_size('t_name'));
 pg_size_pretty 
----------------
 280 kB
(1 行记录)
```

- 表和索引占用总空间

```
select pg_size_pretty(pg_total_relation_size('t_name'));
 pg_size_pretty
----------------
 380 kB
(1 行记录)
```

- 查看一条数据在数据库占用的空间

```
select pg_column_size('Let us go !!!');
 pg_column_size 
----------------
             14
(1 行记录)

```

- 查出所有表（包含索引）并排序

```
SELECT table_schema || '.' || table_name AS table_full_name, pg_size_pretty(pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')) AS size
FROM information_schema.tables
ORDER BY
pg_total_relation_size('"' || table_schema || '"."' || table_name || '"') DESC limit 10;
```

- 查出表大小按大小排序并分离data与index

```
SELECT
table_name,
pg_size_pretty(table_size) AS table_size,
pg_size_pretty(indexes_size) AS indexes_size,
pg_size_pretty(total_size) AS total_size
FROM (
SELECT
table_name,
pg_table_size(table_name) AS table_size,
pg_indexes_size(table_name) AS indexes_size,
pg_total_relation_size(table_name) AS total_size
FROM (
SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
FROM information_schema.tables
) AS all_tables
ORDER BY total_size DESC
) AS pretty_sizes;
```

- 其他

```
pg_stat_database
pg_stat_all_tables
pg_stat_sys_tables
pg_stat_user_tables
pg_stat_all_indexes
pg_stat_sys_indexes
pg_stat_user_indexes
```
---

```
postgres=# select * from pg_stat_database where datname='postgres';
-[ RECORD 1 ]-----+------------------------------
datid             | 13510                 #数据库oid
datname           | postgres              #数据库名
numbackends       | 98                    #访问当前数据库连接数量
xact_commit       | 14291309              #该数据库事务提交总量
xact_rollback     | 0                     #该数据库事务回滚总量
blks_read         | 536888                #总磁盘物理读的块数，这里read也可能是从page cache读取，如果这里很高需要结合blk_read_time看是否真的存在很多实际从磁盘读取的情况。
blks_hit          | 261717850             #在shared_buffer命中的块数
tup_returned      | 58521416              #对于表来说是全表扫描的行数，对于索引是通过索引方法返回的索引行数，如果这个值数量明显大于tup_fetched，说明当前数据库存在大量全表扫描的情况。
tup_fetched       | 57193639              #指通过索引返回的行数
tup_inserted      | 14293061              #插入的行数
tup_updated       | 42868451              #更新的行数
tup_deleted       | 98                    #删除的行数
conflicts         | 0                     #与恢复冲突取消的查询次数(只会在备库上发生)
temp_files        | 0                     #产生临时文件的数量，如果这个值很高说明work_mem需要调大
temp_bytes        | 0                     #临时文件的大小
deadlocks         | 0                     #死锁的数量，如果这个值很大说明业务逻辑有问题
blk_read_time     | 0                     #数据库中花费在读取文件的时间，这个值较高说明内存较小，需要频繁的从磁盘中读入数据文件
blk_write_time    | 0                     #数据库中花费在写数据文件的时间，pg中脏页一般都写入page cache，如果这个值较高，说明page cache较小，操作系统的page cache需要更积极的写入。
stats_reset       | 2019-04-09 14:06:53.416473+08 #统计信息重置的时间
```

通过pg_stat_database我们就可以大概了解数据库的历史情况，比如看到tup_returned值远大于tup_fetched，说明数据库历史执行的sql很多都是全表扫描，说明存在很多没有走索引的sql，这时候可以结合pg_stat_statments来查找慢sql，也可以通过pg_stat_user_tables找到全表扫描次数和行数最多的表。通过看到tup_updated很高说明数据库有很频繁的更新，这个时候就需要关注一下vacuum相关的指标和长事务，如果没有及时进行垃圾回收会造成数据膨胀的比较厉害。如果temp_files较高的话说明存在很多的排序，hash，或者聚合这种操作，可以通过增大work_mem减少临时文件的产生，并且同时这些操作的性能也会有较大的提升。


https://yq.aliyun.com/articles/697692?spm=5176.10695662.1996646101.searchclickresult.28b6528caEAf7X
