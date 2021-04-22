---
title: "Postgres  数据库"
date: 2021-02-08T10:10:01+08:00
draft: false
toc: true
---


## 关于优化思考

- [数据库优化思考 - 性能优化](/postgres/thinking_in_db_performance)
- [数据库优化思考 - 结构设计](/postgres/thinking_in_db_fd)
- [数据库优化思考 - 模块调优](/postgres/thinking_in_db_tune)

## 基础知识

- [模板数据库](/postgres/template)
- [数据库日志](/postgres/log)
- [Explain 执行计划](/postgres/explain)
- [vacuum 垃圾回收器](/postgres/vacuum)
- [表空间膨胀](/postgres/pgstattuple)
- [fillfactor 填充因子](/postgres/fillfactor)
- [TOAST 技术](/postgres/toast)
- [hot update](/postgres/hotupdate)
- [tablespace 表空间](/postgres/tablespace)
- [锁机制](/postgres/pg_lock)
- [锁等待](/postgres/lock_wait)
- [cluster 聚族表](/postgres/cluster)
- [咨询锁 adlock](/postgres/adlock)
- [数据库年龄](/postgres/pgage)
- [方法和函数](/postgres/functionsandoperators)
- [高级SQL](/postgres/high_level_sql)
- [数据库 OOM 预防](/postgres/oom)
- [跨库操作](/postgres/pg_fdw)
- [auto vacuum 触发机制](/postgres/auto_vacuum_trigger)
- [unlogged table](/postgres/unlogged_table)

## 安装维护

- [安装 Postgres](/postgres/install01)
- [主从流复制](/postgres/replication01)
- [Logical Replication 逻辑复制](/logical-replication)
- [数据库参数](/postgres/params)
- [指标查看&stat统计信息](/postgres/stat)
- [拓展插件](/postgres/extention)
- [pg_stat_statements统计信息](/postgres/pg_stat_statements)
- [pg-pool2](/postgres/pgpool2)
- [pgbouncer 连接池](/postgres/pgbouncer)
- [postgres 12](/postgres/postgres12)
- [Untunu18安装Postgres12](/postgres/install02)
- [数据预加载](/postgres/pg_prewarm)
- [kylin系统postgresql编译安装](/postgres/compile_kylin)

## 管理

- [pg_pathman 分区表](/postgres/pg_pathman)
- [范式约束](/postgres/normal-form)
- [DBA 日常](/postgres/dba)
- [数据库日常管理](/postgres/daily_management)
- [应用实战](/postgres/awsome-postgres)
- [创建只读用户](/postgres/readonly)
- [找回supper user 权限](/postgres/reback_supper_user)
- [分区表](/postgres/partition)

## 常用视图

- [数据库视图之 pg_stat_activity](/postgres/view_pg_stat_activity)
- [数据库试图之 pg_stat_bgwriter](/postgres/view_pg_stat_bgwriter)

## 服务进程

- [CheckPoint](/postgres/checkpoint)
- [Backgroud Writer](/postgres/bgwriter)
- wal writer
- stat collector
- logger 
- [vacuum](/postgres/vacuum)  

## 备份恢复

- [备份&恢复](/postgres/backup_restore)
- [Archive wal归档](/postgres/archive)
- [时间点恢复](/postgres/pitr)
- [误操作闪回](/postgres/reback)
- [使用PG_RMAN管理备份恢复](/postgres/pg_rman)
- [wal-g 应用](/postgres/wal-g)
- 使用pgbakrest备份恢复

## 高可用

- [数据库高可用设计分析](/postgres/ha_fd)
- [主从流复制](/postgres/replication01)
- [PG主从切换 pg_rewind](/postgres/pg_rewind)
- [PG高可用Patroni搭建](/postgres/patroni)
- [PG高可用Patroni管理进阶](/postgres/patroni02)
- [PG高可用Repmgr搭建](/postgres/repmgr)

## 索引

- [索引类型及使用场景](/postgres/index01)
- [引起索引失效](/postgres/index-invalid)
- [pg_trgm的gist和gin索引加速字符匹配查询](/postgres/pg_trgm)
- [Bloom 索引](/postgres/index-bloom)
- [创建假设索引](https://github.com/HypoPG/hypopg)

## 流数据库

- [Pipelinedb文档概览](/postgres/pipelinedb01)
- [Pipelinedb 简介](/postgres/pipelinedb02)

## 时序数据库

- [TimescaleDB 时序数据库](/postgres/timescaledb)

## 数据库测试

- [快速生成大量数据](/postgres/insert01)
- [pgbench 压力测试](/postgres/pgbench)
- [tpch AP测试](/postgres/tpch)

## 监控系统

- [监控工具](/postgres/monitor)
- [pgwatch2 数据库指标监控查看](/postgres/pgwatch2)
- [数据库监控指标](/postgres/monitor_explain)

## 日志系统
 
- ELK

## 分布式

- [citus 数据库分库](/postgres/pg_citus)
- [citus 简单应用](/postgres/citus01)

## 安全管理

- [数据库 ssl认证](/postgres/ssl)


