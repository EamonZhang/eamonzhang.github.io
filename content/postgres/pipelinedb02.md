---
title: "Pipelinedb 简介"
date: 2018-12-12T11:39:47+08:00
draft: false
---

##### 项目已经停止维护

适配支持版本
```
PostgreSQL 10: 10.1, 10.2, 10.3, 10.4, 10.5
PostgreSQL 11: 11.0
```

#### 基本概念

##### 流(Stream) 
流是基础，Continuous Views和transform则是基于流中的数据进行处理的手段。
对于同一份数据，只需要定义一个流，写入一份即可。
如果对同一份数据有多个维度的统计，可以写在一条SQL完成的（如同一维度的运算或者可以支持窗口的多维度运算），只需定义一个Continuous Views或transform。如果不能在同一条SQL中完成计算，则定义多个Continuous Views或transform即可。
如果有多份数据来源（例如设计时就已经区分了不同的表）时，定义不同的流即可；

##### 流视图  
流视图，其实就是定义统计分析的QUERY， 例如select id, count(*), avg(x), ... from stream_1 group by ...; 就属于一个流视图。
定义好之后，数据插入流(stream_1)，这个流视图就会不断增量的进行统计，你只要查询这个流视图，就可以查看到实时的统计结果。
数据库中存储的是实时统计的结果（实际上是在内存中进行增量合并的，增量的方式持久化）。

##### Transforms   
与流视图不同的是，transform是用来触发事件的，所以它可以不保留数据，但是可以设定条件，当记录满足条件时，就触发事件。
例如监视传感器的值，当值的范围超出时，触发报警（如通过REST接口发给指定的server），或者将报警记录下来（通过触发器函数）。

##### 支持特性  
pipelinedb继承了PostgreSQL很好的扩展性，例如支持了概率统计相关的功能，例如HLL等。用起来也非常的爽，例如统计网站的UV，或者红绿灯通过的汽车编号唯一值车流，通过手机信号统计基站辐射方圆多少公里的按时UV等。
Bloom Filter    
Count-Min Sketch    
Filtered-Space Saving Top-K    
HyperLogLog    
T-Digest    

##### 滑窗(Sliding Windows)    
因为很多场景的数据有时效，或者有时间窗口的概念，所以pipelinedb提供了窗口分片的接口，允许用户对数据的时效进行定义。
例如仅仅统计最近一分钟的时间窗口内的统计数据。
比如热力图，展示最近一分钟的热度，对于旧的数据不关心，就可以适应SW进行定义，从而保留的数据少，对机器的要求低，效率还高。

#### 安装 base on centos7&postgres10  

```
add repository
curl -s http://download.pipelinedb.com/yum.sh | sudo bash

pipeline package
sudo yum install pipelinedb-postgresql-10

修改数据库配置
# At the bottom of <data directory>/postgresql.conf
shared_preload_libraries = 'pipelinedb'
max_worker_processes = 128

重启数据库
systemctl restart postgresql-10

创建扩展 pipelinedb
CREATE EXTENSION pipelinedb

查看
\dx
                                               已安装扩展列表
        名称        | 版本  |  架构模式  |                               描述                                
--------------------+-------+------------+-------------------------------------------------------------------
 pipelinedb         | 1.0.0 | public     | PipelineDB
```

#### 一个简单的例子

```
创建一个流

CREATE  FOREIGN TABLE  s1 (id int, val int) SERVER pipelinedb;  // 理解为学生Id，成绩

流视图统计count, avg, min, max, sum几个常见维度
CREATE VIEW v1 WITH (action=materialize) AS  SELECT id,count(*),avg(val),min(val),max(val),sum(val)
FROM s1 GROUP BY id;

插入数据
insert into s1 values (0,100);
insert into s1 values (1,90);
insert into s1 values (2,93);
insert into s1 values (0,99);
insert into s1 values (1,96);
insert into s1 values (2,83);

查看结果

pipelinedb=# select * from v1;
 id | count |         avg         | min | max | sum
----+-------+---------------------+-----+-----+-----
  1 |     2 | 93.0000000000000000 |  90 |  96 | 186
  0 |     2 | 99.5000000000000000 |  99 | 100 | 199
  2 |     2 | 88.0000000000000000 |  83 |  93 | 176
(3 行记录)

pipelinedb=# select * from v1_mrel;
 id | count |   avg   | min | max | sum | $pk
----+-------+---------+-----+-----+-----+-----
  1 |     2 | {2,186} |  90 |  96 | 186 |   4
  0 |     2 | {2,199} |  99 | 100 | 199 |   6
  2 |     2 | {2,176} |  83 |  93 | 176 |   5
(3 行记录)

表结构概览

pipelinedb=# \d
 public   | s1                 | 所引用的外表 | postgres
 public   | v1                 | 视图         | postgres
 public   | v1_def             | 视图         | postgres
 public   | v1_mrel            | 数据表       | postgres
 public   | v1_osrel           | 所引用的外表 | postgres
 public   | v1_seq             | 序列数       | postgres

pipelinedb=# \d+ s1
                                               引用的外部表 "public.s1"
       栏位        |           类型           | Collation | Nullable | Default | FDW options | 存储  | 统计目标 | 描述
-------------------+--------------------------+-----------+----------+---------+-------------+-------+----------+------
 id                | integer                  |           |          |         |             | plain |          |
 val               | integer                  |           |          |         |             | plain |          |
 arrival_timestamp | timestamp with time zone |           |          |         |             | plain |          |
Server: pipelinedb

pipelinedb=# \d+ v1
                        视图 "public.v1"
 栏位  |  类型   | Collation | Nullable | Default | 存储  | 描述
-------+---------+-----------+----------+---------+-------+------
 id    | integer |           |          |         | plain |
 count | bigint  |           |          |         | plain |
 avg   | numeric |           |          |         | main  |
 min   | integer |           |          |         | plain |
 max   | integer |           |          |         | plain |
 sum   | bigint  |           |          |         | plain |
视图定义:
 SELECT v1_mrel.id,
    v1_mrel.count,
    int8_avg(v1_mrel.avg) AS avg,
    v1_mrel.min,
    v1_mrel.max,
    v1_mrel.sum
   FROM ONLY v1_mrel;

pipelinedb=# \d+ v1_def
                      视图 "public.v1_def"
 栏位  |  类型   | Collation | Nullable | Default | 存储  | 描述
-------+---------+-----------+----------+---------+-------+------
 id    | integer |           |          |         | plain |
 count | bigint  |           |          |         | plain |
 avg   | numeric |           |          |         | main  |
 min   | integer |           |          |         | plain |
 max   | integer |           |          |         | plain |
 sum   | bigint  |           |          |         | plain |
视图定义:
 SELECT s1.id,
    count(*) AS count,
    avg(s1.val) AS avg,
    min(s1.val) AS min,
    max(s1.val) AS max,
    sum(s1.val) AS sum
   FROM s1
  GROUP BY s1.id;
选项: action=materialize, cv=v1, stream=public.s1, matrel=v1_mrel, overlay=v1, osrel=v1_osrel, seqrel=v1_seq, pkindex=v1_mrel_pkey, lookupindex=v1_mrel_expr_idx

pipelinedb=# \d+ v1_mrel
                            数据表 "public.v1_mrel"
 栏位  |   类型   | Collation | Nullable | Default |   存储   | 统计目标 | 描述
-------+----------+-----------+----------+---------+----------+----------+------
 id    | integer  |           |          |         | plain    |          |
 count | bigint   |           |          |         | plain    |          |
 avg   | bigint[] |           |          |         | extended |          |
 min   | integer  |           |          |         | plain    |          |
 max   | integer  |           |          |         | plain    |          |
 sum   | bigint   |           |          |         | plain    |          |
 $pk   | bigint   |           | not null |         | plain    |          |
索引：
    "v1_mrel_pkey" PRIMARY KEY, btree ("$pk")
    "v1_mrel_expr_idx" btree (pipelinedb.hash_group(id))
选项: fillfactor=50

pipelinedb=# \d+ v1_osrel
                                              引用的外部表 "public.v1_osrel"
       栏位        |           类型           | Collation | Nullable | Default | FDW options |   存储   | 统计目标 | 描述
-------------------+--------------------------+-----------+----------+---------+-------------+----------+----------+------
 old               | v1                       |           |          |         |             | extended |          |
 new               | v1                       |           |          |         |             | extended |          |
 delta             | v1_mrel                  |           |          |         |             | extended |          |
 arrival_timestamp | timestamp with time zone |           |          |         |             | plain    |          |
Server: pipelinedb

pipelinedb=# \d+ v1_seq
                            序列数 "public.v1_seq"
  类型  | Start | Minimum |       Maximum       | Increment | Cycles? | Cache
--------+-------+---------+---------------------+-----------+---------+-------
 bigint |     1 |       1 | 9223372036854775807 |         1 | no      |     1
属于: public.v1_mrel."$pk"

```
