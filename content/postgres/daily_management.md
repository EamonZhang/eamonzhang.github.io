---
title: "数据库日常管理"
date: 2020-04-07T10:38:45+08:00
draft: false
---

#### 日常管理

- 可用性
- 监测项

#### 可用性

- 主从
- HA
- 全量备份
- 增量备份
- 恢复

#### 监测项

##### 磁盘空间
- 全库

```
select pg_size_pretty(sum(pg_database_size(oid))) from pg_database;
```

- 数据库

```
select datname, pg_size_pretty(pg_database_size(oid)) from pg_database order by pg_database_size(oid) desc limit 10;
```

- 表总

```
 SELECT table_schema || '.' || table_name AS table_full_name, pg_size_pretty(pg_total_relation_size('"' || table_schema || '"."' || table_name || '"')) AS size
FROM information_schema.tables where table_schema = 'public' ORDER BY pg_total_relation_size('"' || table_schema || '"."' || table_name || '"') DESC limit 10;
```

- 表


- 索引

##### 冷热数据

- 上次统计信息更新时间
- 热表dml 
  qps io
- 热表qdml
- 冷数据
- 冷索引

##### 索引利用

- 全表扫描次数
- 全表扫描记录数
- 选择性可能不好的索引
- 利用率低的索引
- 利用率高的索引

##### 表膨胀

- 表
- 索引
- 系统膨胀时间点
- 引发自动回收次数
- 关闭自动回收

##### checkpiont

- 频率
- wal膨胀

##### 锁

- 锁等待
- 死锁次数 加入实时监控
- 回滚次数 加入实时监控
- 锁产生的查询取消 加入实时监控

##### SQL

- 总耗时
- io耗时
- 性能抖动
- 内存
- 临时空间
- 长事务
- 慢查询
