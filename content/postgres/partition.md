---
title: "原生分区表"
date: 2020-12-31T10:17:03+08:00
draft: false
toc: true
---

## 分区表

数据库分区是一种将数据做物理分片的数据库设计技术，虽然分区技术可以有多种实现方法，

但其主要目的是为了在特定的SQL操作中减少数据读取的总量以缩减响应时间。

使用分区表对应用程序是透明的，对于INSERT,UPDATE,DELETE,SELECT操作，都只需要对父表tbl进行操作，而无需关心操作哪一张子表。

## 分区方式

- 水平分区  

  比如按照时间维度进行划分，订单时间。  
  
  水平分区划分方式 HASH , LIST , RANGE   

- 垂直分区

  范式规范 ： 订单数据 （客户表，商品表，订单表）

## 优点

- 性能提升。针对具体范围查询或点查询。
- 数据管理。 归档，删除。特别是以一个分区做为操作单元。
- 数据库管理。统计信息，vacuum, repack 操作等

## 注意事项

- 分区键选取，如表单的创建时间。
- 分区大小的划分。一个表多大时开始考虑分区。一个分区多大比较合适。（综合具体业务）
- 分区表数量控制。过多的分区表可能是一种灾难。可以考虑合并分区，归档数据。
- 默认分区
- 表结构更改对现有表结构的影响。更新父表结构对已有子表结构的影响。
- 索引操作，对子表无效
- 分区键更新
- 主键，唯一键约束。 全局还是子表有效。(唯一键+分区键),主表的主键,唯一键必须包含分区键。
- 新分区创建方式。比如按照月分区，下个月的子表是手动还是自动创建。自动创建对新插入数据的分区键时间需要严格验证。
- enable_partition_pruning 需要开启

## 使用限制

- 没有办法创建跨越所有分区的排除约束，只可能单个约束每个叶子分区。
- 分区表上的惟一约束（也就是主键）必须包括所有分区键列。存在此限制是因为PostgreSQL只能每个分区中分别强制实施唯一性。 


## 普通表转换为分区表

- pg 版本 < 12 利用pathman 可在线平滑转换
- pg 版本 >=12 原始方式 

思路：

 1 新建一张结构完全相同的表，
 
 2 将原表作为新表子表 

 3 修改对换表名 （过程加锁）


## 分区表示例 

- LIST 分区
```
CREATE TABLE tbl_list(
  id bigserial,
  ival int,
  cval char(1),
  dval timestamp default now(),
  primary key(id, ival)
) partition by list(ival);
create table tbl_list_0 partition of tbl_list for values in (0);
create table tbl_list_1_2 partition of tbl_list for values in (1,2);
create table tbl_list_default partition of tbl_list default;

```

- RANGE 分区
```
CREATE TABLE tbl_range(
  id bigserial,
  ival int,
  cval char(1),
  dval timestamp default now(),
  primary key(id, dval)
) partition by range(dval);
create table tbl_range_202001 partition of tbl_range for values from ('2020-01-01 00:00:00') to ('2020-02-01 00:00:00');
create table tbl_range_202002 partition of tbl_range for values from ('2020-02-01 00:00:00') to ('2020-03-01 00:00:00');
create table tbl_range_default partition of tbl_range default;

```

- HASH 分区  ，不能包含默认分区
```
CREATE TABLE tbl_hash(
  id bigserial,
  ival int,
  cval char(1),
  dval timestamp default now(),
  primary key(id, ival)
) partition by hash(ival);
create table tbl_hash_0 partition of tbl_hash for values WITH (MODULUS 3, REMAINDER 0);
create table tbl_hash_1 partition of tbl_hash for values WITH (MODULUS 3, REMAINDER 1);
create table tbl_hash_2 partition of tbl_hash for values WITH (MODULUS 3, REMAINDER 2);
```

