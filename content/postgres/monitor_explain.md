---
title: "数据库监控指标"
date: 2020-11-20T14:46:54+08:00
draft: false
---

#### 实体机

- 硬盘空间
- cup利用率
- 内存利用率
- IO
- 网络带宽
- tcp连接情况
- 温度

##### 数据库年龄

```
 -- 数据库database 年龄
 select datname,age(datfrozenxid),pg_size_pretty(pg_database_size(oid)) from pg_database order by age(datfrozenxid) desc limit 10 ;
 
 -- 表年龄
 select relname,age(relfrozenxid), pg_size_pretty(pg_table_size(oid)) from pg_class where relkind in ('t','r') order by age(relfrozenxid) desc limit 10;

说明： 当age到达2亿（默认）时触发自动回卷，期间会大量占用系统资源。提前做好监控避免在业务高峰时发生。可在库级别操作，也可在表基本操作。

VACUUM ANALYZE VERBOSE ;
```

##### 垃圾回收

```
-- 表空间膨胀率, 死元组
select relname,size,ratio from monitor.pg_table_bloat;
```
[视图定义 -见](./postgres/pgstattuple/)

```
-- 垃圾回收开始时间结束时间 进程数

```

##### WAL

```
--- 过去5分钟内生成wal个数
select count(1) from pg_catalog.pg_ls_waldir() where modification > CURRENT_TIMESTAMP - '5 minutes' :: INTERVAL ;

--- wal写入速率
SELECT CASE WHEN pg_is_in_recovery() THEN pg_last_wal_replay_lsn() ELSE pg_current_wal_lsn() END - '0/0' as wal_lsn;
```

##### CheckPoint 
```
-- checkpoint  发生频率
```

##### 连接数
```

```

##### 长事物
```
pg_stat_activity > 2小时
```

##### 2pc 未提交事物
```
pg_prepared_xact() > 5 分钟
```

##### 复制槽 

##### 
