---
title: "pg_trgm的gist和gin索引加速字符匹配查询"
date: 2019-01-07T09:37:23+08:00
draft: false
---

## 背景

对车牌号的记忆有时可能记住的是前几位，有时可能是后几位，不同的人记车牌号的习惯也不同。   
通常是是容易记住首尾，中间不清楚。  
那么如何在大量已有车牌数据中快速根据模糊的信息来进行查询呢？ 

## 模拟

数据库表中约有500w条车牌号记录，对表中的车牌号进行模糊查询。  
即支持 car_id like '%XXXX%XXX%' 查询

```
---创建表
create table t_car (id int , car_id text);

--插入500万车牌数据 

insert into t_car select generate_series(1,5000000), (array['辽A','辽B','吉A','吉B','黑A','黑B'])[floor(random()*6+1)] || substring(md5(random()::text),0,6);

--查看数据

select * from t_car limit 5;
 id |  car_id  
----+----------
  1 | 吉A43bb9
  2 | 吉B19b64
  3 | 辽Afb04e
  4 | 吉Bcf90c
  5 | 辽Be67df
(5 行记录)

``` 

## 索引

- 顺序扫描

```
explain analyze verbose select * from t_car where car_id = '辽Be67df';
                                                          QUERY PLAN                                                          
------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..54069.87 rows=2 width=14) (actual time=0.458..268.782 rows=4 loops=1)
   Output: id, car_id
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on public.t_car  (cost=0.00..53069.67 rows=1 width=14) (actual time=140.151..253.061 rows=1 loops=3)
         Output: id, car_id
         Filter: (t_car.car_id = '辽Be67df'::text)
         Rows Removed by Filter: 1666665
         Worker 0: actual time=246.618..246.619 rows=0 loops=1
         Worker 1: actual time=173.812..251.916 rows=1 loops=1
 Planning time: 0.174 ms
 Execution time: 268.820 ms
(12 行记录)

时间：269.684 ms
```

- btree

```
创建btree类型索引
create index btree_index_01 on t_car using btree (car_id);

等值查询,结果还是相当给力
postgres=# explain analyze verbose select * from t_car where car_id = '辽Be67df';
                                                          QUERY PLAN                                                          
------------------------------------------------------------------------------------------------------------------------------
 Index Scan using btree_index_01 on public.t_car  (cost=0.43..3.77 rows=2 width=14) (actual time=0.047..0.057 rows=4 loops=1)
   Output: id, car_id
   Index Cond: (t_car.car_id = '辽Be67df'::text)
 Planning time: 0.218 ms
 Execution time: 0.091 ms
(5 行记录)

时间：0.971 ms

后模糊查询，不尽人意。不符合预期。
postgres=# explain analyze verbose select * from t_car where car_id like '辽Be67df%';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..54119.47 rows=498 width=14) (actual time=0.426..281.444 rows=4 loops=1)
   Output: id, car_id
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on public.t_car  (cost=0.00..53069.67 rows=208 width=14) (actual time=138.857..270.492 rows=1 loops=3)
         Output: id, car_id
         Filter: (t_car.car_id ~~ '辽Be67df%'::text)
         Rows Removed by Filter: 1666665
         Worker 0: actual time=148.488..267.226 rows=2 loops=1
         Worker 1: actual time=268.058..268.058 rows=0 loops=1
 Planning time: 0.153 ms
 Execution time: 281.481 ms
(12 行记录)

时间：282.275 ms
```

以上btree索引没有起到作用的原因,是因为在创建索引时，默认的opclass为等值查询。[详情](https://www.postgresql.org/docs/10/indexes-opclass.html)  

```
重新创建btree索引

drop index btree_index_01;
create index btree_index_01 on t_car using btree (car_id text_pattern_ops);

这次查询结果符合预期
explain analyze verbose select * from t_car where car_id like '辽Be67df%';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Index Scan using btree_index_01 on public.t_car  (cost=0.43..2.66 rows=498 width=14) (actual time=0.050..0.073 rows=4 loops=1)
   Output: id, car_id
   Index Cond: ((t_car.car_id ~>=~ '辽Be67df'::text) AND (t_car.car_id ~<~ '辽Be67dg'::text))
   Filter: (t_car.car_id ~~ '辽Be67df%'::text)
 Planning time: 0.473 ms
 Execution time: 0.106 ms
(6 行记录)

时间：1.407 ms

前模糊查询还是不行
explain analyze verbose select * from t_car where car_id like '%辽Be67df';
                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..54119.47 rows=498 width=14) (actual time=0.476..309.504 rows=4 loops=1)
   Output: id, car_id
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on public.t_car  (cost=0.00..53069.67 rows=208 width=14) (actual time=121.528..297.927 rows=1 loops=3)
         Output: id, car_id
         Filter: (t_car.car_id ~~ '%辽Be67df'::text)
         Rows Removed by Filter: 1666665
         Worker 0: actual time=200.075..294.789 rows=1 loops=1
         Worker 1: actual time=164.486..295.015 rows=1 loops=1
 Planning time: 0.139 ms
 Execution time: 309.536 ms
(12 行记录)

时间：310.278 ms

解决前模糊查询的方法，反转查询字段。在逻辑上变成后模糊查询。
create index btree_index_02 on t_car using btree (reverse(car_id) text_pattern_ops);
```

- gin

真正的支持模糊查询

```
创建扩展
create extension pg_trgm;

创建gin索引

create index gin_index_01 on t_car using gin(car_id gin_trgm_ops);

模糊查询速度也能飞
explain analyze verbose select * from t_car where car_id like '%辽Be67df%';
                                                       QUERY PLAN                                                       
------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on public.t_car  (cost=36.86..579.80 rows=498 width=14) (actual time=3.936..4.018 rows=4 loops=1)
   Output: id, car_id
   Recheck Cond: (t_car.car_id ~~ '%辽Be67df%'::text)
   Heap Blocks: exact=4
   ->  Bitmap Index Scan on gin_index_01  (cost=0.00..36.73 rows=498 width=0) (actual time=3.900..3.900 rows=4 loops=1)
         Index Cond: (t_car.car_id ~~ '%辽Be67df%'::text)
 Planning time: 2.918 ms
 Execution time: 4.359 ms

explain analyze verbose select * from t_car where car_id like '%辽Be6%df%';
                                                        QUERY PLAN                                                         
---------------------------------------------------------------------------------------------------------------------------
 Bitmap Heap Scan on public.t_car  (cost=17.06..560.00 rows=498 width=14) (actual time=5.958..15.353 rows=35 loops=1)
   Output: id, car_id
   Recheck Cond: (t_car.car_id ~~ '%辽Be6%df%'::text)
   Rows Removed by Index Recheck: 3273
   Heap Blocks: exact=3098
   ->  Bitmap Index Scan on gin_index_01  (cost=0.00..16.93 rows=498 width=0) (actual time=5.172..5.172 rows=3308 loops=1)
         Index Cond: (t_car.car_id ~~ '%辽Be6%df%'::text)
 Planning time: 0.224 ms
 Execution time: 15.462 ms
(9 行记录)

```

## 扩展阅读

[rum](https://github.com/postgrespro/rum?spm=a2c4e.11153940.blogcont111793.51.50575bf0HjdIsl) 是一个索引插件，由Postgrespro开源，适合全文检索，属于GIN的增强版本。   

增强包括：   

1、在RUM索引中，存储了lexem的位置信息，所以在计算ranking时，不需要回表查询（而GIN需要回表查询）。    
 
2、RUM支持phrase搜索，而GIN无法支持。    

3、在一个RUM索引中，允许用户在posting tree中存储除ctid（行号）以外的字段VALUE，例如时间戳。    

如果这种需求多了还是考虑[elasticsearch](../es)吧

[zombodb](https://github.com/zombodb/zombodb)是PostgreSQL与ElasticSearch结合的一个索引接口，可以直接读写ES。
