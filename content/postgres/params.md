---
title: "数据库参数"
date: 2018-11-27T09:57:27+08:00
draft: false
toc: true
categories: ["postgres"]
tags: [""]
---


##  性能参数

[pgtune](https://github.com/le0pard/pgtune) [pgconfig](https://www.pgconfig.org/)  

##  [日志参数](postgres/log/)  

## [更多参数详解](https://postgresqlco.nf/zh/doc/param/)

## 管理
```
listen_addresses = "*"             # 连接访问控制，哪些ip可以访问， * 全部。 结合pg_hba.conf , iptables设置。
superuser_reserved_connections = 3 # 预留给超级管理员的连接数。
port = 5432                        # 默认访问端口
wal_keep_segments = 1024           # wal 日志保存数量
```
## wal日志

```
wal_log_hints = on 
full_page_writes = on
```

## 成本因子 

```
# - Planner Cost Constants -
#seq_page_cost = 1.0                    # measured on an arbitrary scale 顺序扫描
random_page_cost = 1.1                  # same scale as above            随机扫描。HDD 4 ;SSD 1.1; 由于SSD没有磁盘寻道时间，顺序扫描和随机扫描的差距不是那么大。比例设置的相近即可。 
#cpu_tuple_cost = 0.01                  # same scale as above
#cpu_index_tuple_cost = 0.005           # same scale as above
#cpu_operator_cost = 0.0025             # same scale as above
#parallel_tuple_cost = 0.1              # same scale as above
#parallel_setup_cost = 1000.0   # same scale as above
#min_parallel_table_scan_size = 8MB
#min_parallel_index_scan_size = 512kB
effective_cache_size = 666666          # 系统总内存减去数据库shared_buffer减去其他应用占有的内存。 理解为数据可加载到内存的大小。
```

## TCP 连接

Linux 中tcp默认连接超时时间2小时,如果2个小时没有数据包则认为该连接为空闲状态，系统自动关闭。

```
# - TCP Keepalives -
# see "man 7 tcp" for details

#tcp_keepalives_idle = 60                # TCP_KEEPIDLE, in seconds;
                                        # 0 selects the system default
#tcp_keepalives_interval = 10            # TCP_KEEPINTVL, in seconds;  发个心跳数据包，告诉系统我没有空闲
                                        # 0 selects the system default
#tcp_keepalives_count = 6               # TCP_KEEPCNT;
                                        # 0 selects the system default
```

## 检查点checkpoint
具体根据磁盘的吞吐量进行设置 https://yq.aliyun.com/articles/582847
```
shared_buffers = 64GB                  # 1/4 内存 如果不使用huge page建议不要超过32GB   
checkpoint_timeout = 30min              # range 30s-1d  
max_wal_size = 124GB          # 2*shared_buffers  
min_wal_size = 32GB           # shared_buffers * 1/2  
checkpoint_completion_target = 0.9 
``` 

## 垃圾回收autovacuum
```
autovacuum_work_mem = -1 # autovacuum所能使用的内存大小，当其为-1时，使用maintenance_work_mem参数的值，值越大，使用的内存越多
autovacuum = on # 是否打开autovacuum
autovacuum_max_workers =3 # 最多能够有多少个autovaccum进程运行，值越大，使用的内存越多
autovacuum_naptime = 1min  # autovacuum进程间隔多长时间对表进行是否需要autovacuum操作
autovacuum_vacuum_threshold = 50 # 当表上dml操作达到多少行时执行autovacuum操作
autovacuum_analyze_threshold = 50  # 当表上dml操作达到多少行时执行autovacuum analyze操作
autovacuum_vacuum_scale_factor = 0.2 # 当表上dml操作达到多少比例时执行autovacuum操作
autovacuum_analyze_scale_factor = 0.1  # 当表上dml操作达到多少比例时执行autovacuum analyze操作
autovacuum_vacuum_cost_limit = -1  # autovacuum 的cost超过此值时，vacuum会sleep一段时间，使用vacuum_cost_limit参数的值，值越大对系统IO压力越大
```

## 并行计算

```
1. 控制整个数据库集群同时能开启多少个work process，必须设置。
max_worker_processes = 128              # (change requires restart)  

2. 控制一个并行的EXEC NODE最多能开启多少个并行处理单元，同时还需要参考表级参数parallel_workers，或者PG内核内置的算法，根据表的大小计算需要开启多少和并行处理单元。  
实际取小的。
max_parallel_workers_per_gather = 16    # taken from max_worker_processes

3. 计算并行处理的成本，如果成本高于非并行，则不会开启并行处理。
#parallel_tuple_cost = 0.1              # same scale as above
#parallel_setup_cost = 1000.0   # same scale as above

4. 小于这个值的表，不会开启并行。
#min_parallel_relation_size = 8MB

5. 告诉优化器，强制开启并行。
#force_parallel_mode = off

6. 表级参数，不通过表的大小计算并行度，而是直接告诉优化器这个表需要开启多少个并行计算单元。
parallel_workers (integer)

alter table t_table set(parallel_workers = 4)
```

## 同步提交synchronous_commit

同步提交参数, 控制事务提交后返回客户端是否成功的策略 
可选值为:on, remote_write, local, off

on
```
1 为on且没有开启同步备库的时候,会当wal日志真正刷新到磁盘永久存储后才会返回客户端事务已提交成功, 
2 当为on且开启了同步备库的时候(设置了synchronous_standby_names),必须要等事务日志刷新到本地磁盘,并且还要等远程备库也提交到磁盘才能返回客户端已经提交.
```
off
```
写到缓存中就会向客户端返回提交成功，但也不是一直不刷到磁盘，延迟写入磁盘,延迟的时间为最大3倍的wal_writer_delay参数的(默认200ms)的时间,所有如果即使关闭synchronous_commit,
也只会造成最多600ms的事务丢失,此事务甚至包括已经提交的事务（会丢数据）,但数据库确可以安全启动,不会发生块折断,只是丢失了部分数据,但对高并发的小事务系统来说,性能来说提升较大。
```
remote_write
```
当事务提交时,不仅要把wal刷新到磁盘,还需要等wal日志发送到备库操作系统(但不用等备库刷新到磁盘),因此如果备库此时发生实例中断不会有数据丢失,因为数据还在操作系统上,
而如果操作系统故障,则此部分wal日志还没有来得及写入磁盘就会丢失,备库启动后还需要想主库索取wal日志。
```
local
```
当事务提交时,仅写入本地磁盘即可返回客户端事务提交成功,而不管是否有同步备库
如果没有设置同步备库,则 on/remote_write/local都是一样的,仅等待事务刷新到本地磁盘.
```

此参数还可以局部设置,当有临时批量任务时可以这样设置: 
```
SET LOCAL synchronous_commit TO OFF; 
```
这样局部事务可向备库异步的方式同步，而其他重要的事务以同步的方式向备库同步。

## 修改

```
postgresql.conf 服务器启动时默认读取的配置

postgresql.auto.conf 优先级高于postgresql.conf 9.4后引入,对标oracle sfile pfile 。　文件不能修改,需要通过ALTER SYSTE　修改，ALTER SYSTE　RESET | DEFAULT 删除
```

## 策略　

```
postgresql.conf 参数为默认值,不做修改，优化参数通过　postgresql.auto.conf 修改，一目了然。(个人习惯)
```

## 查看

```
SELECT name,setting,vartype,boot_val,min_val,max_val,reset_val FROM pg_settings;

show all;
```

## work_mem

这些内存大小被用来完成内部排序与哈希表操作。
如果未分配足够内存，会导致物理I/O。
work_mem这个值是针对每个session的，所以不能设置的过大。

## 实验
```
创建测试表
postgres=# create table myt (id serial);  
CREATE TABLE

插入测试数据  
postgres=# insert into myt select generate_series(1,1000000);  
INSERT 0 1000000  

设置当前session work_mem

postgres=#set work_me '64kb';
SET  
postgres=# show work_mem;  
 work_mem  
----------  
 64kB  
(1 row)

查看临时文件占用情况
select temp_files, temp_bytes from pg_stat_database
 temp_files | temp_bytes  
------------+------------  
          0 |          0  
(1 row)  

执行测试
select * from (select * from myt order by id) t limit 1000; 

再次查看临时文件占用情况
select temp_files, temp_bytes from pg_stat_database
 temp_files | temp_bytes
------------+------------
          1 |   14016512 
(1 row)

设置当前session work_mem

postgres=#set work_mem = '16MB';  
SET

执行测试
select * from (select * from myt order by id) t limit 1000;

再次查看临时文件占用情况
select temp_files, temp_bytes from pg_stat_database
 temp_files | temp_bytes
------------+------------
          1 |   14016512
```
没有新增临时文件 , 说明work_mem充足


## maintainance_work_mem

主要用于analyzing，vacuum，create index, reindex等。

如需进行如上操作时请适当调整maintainance_work_mem 值，提高效率

## 实验
方法与上面类似，在统计表中观察临时文件使用情况。




