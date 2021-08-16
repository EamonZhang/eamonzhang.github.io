---
title: "Redis Cluster"
date: 2021-03-09T17:00:05+08:00
draft: false 
toc: true
categories: ['redis']
tags: []
---

## 主从复制

原理说明参考 https://www.cnblogs.com/daofaziran/p/10978628.html

#### 基本原理

主要是Redis没有wal日志机制。aof是先执行命令再记录。主从同步不是依赖aof日志。

通过单独的进程完成主从的同步。

初始时全量复制，SYNC。 然后进行增量复制PSYNC。在主库内存中维护一个偏移量`master run id` 。 当断开重新连接上比较偏移量，尝试增量同步，如果增量失败进行全量同步。

#### 从库只读

Redis 从库支持写操作。 容易产生冲突,可通过配置进行设置

```
replica-read-only yes
```

#### 无盘复制

当新添加从节点的时候，会在主库先拷贝一份全量数据放在本地磁盘，如果主库磁盘有限制或IO增大可能对业务造成影响。可选择无盘复制，主从将直接通过socket通信。

```
repl-diskless-sync

repl-diskless-sync-delay
```

#### 多个从库同步成功后主可写

为了增加整体的数据一致性。可设定N个从库同步成功后主库可写功能。

```
min-slaves-to-write（最小从服务器数）
min-slaves-max-lag（从服务器最大确认延迟）
```

#### 级联主从

Redis 支持级联复制模式。从库的复制对主库会有一定的性能影响。

为了消除或减少复制时对主库的影响。可采取级联复制

#### 主从配置

配置文件中加入，或执行命令
```
slaveof  # 旧版本命令
replicaof # 新版本命令
```

## 状态查看

查看命令
```
INFO replication
```

