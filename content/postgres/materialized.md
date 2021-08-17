---
title: "物化视图"
date: 2021-07-21T15:43:34+08:00
draft: false
toc: false
categories: []
tags: []
---

## 物化视图

物化视图与普通视图的区别在于，物化视图是物理上真实存在的表。

## 物化视图的创建

```
 \h create materialized view 
Command:     CREATE MATERIALIZED VIEW
Description: define a new materialized view
Syntax:
CREATE MATERIALIZED VIEW [ IF NOT EXISTS ] table_name
    [ (column_name [, ...] ) ]
    [ USING method ]
    [ WITH ( storage_parameter [= value] [, ... ] ) ]
    [ TABLESPACE tablespace_name ]
    AS query
    [ WITH [ NO ] DATA ]
```

与creat table as 基本相同，但是物化视图不同于table 的是物化时候中的数据内容可以刷新。

## 物化视图的更新

```
postgres=# \h REFRESH 
Command:     REFRESH MATERIALIZED VIEW
Description: replace the contents of a materialized view
Syntax:
REFRESH MATERIALIZED VIEW [ CONCURRENTLY ] name
    [ WITH [ NO ] DATA ]

URL: https://www.postgresql.org/docs/12/sql-refreshmaterializedview.html
```

- 全量更新

全量更新锁表速度快

- 增量更新 （CONCURRENTLY）

增量更新做的操作是将当前视图表中的数据和query中的数据做一个join操作，然后才将差量做填充。

## 应用场景

对抽取数据结果集访问频率高，但是更新变化频率低。

对关注的数据结果集进行抽象为物化视图。方便后面应用的频繁读取。
