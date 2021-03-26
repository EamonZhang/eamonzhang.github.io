---
title: "pg_pathman 分区表"
date: 2019-01-24T10:56:06+08:00
draft: false
---

#### 介绍

分区表的诉求在现实的生成中的意义不必多说，pg以前的实现方式多采用触发器，rules实现。数据量上来时性能明显不尽如意。   
虽然pg10 ，11 版本在分区表的特性上不断发力。但是性能啥还是不够给力。   
pg_pathman 分区表功能在目前的pg版本10.6 中优势还是非常明显的。   

在期待pg自身分区表特性的同时，当前的pg10中还是使用pg_pathman来实现分区功能吧。

##### pathman与pg11 对比

优点:
支持HASH和RANGE分区，后续会支持LIST分区 支持自动和手动的分区维护  
为分区表生成更有效的执行计划 通过引入两个自定义的执行计划节点RuntimeAppend & RuntimeMergeAppend，  
实现运行时动态添加分区到执行计划中 为新插入数据自动创建分区(只对RANGE分区) 提供用户callbacks接口处理创建分区事件。   
 提供在线分区实施(在线重定义)，父表数据迁移到子表，拆分， 合并分区
不足:   
不支持list分区;不支持二级分区;权限，索引，trigger等无法继承; 修改主键默认的seq需要重建分区。    

PG11内置分区   
优点:   
支持hash，range，list分区 支持多字段组合分区，支持表达式分区 支持创建主键，外键，索引，分区表自动继承。 支持update分区键 支持分区表DETACH，ATTACH，支持二级分区 分区自动创建   
Default partition Partition improvements   
不足:   
在主表添加权限，索引，trigger等无法继承 分区表不可以作为其他表的外键主表   


#### 分区表数量对插入数据的影响


https://www.jianshu.com/p/1cba77d18694

#### pathman 分区表 转换为原生分区表

https://github.com/digoal/blog/blob/master/201911/20191113_01.md

主要思路

1 创建一个与原来分区表一样的主表包括分区方式 。

2 将原来的主表上的分区都卸载为普通表，在重新按照原生分区表的方式挂载上去。

直接2 也行

拓展思考。 分区数据迁移使用pg_pathman，迁移后再转换到原生表。

#### 注意事项

需要将pg_pathman放在后面注册，如pg_stat_statements。
```
shared_preload_libraries = 'pg_stat_statements,pg_pathman'
```

创建拓展
```
CREATE SCHEMA pathman;
GRANT USAGE ON SCHEMA pathman TO PUBLIC;
CREATE EXTENSION pg_pathman WITH SCHEMA pathman;
```

#### 参考

https://github.com/postgrespro/pg_pathman

https://github.com/digoal/blog/blob/362b84417ca8b7aaf1add31fe7689c347642bb9a/201610/20161024_01.md

#### 常见错误
```
FATAL:  could not load library "/usr/pgsql-12/lib/pg_pathman.so": /usr/pgsql-12/lib/pg_pathman.so: undefined symbol: expandTableLikeClause
postgres 版本问题
```

#### 简单应用

1 将现有表分区，禁止数据迁移

2 并行迁移数据

3 禁止主表

表 log  必需满足

- 字段 created_time not null

- 无外键约束 

按月分表,后续数据超出范围会自动创建分区（默认）

查看表中最早日期
```
select min(created_time) from log;
---
2018-05-18 00:00:00
```

分表 false 表示禁止数据移动
```
select create_range_partitions('log'::regclass,'created_time','2018-05-18 00:00:00'::timestamp,interval '1 month', null,false);
```

查看分区表
```
select * from pathman_partition_list where parent = 'log'::regclass;
```

并行迁移数据
```
select partition_table_concurrently('log'::regclass,10000,1.0);
```

查看迁移状态
```
select * from pathman_concurrent_part_tasks ;
```

禁主表
```
select set_enable_parent('log'::regclass,false);
```

查看数据
```
select count(1) from only log;
```

#### 分区表常用管理

将一个分区拆分为两个分区
```
split_range_partition(partition_relid REGCLASS,
                      split_value     ANYELEMENT,
                      partition_name  TEXT DEFAULT NULL,
                      tablespace      TEXT DEFAULT NULL)
```

合并多个连续分区,数据将到第一个分区
```
merge_range_partitions(variadic partitions REGCLASS[])
```

向后追加一个分区,分区间隔默认
```
append_range_partition(parent_relid   REGCLASS,
                       partition_name TEXT DEFAULT NULL,
                       tablespace     TEXT DEFAULT NULL)
```

向前追加一个分区，分区间隔默认
```
prepend_range_partition(parent_relid   REGCLASS,
                        partition_name TEXT DEFAULT NULL,
                        tablespace     TEXT DEFAULT NULL)
```

添加一个自定义间隔分区: 如加一个
```
add_range_partition(parent_relid   REGCLASS,
                    start_value    ANYELEMENT,
                    end_value      ANYELEMENT,
                    partition_name TEXT DEFAULT NULL,
                    tablespace     TEXT DEFAULT NULL)
```

删除一个分区，及数据是否删除. 不删除数据将入主表
```
drop_range_partition(partition TEXT, delete_data BOOLEAN DEFAULT TRUE)
```

卸载分区为普通表
```
detach_range_partition(partition_relid REGCLASS)
```

挂载普通表为分区表
```
attach_range_partition(parent_relid    REGCLASS,
                       partition_relid REGCLASS,
                       start_value     ANYELEMENT,
                       end_value       ANYELEMENT)
```

##### 参数

修改默认分区间隔
```
set_interval(relation REGCLASS, value ANYELEMENT)
```

是否禁用主表,禁用后执行计划将不在走主表
```
set_enable_parent(relation REGCLASS, value BOOLEAN)
```

是否自动创建分区. 开启后注意事项， 如果有一条数据的时间异常，会创建大量的分区表。灾难
```
set_auto(relation REGCLASS, value BOOLEAN)
```

#### 遗留问题

1 原表分区后数据磁盘占用增加近一倍，需要vacuum full 解决. 主表残留

数据全部分区后 vacuum 速度也很快

2 分区后对父表添加或删除索引操作对现有分区表不产生作用，仅对新生成的分区有效。[How do I create indexes?](https://github.com/postgrespro/pg_pathman/wiki/How-do-I-create-indexes%3F)

#### 注意事项

对已经分区的表使用copy 方式导入数据后数据只存在于父表中，此时执行partition_table_concurrently 无效果

解决
```
 1 set_enable_parent('log'::regclass, true)
```
```
 2 创建分区表 如插入一条数据 ， 时间比最小时间还小，select min(create) from only log
```
```
 3 partition_table_concurrently
```
