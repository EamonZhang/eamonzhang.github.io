---
title: "引起索引失效"
date: 2018-12-20T16:34:22+08:00
draft: false
---
##### 简介

索引的作用，加速检索，排序，分组。

优点： 检索

缺点： 新增，更新时需要维护索引，占磁盘空间，创建时锁表。

维护： 根据统计表发生全表扫描次数，索引使用次数。合理添加删除索引。

##### 索引失效的场景

如果where过滤条件设置不合理，即使索引存在，且where过滤条件中包含索引列，也会导致全表扫描，索引不起作用。什么条件下会导致索引失效呢？

1.任何计算、函数、类型转换

2.!=

3.NOT，相当于使用函数

4.模糊查询通配符在开头

5.索引字段在表中占比较高

6.多字段btree索引查询条件不包含第一列

7.多字段索引查询条件使用OR（有时也会走索引扫描，但查询效率不高）

8.表中数据量太少时

##### 实例

测试表
```
创建表
postgres#=create table tbl_index(a bigint,b timestamp without time zone ,c varchar(12));

插入1kw数据，打开计时器 对比创建索引对数据插入的影响。

postgres=# \timing 
Timing is on.

postgres=# insert into tbl_index select generate_series(1,10000000),clock_timestamp()::timestamp without time zone,'zhang';
INSERT 0 10000000
Time: 25004.214 ms (00:25.004)

postgres=# create index tbl_index_a ON tbl_index using btree (a);
CREATE INDEX
Time: 4119.733 ms (00:04.120)

postgres=# create index tbl_index_b ON tbl_index using btree (b);
CREATE INDEX
Time: 6229.857 ms (00:06.230)

postgres=# insert into tbl_index select generate_series(1,10000000),clock_timestamp()::timestamp without time zone,'eamon';
INSERT 0 10000000
Time: 153963.850 ms (02:33.964)
```
tips 

大量数据导入时建议先导入数据后创建索引

更新频繁的字段不建议建索引，如update_time

##### 1.任何计算、函数、类型转换
```
#索引检索
postgres=# explain analyze select * from tbl_index where a = 100;
                                                       QUERY PLAN                                                        
-------------------------------------------------------------------------------------------------------------------------
 Index Scan using tbl_index_a on tbl_index  (cost=0.44..19.78 rows=4 width=22) (actual time=0.012..0.015 rows=2 loops=1)
   Index Cond: (a = 100)
 Planning time: 0.053 ms
 Execution time: 0.027 ms
(4 rows)

#计算
postgres=# explain analyze select * from tbl_index where a +1 = 100;
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..263387.92 rows=99999 width=22) (actual time=0.495..478.375 rows=2 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_index  (cost=0.00..252388.02 rows=41666 width=22) (actual time=220.138..465.801 rows=1 loops=3)
         Filter: ((a + 1) = 100)
         Rows Removed by Filter: 6666666
 Planning time: 0.107 ms
 Execution time: 478.411 ms
(8 rows)
#解决方法
create index tbl_index_a_1 on tbl_index using btree ((a+1));

#类型转换
postgres=# explain analyze select * from tbl_index where a::varchar  = '100';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..284221.09 rows=99999 width=22) (actual time=0.529..724.035 rows=2 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_index  (cost=0.00..273221.19 rows=41666 width=22) (actual time=355.491..713.103 rows=1 loops=3)
         Filter: (((a)::character varying)::text = '100'::text)
         Rows Removed by Filter: 6666666
 Planning time: 0.168 ms
 Execution time: 724.075 ms
(8 rows)

postgres=# explain analyze select * from tbl_index where b::date = '2020-04-15';
                                                             QUERY PLAN                                                             
------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..263387.92 rows=99999 width=22) (actual time=0.505..4764.531 rows=20000000 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_index  (cost=0.00..252388.02 rows=41666 width=22) (actual time=0.021..789.147 rows=6666667 loops=3)
         Filter: ((b)::date = '2020-04-15'::date)
 Planning time: 0.146 ms
 Execution time: 5182.919 ms
(7 rows)

Time: 5184.795 ms (00:05.185)

#解决方法 

create index tbl_index_a2str on tbl_index using btree ((a::varchar));
create index tbl_index_b2date on tbl_index using btree ((b::date));

select * from tbl_index where b < '2020-04-16 00:00:00' and b >= '2020-04-15 00:00:00';

```
##### 2.!=
```
postgres=# explain analyze select * from tbl_index where a != 100;
                                                        QUERY PLAN                                                        
--------------------------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index  (cost=0.00..377387.04 rows=19999839 width=22) (actual time=0.020..1384.726 rows=19999998 loops=1)
   Filter: (a <> 100)
   Rows Removed by Filter: 2
 Planning time: 0.132 ms
 Execution time: 1790.685 ms
(5 rows)

Time: 1792.412 ms (00:01.792)
```
##### 3. NOT

```
postgres=# explain analyze select * from tbl_index where a is null;
                                                       QUERY PLAN                                                       
------------------------------------------------------------------------------------------------------------------------
 Index Scan using tbl_index_a on tbl_index  (cost=0.44..8.21 rows=1 width=22) (actual time=0.022..0.022 rows=0 loops=1)
   Index Cond: (a IS NULL)
 Planning time: 0.123 ms
 Execution time: 0.055 ms
(4 rows)

Time: 1.694 ms
postgres=# explain analyze select * from tbl_index where a is not null;
                                                        QUERY PLAN                                                        
--------------------------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index  (cost=0.00..327389.00 rows=20000000 width=22) (actual time=0.025..1375.125 rows=20000000 loops=1)
   Filter: (a IS NOT NULL)
 Planning time: 0.121 ms
 Execution time: 1789.101 ms
(4 rows)

Time: 1790.625 ms (00:01.791)
```
###### 4.模糊查询通配符在开头

[参见](../postgres/pg_trgm/)

##### 5.索引字段在表中占比较高
```
postgres=# create index tbl_index_c on tbl_index using btree (c);
CREATE INDEX
Time: 10552.062 ms (00:10.552)

postgres=# analyze tbl_index ;
ANALYZE
Time: 118.018 ms
postgres=# explain analyze select * from tbl_index where c = 'zhang';
                                                        QUERY PLAN                                                        
--------------------------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index  (cost=0.00..377389.90 rows=10034703 width=22) (actual time=0.021..1409.096 rows=10000000 loops=1)
   Filter: ((c)::text = 'zhang'::text)
   Rows Removed by Filter: 10000000
 Planning time: 0.562 ms
 Execution time: 1612.769 ms
(5 rows)

Time: 1615.034 ms (00:01.615)

postgres=# explain analyze select * from tbl_index where c = 'eamon';
                                                        QUERY PLAN                                                         
---------------------------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index  (cost=0.00..377389.90 rows=9965369 width=22) (actual time=616.952..1404.717 rows=10000000 loops=1)
   Filter: ((c)::text = 'eamon'::text)
   Rows Removed by Filter: 10000000
 Planning time: 0.066 ms
 Execution time: 1607.572 ms
(5 rows)

Time: 1609.019 ms (00:01.609)

postgres=# insert into tbl_index values(1,clock_timestamp()::timestamp without time zone,'zhangeamon');
INSERT 0 1
Time: 2.598 ms

postgres=# explain analyze select * from tbl_index where c = 'zhangeamon';
                                                       QUERY PLAN                                                        
-------------------------------------------------------------------------------------------------------------------------
 Index Scan using tbl_index_c on tbl_index  (cost=0.44..7.46 rows=1 width=22) (actual time=0.086..96.848 rows=1 loops=1)
   Index Cond: ((c)::text = 'zhangeamon'::text)
 Planning time: 0.157 ms
 Execution time: 96.881 ms
(4 rows)

Time: 98.464 ms
```

##### 6.多字段btree索引查询条件不包含第一列

```
#创建表
postgres=# create table tbl_indexes(a int ,b varchar,c varchar);
CREATE TABLE
Time: 6.942 ms

#插入数据
postgres=# insert into tbl_indexes select generate_series(1,5000000),substring(md5(random()::text),0,6),substring(md5(random()::text),0,6);
INSERT 0 5000000
Time: 15003.647 ms (00:15.004)

#创建多值索引
postgres=# create index tbl_indexes_a_b_c on tbl_indexes using btree (a,b,c);
CREATE INDEX
Time: 2207.480 ms (00:02.207)

postgres=# select * from tbl_indexes limit 10;
 a  |   b   |   c   
----+-------+-------
  1 | 0e7fb | d6370
  2 | e2eb1 | 51d3e
  3 | 93521 | 5f6b6
  4 | 5880d | 23527
  5 | 66f8e | f462f
  6 | 6ceb3 | c9beb
  7 | 18d44 | 11d64
  8 | f76a4 | edd04
  9 | 91975 | 4c79d
 10 | 56f26 | 09e16
(10 rows)


#走索引
postgres=# explain analyze select * from tbl_indexes where a = 10;
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on tbl_indexes  (cost=582.18..28488.04 rows=25000 width=68) (actual time=0.030..0.031 rows=1 loops=1)
   Recheck Cond: (a = 10)
   Heap Blocks: exact=1
   ->  Bitmap Index Scan on tbl_indexes_a_b_c  (cost=0.00..575.93 rows=25000 width=0) (actual time=0.022..0.022 rows=1 loops=1)
         Index Cond: (a = 10)
 Planning time: 0.127 ms
 Execution time: 0.075 ms
(7 rows)

Time: 2.878 ms
postgres=# explain analyze select * from tbl_indexes where a = 10 and b = '91975';
                                                         QUERY PLAN                                                         
----------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on tbl_indexes  (cost=5.71..482.09 rows=125 width=68) (actual time=0.025..0.025 rows=0 loops=1)
   Recheck Cond: ((a = 10) AND ((b)::text = '91975'::text))
   ->  Bitmap Index Scan on tbl_indexes_a_b_c  (cost=0.00..5.68 rows=125 width=0) (actual time=0.022..0.022 rows=0 loops=1)
         Index Cond: ((a = 10) AND ((b)::text = '91975'::text))
 Planning time: 0.146 ms
 Execution time: 0.074 ms
(6 rows)

Time: 2.886 ms
postgres=# explain analyze select * from tbl_indexes where a = 10 and b = '91975' and c = '4c79d';
                                                             QUERY PLAN                                                              
-------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using tbl_indexes_a_b_c on tbl_indexes  (cost=0.43..8.45 rows=1 width=68) (actual time=0.025..0.025 rows=0 loops=1)
   Index Cond: ((a = 10) AND (b = '91975'::text) AND (c = '4c79d'::text))
   Heap Fetches: 0
 Planning time: 0.158 ms
 Execution time: 0.067 ms
(5 rows)

Time: 3.136 ms
postgres=# explain analyze select * from tbl_indexes where a = 10  and c = '4c79d';
                                                          QUERY PLAN                                                          
------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on tbl_indexes  (cost=638.46..1114.84 rows=125 width=68) (actual time=0.027..0.027 rows=0 loops=1)
   Recheck Cond: ((a = 10) AND ((c)::text = '4c79d'::text))
   ->  Bitmap Index Scan on tbl_indexes_a_b_c  (cost=0.00..638.43 rows=125 width=0) (actual time=0.023..0.024 rows=0 loops=1)
         Index Cond: ((a = 10) AND ((c)::text = '4c79d'::text))
 Planning time: 0.178 ms
 Execution time: 0.077 ms
(6 rows)

Time: 2.917 ms

#不走索引
postgres=# explain analyze select * from tbl_indexes where b = '91975' and c = '4c79d';
                                                         QUERY PLAN                                                          
-----------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..59290.50 rows=125 width=68) (actual time=0.577..127.956 rows=1 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_indexes  (cost=0.00..58278.00 rows=52 width=68) (actual time=78.366..119.555 rows=0 loops=3)
         Filter: (((b)::text = '91975'::text) AND ((c)::text = '4c79d'::text))
         Rows Removed by Filter: 1666666
 Planning time: 0.154 ms
 Execution time: 127.993 ms
(8 rows)

Time: 130.603 ms

```
##### 7.多字段索引查询条件使用OR（有时也会走索引扫描，但查询效率不高）

```
postgres=# explain analyze select * from tbl_indexes where a = 10  or c = '4c79d';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..64265.50 rows=49875 width=68) (actual time=0.520..138.035 rows=5 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_indexes  (cost=0.00..58278.00 rows=20781 width=68) (actual time=52.632..129.858 rows=2 loops=3)
         Filter: ((a = 10) OR ((c)::text = '4c79d'::text))
         Rows Removed by Filter: 1666665
 Planning time: 0.151 ms
 Execution time: 138.075 ms
(8 rows)

Time: 139.952 ms
postgres=# explain analyze select * from tbl_indexes where a = 10  or b = '4c79d';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..64265.50 rows=49875 width=68) (actual time=0.513..131.024 rows=8 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on tbl_indexes  (cost=0.00..58278.00 rows=20781 width=68) (actual time=51.260..123.413 rows=3 loops=3)
         Filter: ((a = 10) OR ((b)::text = '4c79d'::text))
         Rows Removed by Filter: 1666664
 Planning time: 0.152 ms
 Execution time: 131.064 ms
(8 rows)

Time: 132.946 ms
postgres=# explain analyze select * from tbl_indexes where a = 10  or a = 11;
                                                              QUERY PLAN                                                              
--------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on tbl_indexes  (cost=1176.80..29434.85 rows=49875 width=68) (actual time=0.034..0.036 rows=2 loops=1)
   Recheck Cond: ((a = 10) OR (a = 11))
   Heap Blocks: exact=1
   ->  BitmapOr  (cost=1176.80..1176.80 rows=50000 width=0) (actual time=0.026..0.027 rows=0 loops=1)
         ->  Bitmap Index Scan on tbl_indexes_a_b_c  (cost=0.00..575.93 rows=25000 width=0) (actual time=0.020..0.020 rows=1 loops=1)
               Index Cond: (a = 10)
         ->  Bitmap Index Scan on tbl_indexes_a_b_c  (cost=0.00..575.93 rows=25000 width=0) (actual time=0.005..0.005 rows=1 loops=1)
               Index Cond: (a = 11)
 Planning time: 0.152 ms
 Execution time: 0.090 ms
(10 rows)

Time: 2.928 ms

如果检索条件为同一个字段 如a = 1 or a =2  转换为 a in (1,2) 会更优。
```

如果多个字段为同一类型可使用数组化索引

```
indexdb=# CREATE TABLE tbloom AS
indexdb-#    SELECT
indexdb-#      (random() * 1000000)::int as i1,
indexdb-#      (random() * 1000000)::int as i2,
indexdb-#      (random() * 1000000)::int as i3,
indexdb-#      (random() * 1000000)::int as i4,
indexdb-#      (random() * 1000000)::int as i5,
indexdb-#      (random() * 1000000)::int as i6
indexdb-#    FROM
indexdb-#   generate_series(1,10000000);
SELECT 10000000

-- 创建bloom索引
indexdb=# CREATE index btreeidx ON tbloom (i1, i2, i3, i4, i5, i6);
CREATE INDEX

indexdb=# EXPLAIN ANALYZE SELECT * FROM tbloom WHERE i2 = 898732 OR i5 = 123451;
                                                                  QUERY PLAN                                                                  
----------------------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=249337.50..385507.50 rows=99750 width=24) (actual time=345.415..684.760 rows=19 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Bitmap Heap Scan on tbloom  (cost=248337.50..374532.50 rows=41562 width=24) (actual time=397.157..672.875 rows=6 loops=3)
         Filter: ((i2 = 898732) OR (i5 = 123451))
         Rows Removed by Filter: 3333327
         Heap Blocks: exact=21455
         ->  Bitmap Index Scan on btreeidx  (cost=0.00..248312.56 rows=10000000 width=0) (actual time=331.686..331.686 rows=10000000 loops=1)
 Planning time: 0.165 ms
 Execution time: 684.813 ms
(10 rows)

-- 创建数组化索引
indexdb=# create index ON tbloom USING gin ( (array[i2,i5]));
CREATE INDEX

indexdb=# explain analyze select * from tbloom where (ARRAY[i2, i5]) && array[898732] or (ARRAY[i2, i5]) && array[123451];
                                                              QUERY PLAN                                                              
--------------------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on tbloom  (cost=991.87..68961.41 rows=99750 width=24) (actual time=0.068..0.174 rows=41 loops=1)
   Recheck Cond: ((ARRAY[i2, i5] && '{898732}'::integer[]) OR (ARRAY[i2, i5] && '{123451}'::integer[]))
   Heap Blocks: exact=41
   ->  BitmapOr  (cost=991.87..991.87 rows=100000 width=0) (actual time=0.046..0.046 rows=0 loops=1)
         ->  Bitmap Index Scan on tbloom_array_idx  (cost=0.00..471.00 rows=50000 width=0) (actual time=0.030..0.030 rows=23 loops=1)
               Index Cond: (ARRAY[i2, i5] && '{898732}'::integer[])
         ->  Bitmap Index Scan on tbloom_array_idx  (cost=0.00..471.00 rows=50000 width=0) (actual time=0.015..0.015 rows=18 loops=1)
               Index Cond: (ARRAY[i2, i5] && '{123451}'::integer[])
 Planning time: 0.266 ms
 Execution time: 0.242 ms
(10 rows)

Time: 1.311 ms
```
性能提升明显


##### 8.表中数据量少时

```
postgres=# create table tbl_index_less(a int);
CREATE TABLE

postgres=# create index tbl_index_less_a on tbl_index_less using btree (a);
CREATE INDEX

-- 加10条
postgres=# insert into tbl_index_less select generate_series(1,10);
INSERT 0 10

postgres=# analyze tbl_index_less ;
ANALYZE

postgres=# explain analyze select * from tbl_index_less where a = 4;
                                               QUERY PLAN                                               
--------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index_less  (cost=0.00..1.12 rows=1 width=4) (actual time=0.013..0.016 rows=1 loops=1)
   Filter: (a = 4)
   Rows Removed by Filter: 9
 Planning time: 0.276 ms
 Execution time: 0.054 ms
(5 rows)

-- 加100条
postgres=# insert into tbl_index_less select generate_series(10,100);
INSERT 0 91

postgres=# explain analyze select * from tbl_index_less where a = 4;
                                               QUERY PLAN                                               
--------------------------------------------------------------------------------------------------------
 Seq Scan on tbl_index_less  (cost=0.00..2.26 rows=1 width=4) (actual time=0.017..0.033 rows=1 loops=1)
   Filter: (a = 4)
   Rows Removed by Filter: 100
 Planning time: 0.236 ms
 Execution time: 0.062 ms
(5 rows)

-- 1000条
postgres=# insert into tbl_index_less select generate_series(100,1000);
INSERT 0 901

postgres=# analyze tbl_index_less ;
ANALYZE
postgres=# explain analyze select * from tbl_index_less where a = 4;
                                                              QUERY PLAN                                                              
--------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using tbl_index_less_a on tbl_index_less  (cost=0.28..8.29 rows=1 width=4) (actual time=0.010..0.010 rows=1 loops=1)
   Index Cond: (a = 4)
   Heap Fetches: 1
 Planning time: 0.073 ms
 Execution time: 0.023 ms
(5 rows)

```
tips 

数据库是如何知道表中的数据量及数据分布情况 ，主要是依赖统计信息 pg_class ,pg_stats。

当表数据变更很大时，如批量导入数据或删除数据时。需要及时使用analyze更新统计信息。

<!--
索引在哪些情况下失效
https://www.cnblogs.com/alianbog/p/5648455.html

-->

关于 null 
https://yq.aliyun.com/articles/241219

查看表顺序扫描和索引的次数
```
select * from pg_stat_all_tables where relname = 'tab_name';
select * from pg_stat_all_indexes where relname = 'tbl_name';
```
创建索引
http://www.cnblogs.com/alianbog/p/5631505.html 

mysql 索引建议 参考
https://mp.weixin.qq.com/s/xdbo67F72a9eTV93TEuL6w

[索引利用统计](https://github.com/powa-team/pg_qualstats)
```
A PostgreSQL extension for collecting statistics about predicates, helping find what indices are missing
```
