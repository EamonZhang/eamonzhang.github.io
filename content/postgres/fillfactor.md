---
title: "fillfactor 填充因子"
date: 2018-12-06T11:01:03+08:00
draft: false
---

#### 介绍

PostgreSQL每个表和索引的数据都是由很多个固定尺寸的页面存储（通常是 8kB，不过在编译服务器时[–with-blocksize]可以选择其他不同的尺寸）        
一个表的填充因子(fillfactor)是一个介于 10 和 100 之间的百分数。100(完全填充)是默认值。如果指定了较小的填充因子，INSERT 操作仅按照填充因子指定的百分率填充表页。每个页上的剩余空间将用于在该页上更新行，这就使得 UPDATE 有机会在同一页上放置同一条记录的新版本，这比把新版本放置在其它页上更有效。对于一个从不更新的表将填充因子设为 100 是最佳选择，但是对于频繁更新的表，较小的填充因子则更加有效。

PostgresSQL 使用[Heap-Only Tuple 技术](./postgres/hotupdate) 会在旧行与新行之间建立一个链表，这样一来就不需要更新索引了，索引项仍会指向旧行，通过链表可以找到新行。因此Heap-Only Tuple 的链表不能跨数据块。


#### 示例

```
create table t_fillfactor01(id int ,name varchar  , blog text ) WITH (fillfactor=70);
CREATE TABLE
new_test=# \d+ t_fillfactor01
                         Table "public.t_fillfactor01"
 Column |       Type        | Modifiers | Storage  | Stats target | Description 
--------+-------------------+-----------+----------+--------------+-------------
 id     | integer           |           | plain    |              | 
 name   | character varying |           | extended |              | 
 blog   | text              |           | extended |              | 
Options: fillfactor=70
```


#### 测试

```
/****************************************************************************************
    创建测试表
    test1设置fillfactor=100
    test2设置fillfactor=80
    drop table if exists  test1;
    drop table if exists  test2;
****************************************************************************************/ 
create table test1(
    objectid bigserial not null,                --唯一编号，主键
    name text not null,                         --名称
    describe text,                              --备注
    generate timestamptz default now() not null,--创建日期
    constraint pk_test1_objectid primary key(objectid)
)with (fillfactor=100); 

create table test2(
    objectid bigserial not null,                --唯一编号，主键
    name text not null,                         --名称
    describe text,                              --备注
    generate timestamptz default now() not null,--创建日期
    constraint pk_test2_objectid primary key(objectid)
)with (fillfactor=80); 

/****************************************************************************************
    创建随机生成中文字符函数
drop function if exists gen_random_zh(int,int);
****************************************************************************************/ 

create or replace function gen_random_zh(int,int)
    returns text
as $$
	select string_agg(chr((random()*(20901-19968)+19968 )::integer) , '')  from generate_series(1,(random()*($2-$1)+$1)::integer); $$ language sql; 

/****************************************************************************************
    导入测试数据
****************************************************************************************/ 
insert into test1(name)
  select gen_random_zh(8,32) from generate_series(1,10000); 

insert into test2(name)
    select gen_random_zh(8,32) from generate_series(1,10000);

/****************************************************************************************
    查看test1数据在页中的布局
****************************************************************************************/

select ctid,objectid from test1 limit 500;
略

select ctid,objectid from test2 limit 500;
略

---test1 --- fillfactor = 100
 select ctid from test1 where objectid = 93;
 ctid 
-------- 
(1,18) (1 row) 
update test1 set name=gen_random_zh(8,32) where objectid = 93; 
select ctid from test1 where objectid = 93; 
ctid 
---------- 
(133,31) (1 row) 

--test2 --- fillfactor = 80 
select ctid from test2 where objectid = 93;
ctid 
-------- 
(1,32) (1 row)
update test2 set name=gen_random_zh(8,32) where objectid = 93;
select ctid from test2 where objectid = 93; 
ctid 
-------- 
(1,58) (1 row)

--------------------- 
```

可以看到test1中因为填充率为100%,update后第一页中没有位置存储新的数据了,所以检查最大的页文件是否还有位置,如果有直接插入,如果没有则再新建一页后插入,在本例中跳过了132个页文件.

test2中因为填充率为80%,还有20%的空间可以存储数据,因此update后直接在历史数据所在的页后面插入数据.

#### fillfactor 的设置

fillfactor 的设置可直接影响hotupdate的比例， 通过wal日志的解析可以查看hotupdate的情况 [checkpoint](./postgres/checkpoint)
