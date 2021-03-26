---
title: "TimescaleDB 时序数据库"
date: 2019-01-30T10:20:51+08:00
draft: false
---

时序数据库
https://github.com/timescale/timescaledb


数据库配置
https://github.com/timescale/timescaledb-tune


copy并行导入数据
https://github.com/timescale/timescaledb-parallel-copy


#### 常用方法

创建拓展
```
CREATE EXTENSION timescaledb;
```

创建一个普通的表
```
CREATE TABLE conditions (
  time        TIMESTAMPTZ       NOT NULL,
  location    TEXT              NOT NULL,
  temperature DOUBLE PRECISION  NULL,
  humidity    DOUBLE PRECISION  NULL
);
```

转换成时序数据库表
```
SELECT create_hypertable('conditions', 'time');
```
- conditions 表名
- time 时序字段

修改时序间隔 对新表生效
```
SELECT set_chunk_time_interval('conditions', INTERVAL '24 hours');
```

查看分区
```
SELECT show_chunks('conditions');

SELECT show_chunks('conditions', older_than => INTERVAL '3 months')

SELECT show_chunks('conditions', older_than => DATE '2017-01-01');

SELECT show_chunks(newer_than => INTERVAL '3 months');

SELECT show_chunks(older_than => INTERVAL '3 months', newer_than => INTERVAL '4 months');

```
查看数据大小
```
SELECT * FROM timescaledb_information.hypertable;
```

自动删除
```
添加规则
SELECT add_drop_chunks_policy('conditions', INTERVAL '6 months');
删除规则
SELECT remove_drop_chunks_policy('conditions');
```

#### 注意事项

```
When creating hypertables, one constraing that TimescaleDB imposes is that the partitioning column (in your case 'date_time') must be included in any unique indexes (and Primary Keys) for that table.
```
https://stackoverflow.com/questions/61205063/error-cannot-create-a-unique-index-without-the-column-date-time-used-in-part



#### 时序数据特征

- have a timestamp
- append only ,less update or delete
- recent hot

#### 限制

除分区列外不可以在其他列中有唯一约束

原数据库中的唯一约束为全局表内唯一约束，在分区表（chunks）中不能够保证全局唯一

```
When converting a normal SQL table to a hypertable, pay attention to how you handle constraints.
A hypertable can contain foreign keys to normal SQL table columns, but the reverse is not allowed. UNIQUE and PRIMARY constraints must include the partitioning key.
```

#### 最佳实践

##### chunk 时间范围

 与数据量有关，一个chunk容量约1/4 内存大小
```
SELECT * FROM create_hypertable('conditions', 'time',
       chunk_time_interval => INTERVAL '1 day');
```
##### 组合索引

 1 等值查询 （e,time）e 为等值查询列 time 为分区时间列   
 2 范围查询  (time,c) c 为连续值列 

##### 排序

##### 压缩

 设置历史数据压缩策略，压缩后变成列存，且为只读

 ```
  alter table conditions set( timescaledb.compress);

  timescaledb.compress_segmentby
  timescaledb.compress_orderby
 ```
 设置压缩策略
 ```
  SELECT add_compress_chunks_policy('conditions', INTERVAL '60d'); 
 ```
 删除压缩策略
 ```
  remove_compress_chunks_policy()
 ```
 手动压缩
 ```
 SELECT compress_chunk('_timescaledb_internal._hyper_1_2_chunk');
 ```
 解压缩
 ```
 SELECT compress_chunk('_timescaledb_internal._hyper_1_2_chunk');
 ```
 查看压缩情况
 ```
 SELECT * FROM timescaledb_information.compressed_chunk_stats;
 ```
 
 手动批量压缩

 ```
 SELECT compress_chunk(i) from show_chunks('conditions', newer_than, older_than) i;	
 ```

##### 保留策略

 设置保留数据策略

```
SELECT add_drop_chunks_policy('conditions', INTERVAL '24 hours');
```
##### 连续分析窗口

 物化视图自动持续更新

#### 更多信息查看

比如压缩策略，保留策略，持续集成策略等
```
\dv timescaledb_information.*
                            List of relations
         Schema          |            Name             | Type |  Owner   
-------------------------+-----------------------------+------+----------
 timescaledb_information | compressed_chunk_stats      | view | postgres
 timescaledb_information | compressed_hypertable_stats | view | postgres
 timescaledb_information | continuous_aggregate_stats  | view | postgres
 timescaledb_information | continuous_aggregates       | view | postgres
 timescaledb_information | drop_chunks_policies        | view | postgres
 timescaledb_information | hypertable                  | view | postgres
 timescaledb_information | license                     | view | postgres
 timescaledb_information | policy_stats                | view | postgres
 timescaledb_information | reorder_policies            | view | postgres
```
