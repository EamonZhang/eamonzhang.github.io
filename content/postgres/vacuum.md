---
title: "vacuum 垃圾回收器"
date: 2018-12-05T16:48:00+08:00
draft: false
---

#### 介绍

数据库总是不断地在执行删除，更新等操作。良好的空间管理非常重要，能够对性能带来大幅提高。在postgresql中用于维护数据库磁盘空间的工具是VACUUM，其重要的作用是删除那些已经标示为删除的数据并释放空间。
postgresql中执行delete,update操作后，表中的记录只是被标示为删除状态，并没有释放空间，在以后的update或insert操作中该部分的空间是不能够被重用的。经过vacuum清理后，空间才能得到释放。


#### 意义
PostgreSQL每个表和索引的数据都是由很多个固定尺寸的页面存储（通常是 8kB，不过在编译服务器时[–with-blocksize]可以选择其他不同的尺寸）

PostgreSQL中数据操作永远是Append操作,具体含义如下:

- insert 时向页中添加一条数据
- update 将历史数据标记为无效,然后向页中添加新数据
- delete 将历史数据标记为无效  

因为这个特性,所以需要定期对数据库vacuum,否则会导致数据库膨胀,建议打开autovacuum.

#### 文法

```
VACUUM [ ( { FULL | FREEZE | VERBOSE | ANALYZE | DISABLE_PAGE_SKIPPING } [, ...] ) ] [ table_name [ (column_name [, ...] ) ] ]
VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] [ table_name ]
VACUUM [ FULL ] [ FREEZE ] [ VERBOSE ] ANALYZE [ table_name [ (column_name [, ...] ) ] ]
```
#### 参数

##### FULL
Selects “full” vacuum, which can reclaim more space, but takes much longer and exclusively locks the table. This method also requires extra disk space, since it writes a new copy of the table and doesn't release the old copy until the operation is complete. Usually this should only be used when a significant amount of space needs to be reclaimed from within the table.

大招，需要更多的磁盘空间，空间将会被重新整理。　auto vacumm 只删除空间，并没有整理使空间更紧凑。

##### VERBOSE
Prints a detailed vacuum activity report for each table.  
打印回收时每个table 执行细节

##### ANALYZE
Updates statistics used by the planner to determine the most efficient way to execute a query.

统计库

##### 例子

可以精确指定需要执行的table, 如果不指定被回收的对象，默认为当前database 下所有 table   
```
VACUUM (FULL,VERBOSE, ANALYZE) table_name;
```

将执行过程细节打印到文件中
```
psql -U user -d database  -c "vacuum FULL VERBOSE ANALYZE table"  > vacuum-01.log 2>&1
```

##### 测试 vacuum full

ctid (0,59) 表示数据存放位置为第0个页面的第59行

创建测试表
```
create table test_vacuum(
    objectid bigserial not null,                --唯一编号，主键
    name text not null,                         --名称
    describe text,                              --备注
    generate timestamptz default now() not null,--创建日期
    constraint pk_test1_objectid primary key(objectid)
); 
```

创建随机生成中文字符函数
```
drop function if exists gen_random_zh(int,int);
create or replace function gen_random_zh(int,int)
    returns text
as $$
	select string_agg(chr((random()*(20901-19968)+19968 )::integer) , '')  from generate_series(1,(random()*($2-$1)+$1)::integer); $$ language sql; 
```

导入测试数据
```
insert into test_vacuum(name)
  select gen_random_zh(8,32) from generate_series(1,10000); 
```
    
查看数据布局
```
select ctid,objectid from test_vacuum limit 500;
ctid,objectid
--------
 ....
(1,17) 92
(1,18) 93
(1,19) 94
(1,20) 95 
 ....
```

更新表中数据
```
update test2 set name=gen_random_zh(8,32) where objectid = 93;
```
更新后表中数据布局
```
select ctid,objectid from test_vacuum limit 500;
ctid,objectid
--------
 ....
(1,17) 92
(1,19) 94
(1,20) 95 
 ....
```

执行 vacuum FULL 
```
vacuum FULL test_vacuum

select ctid,objectid from test_vacuum limit 500;
ctid,objectid
--------
 ....
(1,17) 92
(1,18) 94
(1,29) 95 
 ....

```

数据布局变的更紧凑，　只执行vacuum 数据不会移动

#### 扩展阅读

1.回收空间

这个通常是大家最容易想起来的功能。回收空间，将dead tuple清理掉。但是已经分配的空间，一般不会释放掉。除非做vacuum full，但是需要exclusive lock。一般不太建议，因为如果表最终还是会涨到
这个高水位上，经常做vacuum full意义不是非常大。一般合理设置vacuum参数，进行常规vacuum也就够了。


2.冻结tuple的xid

PG会在每条记录（tuple）的header中，存放xmin,xmax信息(增删改事务ID)。transactionID的最大值为2的32次，即无符整形来表示。当transactionID超过此最大值后，会循环使用。
这会带来一个问题：就是最新事务的transactionID会小于老事务的transactionID。如果这种情况发生后，PG就没有办法按transactionID来区分事务的先后，也没有办法实现MVCC了。因此PG用vacuum后台进程，
按一定的周期和算法触发vacuum动作，将过老的tuple的header中的事务ID进行冻结。冻结事务ID，即将事务ID设置为“2”（“0”表示无效事务ID；“1”表示bootstrap，即初始化；“3”表示最小的事务ID）。PG认为被冻结的事务ID比任何事务都要老。这样就不会出现上面的这种情况了。

3.更新统计信息

vacuum analyze时，会更新统计信息，让PG的planner能够算出更准确的执行计划。autovacuum_analyze_threshold和autovacuum_analyze_scale_factor参数可以控制analyze的触发的频率。

4.更新visibility map

在PG中，有一个visibility map用来标记那些page中是没有dead tuple的。这有两个好处，一是当vacuum进行scan时，直接可以跳过这些page。二是进行index-only scan时，可以先检查下visibility map。这样减少fetch tuple时的可见性判断，从而减少IO操作，提高性能。另外visibility map相对整个relation，还是小很多，可以cache到内存中。

#### vacuum参数介绍

##### autovacuum 触发条件，大致有以下几个：
```
autovacuum：默认为on，表示是否开起autovacuum。默认开起。特别的，当需要冻结xid时，尽管此值为off，PG也会进行vacuum。
autovacuum_naptime：下一次vacuum的时间，默认1min。 这个naptime会被vacuum launcher分配到每个DB上。autovacuum_naptime/num of db。
log_autovacuum_min_duration：记录autovacuum动作到日志文件，当vacuum动作超过此值时。 “-1”表示不记录。“0”表示每次都记录。
autovacuum_max_workers：最大同时运行的worker数量，不包含launcher本身。
autovacuum_vacuum_threshold:默认50。与autovacuum_vacuum_scale_factor配合使用， autovacuum_vacuum_scale_factor默认值为20%。
                          当update,delete的tuples数量超过autovacuum_vacuum_scale_factor*table_size+autovacuum_vacuum_threshold时，进行vacuum。如果要使vacuum工作勤奋点，则将此值改小。
autovacuum_analyze_threshold:默认50。与autovacuum_analyze_scale_factor配合使用, autovacuum_analyze_scale_factor默认10%。
                          当update,insert,delete的tuples数量超过autovacuum_analyze_scale_factor*table_size+autovacuum_analyze_threshold时，进行analyze。
autovacuum_freeze_max_age和autovacuum_multixact_freeze_max_age：前面一个200 million,后面一个400 million。离下一次进行xid冻结的最大事务数。
autovacuum_vacuum_cost_delay：如果为-1，取vacuum_cost_delay值。
autovacuum_vacuum_cost_limit：如果为-1，到vacuum_cost_limit的值，这个值是所有worker的累加值。
```
##### 基于代价的vacuum参数:
```
vacuum_cost_delay ：计算每个毫秒级别所允许消耗的最大IO，vacuum_cost_limit/vacuum_cost_dely。 默认vacuum_cost_delay为20毫秒。
vacuum_cost_page_hit ：vacuum时，page在buffer中命中时，所花的代价。默认值为1。
vacuum_cost_page_miss：vacuum时，page不在buffer中，需要从磁盘中读入时的代价默认为10。 vacuum_cost_page_dirty：当vacuum时，修改了clean的page。这说明需要额外的IO去刷脏块到磁盘。默认值为20。
vacuum_cost_limit：当超过此值时，vacuum会sleep。默认值为200。
把上面每个cost值调整的小点，然后把limit值调的大些，可以延长每次vacuum的时间。这样做，如果在高负载的系统当中，可能IO会有所影响，因vacuum。但是对于表物理存储空间的增长会有所减缓。
```

[参见](http://blog.itpub.net/30088583/viewspace-1592066/)

#### 扩展阅读  

Autovacuum 基础调优 [中文](https://mp.weixin.qq.com/s/ekKuDMEkQsZX5vx0VG0_1A) [英文](https://blog.2ndquadrant.com/autovacuum-tuning-basics/#PostgreSQL%20Performance%20Tuning)


#### 实战
 
 autovacuum 在达到触发条件时就会执行。如果触发在业务高峰时发生，对线上的业务性能会带来影响。应避免。

 数据库的vacuum 为可控的，避免autovacuum对线上数据库在运行高峰时的影响。

 在必要时进行手动执行vacuum ,在业务低峰期执行。 

 监控数据库的autovacuum ，使其在达到触发条件前被及时发现。

##### DBA 维护

- 参考表空间膨胀率计算执行预期效果
- 执行前设置 maintenance_work_mem 增加临时使用内存
- 执行前设置 vacuum_cost_delay , vacuum_cost_limit 调整处理速度
- 执行vacuum VERVOSE ANALYZE
- 执行analyze 更新统计信息
- 进度查看  select * from pg_stat_progress_vacuum ; 
- 注意wal 生成速率，可能会造成从库落后过多。wal找不到错误。从库需要重新拉取
- 注意业务峰值期对业务的造成影响
- 系统IO，主从主机带宽

