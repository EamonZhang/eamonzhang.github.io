---
title: "表空间膨胀"
date: 2019-05-22T17:26:45+08:00
draft: false
---

#### 背景介绍

由于mvcc机制，数据被删除后只是被标记为删除，实际空间没有被释放，这是表空间膨胀的根本原因。

目前用于解决表空间膨胀方式有如下方式

1 删除dead tuple 

- vacuum  ,tuple被清理。数据库可以自动执行autovacuum
- vacuum full ,tuple被清理并且空间连续紧凑。弊端，在执行过程中会锁表。应用不可用
- 为了避免锁表的影响，提供的[pg_squeeze](https://github.com/cybertec-postgresql/pg_squeeze)拓展,使用逻辑复制。[pg_repack拓展](https://www.timbotetsu.com/blog/postgresql-bloatbusters/)，使用了触发器，影响业务的性能。

2 fillfactor

3 vacuum_defer_cleanup_age > 0, 是以事务为单位。配合pg_resetwal 可以做到flashback
```
代价1，主库膨胀，因为垃圾版本要延迟若干个事务后才能被回收。
代价2，重复扫描垃圾版本，重复耗费垃圾回收进程的CPU资源。（n_dead_tup会一直处于超过垃圾回收阈值的状态，从而autovacuum 不断唤醒worker进行回收动作）。
当主库的 autovacuum_naptime=很小的值，同时autovacuum_vacuum_scale_factor=很小的值时，尤为明显。
代价3，如果期间发生大量垃圾，垃圾版本可能会在事务到达并解禁后，爆炸性的被回收，产生大量的WAL日志，从而造成WAL的写IO尖刺。
```
4 reindex 从新建立索引，不要忽略表膨胀中索引的影响，通常来说索引所占的空间和维护成本要高于数据表，在pg version 12版本中预计reindex时不需要锁表。

###### 处理完毕后需要重新生成统计信息

```
 ANALYZE;
```

在执行以上操作时建议设置

```
set maintenance_work_mem = '10GB';
```

#### 监控表空间膨胀

pgstattuple提供了pgstatetuple()和pgstatindex()两个统计表和索引的方法，较PostgreSQL系统表pg_class的表统计信息，pgstatetuple()还统计了表中的dead tuples。

https://www.postgresql.org/docs/current/pgstattuple.html

创建拓展
```
create extension pgstattuple ;
```

```
表
test=> SELECT * FROM pgstattuple('tablename');
-[ RECORD 1 ]------+-------
table_len          | 458752
tuple_count        | 1470
tuple_len          | 438896
tuple_percent      | 95.67
dead_tuple_count   | 11
dead_tuple_len     | 3157
dead_tuple_percent | 0.69
free_space         | 8932
free_percent       | 1.95

字段说明

table_len	bigint	Physical relation length in bytes 等价于 pg_relation_size()
tuple_count	bigint	Number of live tuples 
tuple_len	bigint	Total length of live tuples in bytes
tuple_percent	float8	Percentage of live tuples
dead_tuple_count	bigint	Number of dead tuples
dead_tuple_len	bigint	Total length of dead tuples in bytes
dead_tuple_percent	float8	Percentage of dead tuples
free_space	bigint	Total free space in bytes
free_percent	float8	Percentage of free space
三部分 live(存活tuple) dead(被标记删除tuple) free(剩余空间 应该是dead tuple ,vacuum 后被释放的, filltor 设置)

所用表
select tablename, (x).* from pg_tables ,LATERAL (select * from pgstattuple(tablename)) as X where schemaname = 'public' order by tuple_percent asc;

索引

test=> SELECT * FROM pgstatindex('index_name');
-[ RECORD 1 ]------+------
version            | 2
tree_level         | 0
index_size         | 16384
root_block_no      | 1
internal_pages     | 0
leaf_pages         | 1
empty_pages        | 0
deleted_pages      | 0
avg_leaf_density   | 54.27 (fillfator 默认90 ，该值接近90比较正常)
leaf_fragmentation | 0

字段说明
version	integer	B-tree version number
tree_level	integer	Tree level of the root page
index_size	bigint	Total index size in bytes
root_block_no	bigint	Location of root page (zero if none)
internal_pages	bigint	Number of “internal” (upper-level) pages
leaf_pages	bigint	Number of leaf pages
empty_pages	bigint	Number of empty pages
deleted_pages	bigint	Number of deleted pages
avg_leaf_density	float8	Average density of leaf pages
leaf_fragmentation	float8	Leaf page fragmentation

```
#### 简单使用

```
--- 生成测试数据

test=# create  table tb3(id integer,name character varying);
CREATE TABLE
test=# \d+ tb3 
                                  数据表 "public.tb3"
 栏位 |       类型        | Collation | Nullable | Default |   存储   | 统计目标 | 描述 
------+-------------------+-----------+----------+---------+----------+----------+------
 id   | integer           |           |          |         | plain    |          | 
 name | character varying |           |          |         | extended |          | 

test=#  alter table tb3 add primary key(id);
ALTER TABLE
test=# \d+ tb3 
                                  数据表 "public.tb3"
 栏位 |       类型        | Collation | Nullable | Default |   存储   | 统计目标 | 描述 
------+-------------------+-----------+----------+---------+----------+----------+------
 id   | integer           |           | not null |         | plain    |          | 
 name | character varying |           |          |         | extended |          | 
索引：
    "tb3_pkey" PRIMARY KEY, btree (id)

test=# insert into tb3 select generate_series(1,1000000),md5(random()::text);
INSERT 0 1000000

--- 创建拓展

test=# create extension pgstattuple ;
CREATE EXTENSION
test=# select * from pgstattuple('tb3');
-[ RECORD 1 ]------+---------
table_len          | 68272128
tuple_count        | 1000000
tuple_len          | 61000000
tuple_percent      | 89.35
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 38776
free_percent       | 0.06

test=# select * from pgstatindex('tb3_pkey');
-[ RECORD 1 ]------+---------
version            | 2
tree_level         | 2
index_size         | 22487040
root_block_no      | 412
internal_pages     | 11
leaf_pages         | 2733
empty_pages        | 0
deleted_pages      | 0
avg_leaf_density   | 90.06
leaf_fragmentation | 0

test=# delete from tb3 where id%5=0;
DELETE 200000
test=# select * from pgstatindex('tb3_pkey');
-[ RECORD 1 ]------+---------
version            | 2
tree_level         | 2
index_size         | 22487040
root_block_no      | 412
internal_pages     | 11
leaf_pages         | 2733
empty_pages        | 0
deleted_pages      | 0
avg_leaf_density   | 90.06
leaf_fragmentation | 0

test=# select * from pgstattuple('tb3');
-[ RECORD 1 ]------+---------
table_len          | 68272128
tuple_count        | 800000
tuple_len          | 48800000
tuple_percent      | 71.48
dead_tuple_count   | 200000
dead_tuple_len     | 12200000
dead_tuple_percent | 17.87
free_space         | 38776
free_percent       | 0.06

test=#  vacuum tb3;
VACUUM
test=# select * from pgstattuple('tb3');
-[ RECORD 1 ]------+---------
table_len          | 68272128
tuple_count        | 800000
tuple_len          | 48800000
tuple_percent      | 71.48
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 12838776
free_percent       | 18.81

test=# select * from pgstatindex('tb3_pkey');
-[ RECORD 1 ]------+---------
version            | 2
tree_level         | 2
index_size         | 22487040
root_block_no      | 412
internal_pages     | 11
leaf_pages         | 2733
empty_pages        | 0
deleted_pages      | 0
avg_leaf_density   | 72.11
leaf_fragmentation | 0

test=# select * from pgstattuple('tb3');
-[ RECORD 1 ]------+---------
table_len          | 68272128
tuple_count        | 800000
tuple_len          | 48800000
tuple_percent      | 71.48
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 12838776
free_percent       | 18.81

test=# vacuum full tb3;
VACUUM
test=# select * from pgstattuple('tb3');
-[ RECORD 1 ]------+---------
table_len          | 54616064
tuple_count        | 800000
tuple_len          | 48800000
tuple_percent      | 89.35
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 29388
free_percent       | 0.05


``` 


##### 查看每一页的空间利用

创建拓展

```
create extension pg_freespacemap;

```

查看没个页的空间利用 

```
select * from pg_freespace('tablename');
```

查看表的空间利用

```
select count(*) as "number of pages", pg_size_pretty(cast(avg(avail) as bigint)) as "freespace size ", round(100* avg(avail)/8192,2) as "freespace ratio" 
from pg_freespace('tablename');
```

[实战](https://mp.weixin.qq.com/s/g6j3WsBTGQipgEfrkzObRw)

##### 表空间数据膨胀的监控与处理

在实际的生产环境中，由于数据量非常大，传统方式统计表空间的膨胀率非常耗时耗资源。

结合统计情况，利用pg_repack可不停服处理。处理前查看是否有vacuum进程正在执行，避免冲突。

```
-- @auth Vonng

CREATE SCHEMA IF NOT EXISTS monitor;
CREATE EXTENSION IF NOT EXISTS pg_repack WITH SCHEMA monitor;

-- Table bloat estimate
CREATE OR REPLACE VIEW monitor.pg_table_bloat AS
    SELECT CURRENT_CATALOG AS datname, nspname, relname , bs * tblpages AS size,
           CASE WHEN tblpages - est_tblpages_ff > 0 THEN (tblpages - est_tblpages_ff)/tblpages::FLOAT ELSE 0 END AS ratio
    FROM (
             SELECT ceil( reltuples / ( (bs-page_hdr)*fillfactor/(tpl_size*100) ) ) + ceil( toasttuples / 4 ) AS est_tblpages_ff,
                    tblpages, fillfactor, bs, tblid, nspname, relname, is_na
             FROM (
                      SELECT
                          ( 4 + tpl_hdr_size + tpl_data_size + (2 * ma)
                              - CASE WHEN tpl_hdr_size % ma = 0 THEN ma ELSE tpl_hdr_size % ma END
                              - CASE WHEN ceil(tpl_data_size)::INT % ma = 0 THEN ma ELSE ceil(tpl_data_size)::INT % ma END
                              ) AS tpl_size, (heappages + toastpages) AS tblpages, heappages,
                          toastpages, reltuples, toasttuples, bs, page_hdr, tblid, nspname, relname, fillfactor, is_na
                      FROM (
                               SELECT
                                   tbl.oid AS tblid, ns.nspname , tbl.relname, tbl.reltuples,
                                   tbl.relpages AS heappages, coalesce(toast.relpages, 0) AS toastpages,
                                   coalesce(toast.reltuples, 0) AS toasttuples,
                                   coalesce(substring(array_to_string(tbl.reloptions, ' ') FROM 'fillfactor=([0-9]+)')::smallint, 100) AS fillfactor,
                                   current_setting('block_size')::numeric AS bs,
                                   CASE WHEN version()~'mingw32' OR version()~'64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END AS ma,
                                   24 AS page_hdr,
                                   23 + CASE WHEN MAX(coalesce(s.null_frac,0)) > 0 THEN ( 7 + count(s.attname) ) / 8 ELSE 0::int END
                                       + CASE WHEN bool_or(att.attname = 'oid' and att.attnum < 0) THEN 4 ELSE 0 END AS tpl_hdr_size,
                                   sum( (1-coalesce(s.null_frac, 0)) * coalesce(s.avg_width, 0) ) AS tpl_data_size,
                                   bool_or(att.atttypid = 'pg_catalog.name'::regtype)
                                       OR sum(CASE WHEN att.attnum > 0 THEN 1 ELSE 0 END) <> count(s.attname) AS is_na
                               FROM pg_attribute AS att
                                        JOIN pg_class AS tbl ON att.attrelid = tbl.oid
                                        JOIN pg_namespace AS ns ON ns.oid = tbl.relnamespace
                                        LEFT JOIN pg_stats AS s ON s.schemaname=ns.nspname AND s.tablename = tbl.relname AND s.inherited=false AND s.attname=att.attname
                                        LEFT JOIN pg_class AS toast ON tbl.reltoastrelid = toast.oid
                               WHERE NOT att.attisdropped AND tbl.relkind = 'r' AND nspname NOT IN ('pg_catalog','information_schema')
                               GROUP BY 1,2,3,4,5,6,7,8,9,10
                           ) AS s
                  ) AS s2
         ) AS s3
    WHERE NOT is_na;

-- Index bloat estimate
CREATE OR REPLACE VIEW monitor.pg_index_bloat AS
    SELECT CURRENT_CATALOG AS datname, nspname, idxname AS relname, relpages::BIGINT * bs AS size,
           COALESCE((relpages - ( reltuples * (6 + ma - (CASE WHEN index_tuple_hdr % ma = 0 THEN ma ELSE index_tuple_hdr % ma END)
                                                   + nulldatawidth + ma - (CASE WHEN nulldatawidth % ma = 0 THEN ma ELSE nulldatawidth % ma END))
                                      / (bs - pagehdr)::FLOAT  + 1 )), 0) / relpages::FLOAT AS ratio
    FROM (
             SELECT nspname,
                    idxname,
                    reltuples,
                    relpages,
                    current_setting('block_size')::INTEGER                                                               AS bs,
                    (CASE WHEN version() ~ 'mingw32' OR version() ~ '64-bit|x86_64|ppc64|ia64|amd64' THEN 8 ELSE 4 END)  AS ma,
                    24                                                                                                   AS pagehdr,
                    (CASE WHEN max(COALESCE(pg_stats.null_frac, 0)) = 0 THEN 2 ELSE 6 END)                               AS index_tuple_hdr,
                    sum((1.0 - COALESCE(pg_stats.null_frac, 0.0)) *
                        COALESCE(pg_stats.avg_width, 1024))::INTEGER                                                     AS nulldatawidth
             FROM pg_attribute
                      JOIN (
                 SELECT pg_namespace.nspname,
                        ic.relname                                                   AS idxname,
                        ic.reltuples,
                        ic.relpages,
                        pg_index.indrelid,
                        pg_index.indexrelid,
                        tc.relname                                                   AS tablename,
                        regexp_split_to_table(pg_index.indkey::TEXT, ' ') :: INTEGER AS attnum,
                        pg_index.indexrelid                                          AS index_oid
                 FROM pg_index
                          JOIN pg_class ic ON pg_index.indexrelid = ic.oid
                          JOIN pg_class tc ON pg_index.indrelid = tc.oid
                          JOIN pg_namespace ON pg_namespace.oid = ic.relnamespace
                          JOIN pg_am ON ic.relam = pg_am.oid
                 WHERE pg_am.amname = 'btree' AND ic.relpages > 0 AND nspname NOT IN ('pg_catalog', 'information_schema')
             ) ind_atts ON pg_attribute.attrelid = ind_atts.indexrelid AND pg_attribute.attnum = ind_atts.attnum
                      JOIN pg_stats ON pg_stats.schemaname = ind_atts.nspname
                 AND ((pg_stats.tablename = ind_atts.tablename AND pg_stats.attname = pg_get_indexdef(pg_attribute.attrelid, pg_attribute.attnum, TRUE))
                     OR (pg_stats.tablename = ind_atts.idxname AND pg_stats.attname = pg_attribute.attname))
             WHERE pg_attribute.attnum > 0
             GROUP BY 1, 2, 3, 4, 5, 6
         ) est
    LIMIT 512;

-- index bloat overview
CREATE OR REPLACE VIEW monitor.pg_table_bloat_human AS
    SELECT nspname || '.' || relname AS name,
           pg_size_pretty(size)      AS size,
           pg_size_pretty((size * ratio)::BIGINT) AS wasted,
           round(100 * ratio::NUMERIC, 2)  as ratio
    FROM monitor.pg_table_bloat ORDER BY wasted DESC NULLS LAST;
    
CREATE OR REPLACE VIEW monitor.pg_index_bloat_human AS
    SELECT nspname || '.' || relname              AS name,
           pg_size_pretty(size)                   AS size,
           pg_size_pretty((size * ratio)::BIGINT) AS wasted,
           round(100 * ratio::NUMERIC, 2)         as ratio
    FROM monitor.pg_index_bloat;
```

##### 主要原因分析及监控措施

###### 长事务

```
-- 跨事务
SELECT pid, datname, usename, state, backend_xmin
FROM pg_stat_activity
WHERE backend_xmin IS NOT NULL
ORDER BY age(backend_xmin) DESC;
```
```
-- 跨时间
select * from pg_stat_activity 
where state<>'idle' and pg_backend_pid()!=pid and (backend_xid is not null or backend_xmin is not null) and 
extract(epoch from(now()-xact_start))>6 
order by xact_start;
```

###### 废弃的复制槽
```
SELECT slot_name, slot_type, database, xmin
FROM pg_replication_slots
ORDER BY age(xmin) DESC;
```

###### 两阶段提交
```
SELECT gid, prepared, owner, database, transaction AS xmin
FROM pg_prepared_xacts
ORDER BY age(transaction) DESC;
```
