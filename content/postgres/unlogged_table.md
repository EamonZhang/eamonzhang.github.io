---
title: "unlogged table"
date: 2021-01-12T10:21:36+08:00
draft: false
---

##### 介绍

在写数据的时候不记录wal的表。

在意外发生时表中的数据被trunce 。如断电、 主进程kill 、scrash 等。

正常关闭重启数据库时数据不会丢失。

优点： 提高写入效率

不足： 数据安全性不能得到保障。 由于没有wal 流复制从库不能同步

应用场景： 

数据可丢失，如频繁更新，只保留最后状态信息的表。

导入表数据，后将表改为正常表。


##### 使用

```
-- 创建unlogged table,与创建普通的表类似。加个unlogged 关键字
postgres=# create unlogged table ult (id int,name text);
CREATE TABLE
postgres=# \d+ ult 
                      不记录日志的表 "public.ult"
 栏位 |  类型   | 校对规则 | 可空的 | 预设 |   存储   | 统计目标 | 描述 
------+---------+----------+--------+------+----------+----------+------
 id   | integer |          |        |      | plain    |          | 
 name | text    |          |        |      | extended |          | 


-- 将普通表与unlogged table 之间转换
postgres=# alter table ult set logged ;
ALTER TABLE
postgres=# \d+ ult 
                          数据表 "public.ult"
 栏位 |  类型   | 校对规则 | 可空的 | 预设 |   存储   | 统计目标 | 描述 
------+---------+----------+--------+------+----------+----------+------
 id   | integer |          |        |      | plain    |          | 
 name | text    |          |        |      | extended |          | 

postgres=# alter table ult set unlogged ;
ALTER TABLE
postgres=# \d+ ult 
                      不记录日志的表 "public.ult"
 栏位 |  类型   | 校对规则 | 可空的 | 预设 |   存储   | 统计目标 | 描述 
------+---------+----------+--------+------+----------+----------+------
 id   | integer |          |        |      | plain    |          | 
 name | text    |          |        |      | extended |          | 

```
