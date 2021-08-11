---
title: "Redis 持久化策略"
date: 2021-03-09T17:04:58+08:00
draft: false
toc: false
categories: ['redis','python']
tags: []
---

## 持久化的两种方式

- RDB 快照
- AOF 日志

## RDB  快照

 快照一次全量备份。
 
 特点： 保存时比较耗系统资源容易造成业务卡顿，恢复比较快。
 
 原理： 使用操作系统的多进程COW(COPY ON Write)机制来实现快照持久化

 命令： 堵塞 save ，非堵塞后台执行 bgsave 

 配置： 

```
save m n
#配置快照(rdb)促发规则，格式：save <seconds> <changes>
#save 900 1  900秒内至少有1个key被改变则做一次快照
#save 300 10  300秒内至少有300个key被改变则做一次快照
#save 60 10000  60秒内至少有10000个key被改变则做一次快照
#关闭该规则使用save “” 

dbfilename  dump.rdb
#rdb持久化存储数据库文件名，默认为dump.rdb

stop-write-on-bgsave-error yes 
#yes代表当使用bgsave命令持久化出错时候停止写RDB快照文件,no表明忽略错误继续写文件。

rdbchecksum yes
#在写入文件和读取文件时是否开启rdb文件检查，检查是否有无损坏，如果在启动是检查发现损坏，则停止启动。

dir "/etc/redis"
#数据文件存放目录，rdb快照文件和aof文件都会存放至该目录，请确保有写权限

rdbcompression yes
#是否开启RDB文件压缩，该功能可以节约磁盘空间
```

## AOF 日志

 AOF日志只记录对内存进行修改的指令。先执行指令再将AOF日志存盘。增量备份。

 特点： 开启后占用系统IO，会稍微降低性能。但是是顺序写，写性能很高。 日志文件会随着业务不断增加，需要定期重写日志。恢复的过程相当于重放日志的指令，如果间隔多大恢复慢。

 命令： 日志重写瘦身 bgrewriteaof

 配置： 

```
auto-aof-rewrite-min-size 64mb
#AOF文件最小重写大小，只有当AOF文件大小大于该值时候才可能重写,4.0默认配置64mb。

auto-aof-rewrite-percentage  100
#当前AOF文件大小和最后一次重写后的大小之间的比率等于或者等于指定的增长百分比，如100代表当前AOF文件是上次重写的两倍时候才重写。

appendfsync everysec
#no：不使用fsync方法同步，而是交给操作系统write函数去执行同步操作，在linux操作系统中大约每30秒刷一次缓冲。这种情况下，缓冲区数据同步不可控，并且在大量的写操作下，aof_buf缓冲区会堆积会越来越严重，一旦redis出现故障，数据
#always：表示每次有写操作都调用fsync方法强制内核将数据写入到aof文件。这种情况下由于每次写命令都写到了文件中, 虽然数据比较安全，但是因为每次写操作都会同步到AOF文件中，所以在性能上会有影响，同时由于频繁的IO操作，硬盘的使用寿命会降低。
#everysec：数据将使用调用操作系统write写入文件，并使用fsync每秒一次从内核刷新到磁盘。 这是折中的方案，兼顾性能和数据安全，所以redis默认推荐使用该配置。

aof-load-truncated yes
#当redis突然运行崩溃时，会出现aof文件被截断的情况，Redis可以在发生这种情况时退出并加载错误，以下选项控制此行为。
#如果aof-load-truncated设置为yes，则加载截断的AOF文件，Redis服务器启动发出日志以通知用户该事件。
#如果该选项设置为no，则服务将中止并显示错误并停止启动。当该选项设置为no时，用户需要在重启之前使用“redis-check-aof”实用程序修复AOF文件在进行启动。

appendonly no 
#yes开启AOF，no关闭AOF

appendfilename appendonly.aof
#指定AOF文件名，4.0无法通过config set 设置，只能通过修改配置文件设置。

dir /var/lib/redis
#RDB文件和AOF文件存放目录
```

## 4.0  混合持久化

混合持久化就是同时结合RDB持久化以及AOF持久化混合写入AOF文件。这样做的好处是可以结合 rdb 和 aof 的优点, 快速加载同时避免丢失过多的数据，缺点是 aof 里面的 rdb 部分就是压缩格式不再是 aof 格式，可读性差。

开启关闭配置 `aof-use-rdb-preamble` 

## 相关命令

```
aof文件检查
redis-check-aof /var/lib/redis/appendonly.aof

rdb文件检查
redis-check-rdb /var/lib/redis/dump.rdb

查看持久化信息
info Persistence

查看状态信息
info stats
```

