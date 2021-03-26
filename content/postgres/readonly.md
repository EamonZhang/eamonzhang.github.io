---
title: "创建只读用户"
date: 2020-09-08T09:28:59+08:00
draft: false
---

```
1.创建一个用户名为readonly密码为ropass的用户
CREATE USER readonly WITH ENCRYPTED PASSWORD 'ropass';
 
2.用户只读事务
alter user readonly set default_transaction_read_only=on;
 
3.把所有库的语言的USAGE权限给到readonly
GRANT USAGE ON SCHEMA public to readonly;      
 
4.授予select权限(这句要进入具体数据库操作在哪个db环境执行就授予那个db的权)
 grant select on all tables in schema public to readonly;

```
