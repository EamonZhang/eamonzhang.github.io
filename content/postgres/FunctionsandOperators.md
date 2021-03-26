---
title: "方法和函数"
date: 2020-04-13T16:15:51+08:00
draft: false
---

#### 条件表达式
https://www.postgresql.org/docs/10/functions-conditional.html

postgresql支持CASE,COALESCE,NULLIF,GREATEST,LEAST条件表达式，使用它们有时候可以简化许多功能实现。

##### CASE

CASE类似其他语言中的if/else等，当符合不同条件时则进行不同的运算

tbl_001表
```
create table tbl_001(id int,name varchar(32),sex varchar(1));

insert into tbl_001 values(1,'张三','m'),(2,'李四','m'),(3,'王五','f');
```

测试

```
简单应用
postgres=# select case when sex = 'm' then '男' when sex = 'f' then '女' else 'O'  end as sex from tbl_001 ;
 sex 
-----
 男
 男
 女
(3 rows)

统计男女人数
postgres=# select count(sex) as 男 from tbl_001 where sex = 'm';
 男 
----
  2
(1 row)

postgres=# select count(sex) as 女 from tbl_001 where sex = 'f';
 女 
----
  1
(1 row)

使用case 一条搞定
select sum(case when sex = 'm' then 1 else 0 end) as 男, sum(case when sex = 'f' then 1 else 0 end) as 女 from tbl_001 ;
 男 | 女 
----+----
  2 |  1
(1 row)

```

#####  COALESCE

```
COALESCE(value [, ...])
```
返回第一个非null

```
postgres=# select coalesce(null,null,1,2,3);
 coalesce 
----------
        1
(1 row)

postgres=# select coalesce(null,null,'a','b','c');
 coalesce 
----------
 a
(1 row)


select coalesce(extract(epoch from max(age(now(), query_start))), 0) from pg_stat_activity where wait_event is not null;

```

##### NULLIF

```
NULLIF(value1, value2)
```

value1 和 value2 相等返回null 否则返回 value1

```
postgres=# select nullif(1,1),nullif(1,2);
 nullif | nullif 
--------+--------
        |      1
(1 row)
```

##### GREATEST and LEAST

分别返回最大和最小值

```
postgres=# select greatest(1,2,3),greatest('a','b','c');
 greatest | greatest 
----------+----------
        3 | c
(1 row)

postgres=# select least(1,2,3),least('a','b','c');
 least | least 
-------+-------
     1 | a
(1 row)
```

###### 时间类型


纪元，utc时间epoch
```
# t
postgres=# select extract(epoch from now());
    date_part     
------------------
 1586846074.40049
(1 row)

postgres=# select extract(epoch from timestamp without time zone '1970-01-01 01:00:00');
 date_part 
-----------
      3600
(1 row)

postgres=# SELECT TIMESTAMP WITH TIME ZONE 'epoch' + 1586846074.40049 * INTERVAL '1 second' as tsp;
             tsp              
------------------------------
 2020-04-14 14:34:34.40049+08
(1 row)
```

时区
```
#当前时区
postgres=# show timezone;
 TimeZone 
----------
 PRC
(1 row)

#系统支持的时区
postgres=# select * from pg_timezone_names; 

#时区
postgres=# select now()::timestamp with time zone, now()::timestamp without time zone;
              now              |            now             
-------------------------------+----------------------------
 2020-04-14 15:44:39.501691+08 | 2020-04-14 15:44:39.501691
(1 row)

#时区转换
postgres=# select '2020-04-14 09:07:30.816885+08' at time zone 'prc';
          timezone          
----------------------------
 2020-04-14 09:07:30.816885
(1 row)

postgres=# select '2016-02-03 09:07:30.816885+08' at time zone 'pst';
          timezone          
----------------------------
 2016-02-02 17:07:30.816885
```
没有时区代表的是绝对时间，absolute timestamp，即 UTC (UTC+0) 时间。

带着时区的代表相对时间，relative timestamp，即当地时间，如北京的当地时间是 UTC+8 的时间。

使用的一个最佳实践是时间类型都设为 timestamp with time zone 类型，只有在根据 timestamp 进行 partition 时才使用 timestamp without time zone 类型，

因为 partition 必须使用 immutable 数据 (即在任何情况下数据取出来都一样)，而 timestamp with time zone 的数据值与 postgres 配置的 timezone 有关。

这两种数据类型的区别是:

以当地时间存储数据到 timestamp with time zone 类型的字段时，postgres 底层会以 UTC 时间存储，展示数据时会根据 postgres 设置的 timezone 显示为当时时间。

以当地时间存储数据到 timestamp without time zone 类型的字段时，postgres 底层以输入的数据进行存储，展示时会原样展示，与 postgres 设置的时区无关。

时间戳加减
```
postgres=# select date '2016-02-02 10:00:00'+ interval '10 minutes'; 
```

时间戳格式化
```
postgres=# select to_char(now(),'YYYY-MM-DD hh24:mi:ss');
       to_char       
---------------------
 2020-04-14 16:14:29
(1 row)

postgres=# select to_timestamp('2020-04-14 16:14:29','YYYY-MM-DD hh24:mi:ss');
      to_timestamp      
------------------------
 2020-04-14 16:14:29+08
(1 row)
```

时间比较
```
select current_date <= to_date('2018-03-12 18:47:35','yyyy-MM-dd hh24:mi:ss');

select current_timestamp <= to_timestamp('2018-03-12 18:47:35','yyyy-MM-dd hh24:mi:ss');
```

```
--创建随机日期时间函数       
CREATE OR REPLACE FUNCTION rand_date_time(start_date date, end_date date)
 RETURNS TIMESTAMP AS $$  
DECLARE  
    interval_days integer;  
    random_seconds integer;  
    random_dates integer;  
    random_date date;  
    random_time time;
BEGIN  
    interval_days := end_date - start_date;  
    random_dates:= trunc(random()*interval_days);
    random_date := start_date + random_dates; 
    random_seconds:= trunc(random()*3600*24); 
    random_time:=' 00:00:00'::time+(random_seconds || ' second')::INTERVAL;
    RETURN random_date +random_time;  
END;   
$$  
LANGUAGE plpgsql;
```

###### JSON 类型

postgresql支持两种json数据类型：json和jsonb，而两者唯一的区别在于效率,json是对输入的完整拷贝，使用时再去解析，所以它会保留输入的空格，重复键以及顺序等。

而jsonb是解析输入后保存的二进制，它在解析时会删除不必要的空格和重复的键，顺序和输入可能也不相同。使用时不用再次解析。

两者对重复键的处理都是保留最后一个键值对。效率的差别：json类型存储快，使用慢，jsonb类型存储稍慢，使用较快。

```
postgres=#  SELECT '{"bar": "baz", "balance":      7.77, "active":false}'::json;
                         json                         
------------------------------------------------------
 {"bar": "baz", "balance":      7.77, "active":false}
(1 row)

postgres=#  SELECT '{"bar": "baz", "balance":      7.77, "active":false}'::jsonb;
                      jsonb                       
--------------------------------------------------
 {"bar": "baz", "active": false, "balance": 7.77}
(1 row)

```

测试表
```
create table api(jdoc jsonb);

insert into api values('{
"guid": "9c36adc1-7fb5-4d5b-83b4-90356a46061a",
"name": "Angela Barton",
"is_active": true,
"company": "Magnafone",
"address": "178 Howard Place, Gulf, Washington, 702",
"registered": "2009-11-07T08:53:22 +08:00",
"latitude": 19.793713,
"longitude": 86.513373,
"tags": [
"enim",
"aliquip",
"qui"
]}');
```

```
postgres=# SELECT jdoc->'guid', jdoc->'name' FROM api WHERE jdoc @> '{"company": "Magnafone"}';
                ?column?                |    ?column?     
----------------------------------------+-----------------
 "9c36adc1-7fb5-4d5b-83b4-90356a46061a" | "Angela Barton"
```

jsonb缺省的GIN操作符类支持使用@>、?、?&和?|操作符查询，在api的jdoc上创建一个gin索引。
```
test=# CREATE INDEX idxgin ON api USING gin (jdoc);
CREATE INDEX
```

json和jsonb的操作符

https://www.postgresql.org/docs/9.6/functions-json.html


##### 数组函数和操作符

http://postgres.cn/docs/11/functions-array.html
