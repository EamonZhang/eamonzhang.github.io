---
title: "数据库年龄"
date: 2020-01-07T09:47:18+08:00
draft: false
---

##### 背景

数据库的事务标识符使用的是32位的,最大可表示42个亿。当前事务的数据在20亿个事务之后将变的不可见。为了解决这个问题（回卷），Postgres引入了一个冻结事务标识的概念。
并实现了名为freeze的冻结过程。


##### 冻结过程

两种模式

- 惰性模式

- 迫切模式

惰性模式回跳过页中所有的数据都位可见的数据库块（由数据库中的vm可见性映射）

迫切模式会扫描所有的页，检查表中的所有元组。并可能删除不必要的clog文件与页面。

改进的迫切模式，会跳过页面中所有的元组都已被冻结过的页面

首先介绍几个数据库值

```
 -- 当前事务号
 select txid_current();

 -- 记录事务号
 select xmax,xmin ,* from table_name where xxxx;

 -- 表年龄， 表中最老行的事务号
 select age(relfrozenxid) from pg_class where relname = table_name;

 -- database 年龄
 select datname , age(datfrozenxid) from pg_database ;

 -- 数据配置
 show vacuum_freeze_min_age ; -- 默认值5千万

 show vacuum_freeze_table_age ; -- 默认值1.5亿

 show autovacuum_freeze_max_age ; -- 默认值2亿

 show autovacuum_naptime ; -- 默认值1 分钟
```
 
##### 触发条件

当前年龄大于5千万时 惰性模式
当前库年龄大于1.5亿时 迫切模式

冻结后修改表和库的 relfrozenxid，datfrozenxid 值。

##### 手动冻结

```
 vacuum freeze 
```

由于冻结的过程会占用数据库系统的资源。可根据当前数据的年龄在业务低峰期进行手动冻结，降低对业务的影响。


