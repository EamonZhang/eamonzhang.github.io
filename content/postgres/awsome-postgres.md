---
title: "工作中所使用的postgres"
date: 2020-05-27T11:34:24+08:00
draft: false
---

Postgres 实际应用概览


- MVCC 多版本控制 

一个绕不开的话题， 主要是对抗表空间的膨胀。解决垃圾回收问题，主从库之间从库查询冲突问题。

目前方法每日低峰期定时 vaccum ，gocron自定定时任务 。 根据pgstattuple对磁盘空间利用率进行分析。决定是否vaccum full ,pg_repack

- 流复制

主从复制，读写分离的基础。五种同步方式

- 逻辑订阅

大版本升级，数据并归。迁移

- 执行计划调优

调节成本因子比例，如不同的磁盘类型比例有所区别

- 参数调优

主机 和 服务

- 分区表

采用pg_pathman ,因为都是根据业务数据量来决定是否分区。pg_pathman 能够不停服的前提下自动分区数据。

- 高可用

patroni

- 分表

citus 注意亲和性 和表之间的join ddl 等限制。


- 监控，日志

promethues 套件，自定义监控项 。 filebeat elasticsearch kibana 日志收集

- 统计

结合数据库自带的统计信息及pg_stat_statements 插件生产报表

- 压测

pg_bench ,自定义sql

- 备份恢复

wal-g 全量和实时增量

- 连接池

pgbounch 主要用于分表中各个服务之间

- FDW


