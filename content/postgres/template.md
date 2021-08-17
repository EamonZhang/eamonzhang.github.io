---
title: "模板数据库"
date: 2018-11-30T09:52:43+08:00
draft: false
---

#### 模板数据库
模板数据库就是创建新database时，PostgreSQL会基于模板数据库制作一份副本，其中会包含所有的数据库设置和数据文件。
PostgreSQL安装好以后会默认附带两个模板数据库：template0和template1。

- template0 干净版，任何时候不要修改
- template1 默认版，如果创建数据库时不指定模板将默认模板指定为template1


#### 区别

- template1 可以连接并创建对象，template0 不可以连接

- 使用 template1 模板库建库时不可指定新的 encoding 和 locale，而 template0 可以

#### 使用


使用方法　
```

 create database mytemplate template template1;

 create database mydatabase template mytemplate;

```


设置自己的模板　mytemplate

在自己的模板中需改信息，比如　添加必备的扩展，统计函数库等。

其他数据库在创建时使用自定的模板



