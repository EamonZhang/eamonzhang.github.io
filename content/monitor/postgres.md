---
title: "Postgres"
date: 2019-01-11T17:09:51+08:00
draft: false
---

#### Postgresql 常用监控 , 巡检报表

直接利用PG提供的性能统计数据   
PG的很多性能数据可以通过查询pg_stat_或pg_statio_开头的系统表获取 


zabbix 

http://pg-monz.github.io/pg_monz/index-en.html

[zabbix-extensions](monitor/zabbix-postgres-fqa/)

PG专用的监控工具   
pgsnap, pgstatspack,pgwatch,pg_statsinfo等。这些工具主要做PG的性能分析，状态查看的。不能做故障通知。    


https://github.com/cybertec-postgresql/pgwatch2

https://github.com/wrouesnel/postgres_exporter

https://www.cnblogs.com/ilifeilong/p/10543876.html

基于promethues postgres_exporter

https://github.com/CrunchyData/pgmonitor
