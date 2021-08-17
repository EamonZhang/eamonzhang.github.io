---
title: "快速生成大量数据"
date: 2018-12-14T13:13:57+08:00
draft: false
---

#### 在数据库中快速生成1w条数据，或测试数据库的写入性能。

```
创建数据库表
postgres=# create table tbl(id int, info text, crt_time timestamp);
CREATE TABLE 
```

##### 方法一 generate_series

``` 
查看方法函数
postgres=# \df generate_series 
                                                                   函数列表
  架构模式  |      名称       |           结果数据类型            |                            参数数据类型                            | 类型 
------------+-----------------+-----------------------------------+--------------------------------------------------------------------+------
 pg_catalog | generate_series | SETOF bigint                      | bigint, bigint                                                     | 常规
 pg_catalog | generate_series | SETOF bigint                      | bigint, bigint, bigint                                             | 常规
 pg_catalog | generate_series | SETOF integer                     | integer, integer                                                   | 常规
 pg_catalog | generate_series | SETOF integer                     | integer, integer, integer                                          | 常规
 pg_catalog | generate_series | SETOF numeric                     | numeric, numeric                                                   | 常规
 pg_catalog | generate_series | SETOF numeric                     | numeric, numeric, numeric                                          | 常规
 pg_catalog | generate_series | SETOF timestamp without time zone | timestamp without time zone, timestamp without time zone, interval | 常规
 pg_catalog | generate_series | SETOF timestamp with time zone    | timestamp with time zone, timestamp with time zone, interval       | 常规
(8 行记录)

postgres=# insert into tbl select id, md5(random()::text), clock_timestamp() from generate_series(1,10000) t(id);  
INSERT 0 10000  
```
#### 方法二 pgbench  

```
vi test.sql  
\set id random(1,10000000)  
insert into tbl values (:id, md5(random()::text), now());  

pgbench -M prepared -n -r -f ./test.sql -P 1 -c 32 -j 32 -t 1000  

```

#### 方法三 do

```
postgres=# do language plpgsql $$  
declare  
begin  
  for i in 1..100 loop  
    insert into tbl select mod(id,i), md5(random()::text), clock_timestamp() from generate_series(1,1000) t(id);  
  end loop;  
end;  
$$;  
DO 

``` 
