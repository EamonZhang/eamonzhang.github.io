---
title: "数据库试图之 pg_stat_bgwriter"
date: 2021-03-31T09:32:17+08:00
draft: false
toc: false
categories: ["postgres"]
tags: []
---

## 介绍

 
可查看 backgroud writer， [checkpoint](/postgres/checkpoint) ，backend 进程刷写 Shared buffer 情况视图

pg数据库在写入时先在内存中更新shared buffer ，然后有checkpoint机制将脏数据刷写到磁盘。

## 视图

```
 select * from pg_stat_bgwriter ;
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 64017
checkpoints_req       | 458
checkpoint_write_time | 9608302902
checkpoint_sync_time  | 1189286
buffers_checkpoint    | 578367652
buffers_clean         | 329022
maxwritten_clean      | 2353
buffers_backend       | 29802728
buffers_backend_fsync | 0
buffers_alloc         | 83826180
stats_reset           | 2020-08-20 19:41:20.491551+08
```

负责将shared buffer 中的内容刷新到磁盘主要有三个进程完成

- checkpoint 
- bgwriter
- backend

视图内容主要也是针对这三个进程的统计信息

#### checkpoint
```
checkpoints_timed 周期性进行checkpoint的次数    
checkpoints_req   周期以外发生checkpoint的次数
checkpoint_write_time 刷写耗时
checkpoint_sync_time  同步耗时
buffers_checkpoint 写入量
```

#### bgwriter

```
buffers_clean bgwriter 写入量
maxwritten_clean bgwriter 一次写入量超过bgwriter_lru_maxpages停止次数
```

#### 

```
buffers_backend       backend 写入量
buffers_backend_fsync 同步写入次数
```


## 理想状态

大部分的脏数据都是bgwriter写回存储的，少量的脏数据是checkpointer写入的，更少的数据是backend写入的。因为backend写入数据成本非常高。

checkpoint 的写入基本都是周期性的写入。


