---
title: "误操作闪回"
date: 2021-01-11T17:19:06+08:00
draft: false
---

##### 原理

利用mvcc原理，数据在删除或更新时只是标记为删除。当没有发生过gc时历史数据仍然存在。只是对当前事务不可见。

通过修改当前事务号为误操作前的事务号就可以看到历史数据。

例如 T1 （添加数据） T2 - T8（其他操作） T9（删除了T1加入的数据）T10... (其他操作)。 自需要将当前事务号修改为T1之后T9之前的任何时刻都可以看到T1 加入的数据。

前提：误操作表在误操作后没有发生过gc

```
select  last_vacuum , last_autovacuum  from pg_stat_all_tables where = ?;
```
修改方法：利用pg_resetwal工具重置当前事务号

注意： 尽快将找到的数据导出，随着当前数据库事务号增加，数据将再次不可见，T10 也会同样不可见。

##### 示例

通过pg_xlogdump找到误删的事务号（xid），停止数据库，然后重置xlog，启动数据库，数据就是重置的xid位置可见

模拟事故现场
```
-- 创建测试表
postgres=# create table reback_t (i int);
postgres=# select txid_current();
 txid_current 
--------------
     26913040
(1 行记录)

-- 模拟业务插入数据 
postgres=# insert into reback_t values (1);
INSERT 0 1
postgres=# insert into reback_t values (2);
INSERT 0 1
postgres=# insert into reback_t values (3);
INSERT 0 1
postgres=# insert into reback_t values (4);
INSERT 0 1
postgres=# select txid_current();
 txid_current 
--------------
     26913045
(1 行记录)

postgres=# insert into reback_t values (5);
INSERT 0 1
postgres=# insert into reback_t values (6);
INSERT 0 1
postgres=# insert into reback_t values (7);
INSERT 0 1
postgres=# insert into reback_t values (8);
INSERT 0 1
postgres=# insert into reback_t values (9);
INSERT 0 1
postgres=# insert into reback_t values (10);
INSERT 0 1
postgres=# select txid_current();
 txid_current 
--------------
     26913052
(1 行记录)

-- 误删除数据,事故点 
postgres=# delete from reback_t where i < 4;
DELETE 3
-- 在线业务继续
postgres=# insert into reback_t values (11);
INSERT 0 1
postgres=# insert into reback_t values (12);
INSERT 0 1
postgres=# insert into reback_t values (13);
INSERT 0 1
postgres=# select * from reback_t ;
 i  
----
  4
  5
  6
  7
  8
  9
 10
 11
 12
 13
(10 行记录)

postgres=# \q

```
```
停服闪退
[root@pg-d data]# systemctl stop  postgresql-10

回退到指定事务号
[root@pg-d data]# su postgres -c "/usr/pgsql-10/bin/pg_resetwal -x 26913047 -D /var/lib/pgsql/10/data/"
Write-ahead log reset

建议使用 --single 维护模式启动数据库
```

```
查看回退效果, 1,2 又可见
postgres=# select * from reback_t ;
 i 
---
 1
 2
 3
 4
 5
(5 行记录)

事务号 +1
postgres=# select txid_current();
 txid_current 
--------------
     26913047
(1 行记录)

postgres=# select * from reback_t ;
 i 
---
 1
 2
 3
 4
 5
 6
(6 行记录)
-- 其他操作 , 事务继续向前。。。
postgres=# insert into reback_t values (21);
INSERT 0 1
postgres=# select * from reback_t ;
 i  
----
  1
  2
  3
  4
  5
  6
  7
  8
 21
(9 行记录)
-- 当事务号增长到事故点26913053时，事故再次重现
postgres=# select * from reback_t ;
 i
----
  3
  4
  5
  6
  7
  8
 21
(7 行记录)
```

```
-- 事务真相
postgres=# select xmin,xmax,* from reback_t ;
   xmin   | xmax | i  
----------+------+----
 26913044 |    0 |  4
 26913046 |    0 |  5
 26913047 |    0 |  6
 26913048 |    0 |  7
 26913049 |    0 |  8
 26913050 |    0 |  9
 26913051 |    0 | 10
 26913054 |    0 | 11
 26913055 |    0 | 12
 26913049 |    0 | 21

```

思考 trunce 后是否能够闪回

```
postgres=# select txid_current();
 txid_current 
--------------
     26913056
(1 行记录)

postgres=# truncate reback_t ;
TRUNCATE TABLE
postgres=# \q
 
#systemctl stop  postgresql-10
 
#su postgres -c "/usr/pgsql-10/bin/pg_resetwal -x 26913050 -D /var/lib/pgsql/10/data/"
Write-ahead log reset

# systemctl start  postgresql-10
# psql 
psql (12.5, 服务器 10.13)
输入 "help" 来获取帮助信息.

postgres=# select xmin,xmax,* from reback_t ;
   xmin   |   xmax   | i  
----------+----------+----
 26913041 | 26913053 |  1
 26913042 | 26913053 |  2
 26913043 | 26913053 |  3
 26913044 |        0 |  4
 26913046 |        0 |  5
 26913047 |        0 |  6
 26913048 |        0 |  7
 26913049 |        0 |  8
 26913049 | 26913056 | 21
(9 行记录)
```

封侯非我意，我愿海波平。
