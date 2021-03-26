---
title: "高级SQL"
date: 2021-01-11T17:05:25+08:00
draft: false
---

- 分组集
- 排序集
- 假象集
- 窗口函数
- 递归

#### 递归应用

递归加速count(distint) 查询。 使用场景，数据分布：大数据集但其中的类型却很少
```
-- 创建表
test1=# create table recurive_t(user_id int,free float,info text);
CREATE TABLE
-- 加入数据
test1=# insert into recurive_t select 1 ,generate_series(0,1000000),'user 1 pay !!!';
test1=# insert into recurive_t select 2 ,generate_series(0,2000000),'user 2 pay !!!';
test1=# insert into recurive_t select 3 ,generate_series(0,3000000),'user 3 pay !!!';
test1=# insert into recurive_t select 4 ,generate_series(0,4000000),'user 4 pay !!!';
test1=# insert into recurive_t select 5 ,generate_series(0,4000000),'user 5 pay !!!';
test1=# analyze recurive_t ;
ANALYZE
```

```
-- count(distinct()) 查询
test1=# explain analyze select count(distinct(user_id)) from recurive_t ;
                                                                  QUERY PLAN                                                                   
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=10000412944.36..10000412944.37 rows=1 width=8) (actual time=2793.108..2793.108 rows=1 loops=1)
   ->  Seq Scan on recurive_t  (cost=10000000000.00..10000377992.29 rows=13980829 width=4) (actual time=0.006..1065.338 rows=14000005 loops=1)
 Planning time: 0.054 ms
 Execution time: 2793.144 ms
(4 行记录)

时间：2793.548 ms (00:02.794)
```

```
-- group by 查询
test1=# explain analyze select user_id from recurive_t group by user_id;
                                                                                      QUERY PLAN                                                                                      
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Group  (cost=1000.46..511742.60 rows=5 width=4) (actual time=8.073..1119.549 rows=5 loops=1)
   Group Key: user_id
   ->  Gather Merge  (cost=1000.46..511742.57 rows=10 width=4) (actual time=8.072..1138.226 rows=15 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         ->  Group  (cost=0.43..510741.40 rows=5 width=4) (actual time=0.053..845.258 rows=5 loops=3)
               Group Key: user_id
               ->  Parallel Index Only Scan using recurive_t_user_id_idx on recurive_t  (cost=0.43..496178.03 rows=5825345 width=4) (actual time=0.050..694.273 rows=4666668 loops=3)
                     Heap Fetches: 1803282
 Planning time: 0.133 ms
 Execution time: 1138.276 ms
(11 行记录)

时间：1139.009 ms (00:01.139)
```

```
-- 添加索引，对优化没有效果
test1=# create index ON recurive_t (user_id );
CREATE INDEX
时间：5990.992 ms (00:05.991)
test1=# explain analyze select count(distinct(user_id)) from recurive_t ;
                                                                             QUERY PLAN                                                                             
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=613020.52..613020.53 rows=1 width=8) (actual time=3180.517..3180.517 rows=1 loops=1)
   ->  Index Only Scan using recurive_t_user_id_idx on recurive_t  (cost=0.43..578020.51 rows=14000005 width=4) (actual time=0.089..1531.050 rows=14000005 loops=1)
         Heap Fetches: 14000005
 Planning time: 0.288 ms
 Execution time: 3180.570 ms
(5 行记录)

时间：3181.520 ms (00:03.182)
```

```
--- 画重点，利用递归查询。效果惊人
test1=# explain analyze with recursive skip as(
    (
      select min(t.user_id) as user_id from recurive_t t
    )
    union
    (
      select (select min(t.user_id) from recurive_t t where t.user_id > s.user_id )
         from skip s
    )
)
select count(*) from skip;
                                                                                       QUERY PLAN                                                                                        
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Aggregate  (cost=54.94..54.95 rows=1 width=8) (actual time=0.271..0.271 rows=1 loops=1)
   CTE skip
     ->  Recursive Union  (cost=0.47..52.67 rows=101 width=4) (actual time=0.051..0.256 rows=6 loops=1)
           ->  Result  (cost=0.47..0.48 rows=1 width=4) (actual time=0.048..0.048 rows=1 loops=1)
                 InitPlan 3 (returns $1)
                   ->  Limit  (cost=0.43..0.47 rows=1 width=4) (actual time=0.043..0.044 rows=1 loops=1)
                         ->  Index Only Scan using recurive_t_user_id_idx on recurive_t t_1  (cost=0.43..525904.40 rows=15394398 width=4) (actual time=0.042..0.042 rows=1 loops=1)
                               Index Cond: (user_id IS NOT NULL)
                               Heap Fetches: 1
           ->  WorkTable Scan on skip s  (cost=0.00..5.02 rows=10 width=4) (actual time=0.031..0.032 rows=1 loops=6)
                 SubPlan 2
                   ->  Result  (cost=0.47..0.48 rows=1 width=4) (actual time=0.028..0.028 rows=1 loops=6)
                         InitPlan 1 (returns $3)
                           ->  Limit  (cost=0.43..0.47 rows=1 width=4) (actual time=0.027..0.027 rows=1 loops=6)
                                 ->  Index Only Scan using recurive_t_user_id_idx on recurive_t t  (cost=0.43..188135.76 rows=5131466 width=4) (actual time=0.025..0.025 rows=1 loops=6)
                                       Index Cond: ((user_id IS NOT NULL) AND (user_id > s.user_id))
                                       Heap Fetches: 4
   ->  CTE Scan on skip  (cost=0.00..2.02 rows=101 width=0) (actual time=0.054..0.263 rows=6 loops=1)
 Planning time: 0.415 ms
 Execution time: 0.373 ms
(20 行记录)

时间：1.872 ms
```

###### WITH 

利用with as 不需要修改索引，指定查询计划

```
select * from T where A=1 and B = 2;

执行计划可能使用A索引，也可能走B索引

WITH T_a as (
 select * from T where A = 1;
)
select * from T_a where B = 1;

执行计划走A 索引 
```
