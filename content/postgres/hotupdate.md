---
title: "hot update"
date: 2021-01-14T13:49:11+08:00
draft: false
---

##### What is HOT

HOT是“Heap Only Tuple”（仅元组堆）的缩写, 用来提高update效率。

行的新版本和旧版本位于同一块中时，该行的外部地址（原始行指针）保持不变，利用hot link指针进行转发地址。索引不需要任何改动。

##### 前提条件

- 包含更新行的块中必须有足够的空间

- 在已修改值的任何列上均未定义索引

##### 生产应用

使用[fillfactor](./postgres/fillfactor)以获取HOT更新

##### 例子

建表
```
CREATE TABLE mytable (
   id  integer PRIMARY KEY,
   val integer NOT NULL
) WITH (autovacuum_enabled = off);
 
INSERT INTO mytable
SELECT *, 0
FROM generate_series(1, 235) AS n; 

```

8k page 物理分布
```
SELECT ctid, id, val
FROM mytable;
  ctid   | id  | val 
---------+-----+-----
 (0,1)   |   1 |   0
 (0,2)   |   2 |   0
 (0,3)   |   3 |   0
 (0,4)   |   4 |   0
 (0,5)   |   5 |   0
...
 (0,224) | 224 |   0
 (0,225) | 225 |   0
 (0,226) | 226 |   0
 (1,1)   | 227 |   0
 (1,2)   | 228 |   0
 (1,3)   | 229 |   0
 (1,4)   | 230 |   0
 (1,5)   | 231 |   0
 (1,6)   | 232 |   0
 (1,7)   | 233 |   0
 (1,8)   | 234 |   0
 (1,9)   | 235 |   0
(235 rows)
```

页内无足够剩余空间,跨页更新
```
postgres=# update mytable set val = 100 where id = 5;
UPDATE 1
postgres=# select ctid,* from mytable where id = 5;
  ctid  | id | val 
--------+----+-----
 (1,10) |  5 | 100
(1 行记录)

postgres=# select  n_tup_upd, n_tup_hot_upd from pg_stat_all_tables where relname = 'mytable';
 n_tup_upd | n_tup_hot_upd 
-----------+---------------
         1 |             0
(1 行记录)

```

页内有足够剩余空间，页内hot 更新
```
postgres=# update mytable set val = 100 where id = 230;
UPDATE 1
postgres=# select ctid,* from mytable where id = 230;
  ctid  | id  | val 
--------+-----+-----
 (1,11) | 230 | 100
(1 行记录)

postgres=# select  n_tup_upd, n_tup_hot_upd from pg_stat_all_tables where relname = 'mytable';
 n_tup_upd | n_tup_hot_upd 
-----------+---------------
         2 |             1
(1 行记录)
```

页内有足够空间，但是更新的字段包含索引的情况,没有发生hot 更新
```
postgres=# create index ON mytable (val );
CREATE INDEX
postgres=# update mytable set val = 100 where id = 231;
UPDATE 1
postgres=# select ctid,* from mytable where id = 231;
  ctid  | id  | val 
--------+-----+-----
 (1,12) | 231 | 100
(1 行记录)

postgres=# select  n_tup_upd, n_tup_hot_upd from pg_stat_all_tables where relname = 'mytable';
 n_tup_upd | n_tup_hot_upd 
-----------+---------------
         3 |             1
(1 行记录)

```

[more](https://www.modb.pro/db/33457)
