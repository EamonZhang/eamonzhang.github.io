---
title: "pg_rman 备份恢复数据库"
date: 2021-03-09T13:35:31+08:00
draft: false
---

##### 适用场景

PG_RMAN 基于本地数据拷贝的方式，要求与数据库需要安装在同一个机器节点上。

适用于项目初期，对数据库的规划处于初级阶段。实体机不充分的情况是个很好的选择。

数据库使用ssd盘，备份磁盘采用企业sata大盘。或nfs网盘等。

PG_RMAN 支持全备份，增量备份，备份验证，保留策略等

应用软件包地址
https://github.com/ossc-db/pg_rman/releases

###### 基本用法

```
-- 初始化
/usr/pgsql-13/bin/pg_rman -D /var/lib/pgsql/13/data/  -B /data/backup/ init

-- 在/data/backup 目录下会产生如下目录结构
backup 
pg_rman.ini
system_identifier
timeline_history

-- 全备份
pg_rman backup -B /pgdata/backup -D /var/lib/pgsql/13/data/  -b full  -h 127.0.0.1 -p 5432 -U backup -d postgres

-- 验证
pg_rman validate

-- 详情查看
pg_rman show detail

-- 增量备份
pg_rman backup -B /pgdata/backup -D /var/lib/pgsql/13/data/  -b incremental  -h 127.0.0.1 -p 5432 -U backup -d postgres

```

设置保留策略
```
vi pg_rman.ini 

KEEP_ARCLOG_DAYS = 7
KEEP_DATA_DAYS = 7
KEEP_SRVLOG_DAYS = 7

```

```
-- 恢复
pg_rman restore -B /pgdata/backup -D /var/lib/pgsql/13/data/ 

数据恢复后 数据库可能处于pg_wal_replay_resume() 的状态,在数据库执行完 pg_wal_replay_resume 后数据库就可以正常工作
```
