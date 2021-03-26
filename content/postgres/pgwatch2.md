---
title: "pgwatch2 数据库指标监控查看"
date: 2019-01-29T11:19:05+08:00
draft: false
---

##### 介绍

[pgwatch2官方](https://github.com/cybertec-postgresql/pgwatch2)

[官方演示示例](https://demo.pgwatch.com/)

架构 agent server

- agent 在被监控的pg上自定义方法，用于收集数据库信息。这些自定义的方法需要依赖需要数据库扩展如pg_stat_statements,plpythonu.

- server 负责存储收集过来的信息，可以存放在postgres或influxdb中. 并将收集的信息进行展示grafana.

#####  安装

 客户端

依赖的拓展
```
yum install postgresql10-plpython.x86_64 -y

```
配置数据库,需要重启数据库生效，多个拓展之间用,号分割。
```
shared_preload_libraries = 'pg_stat_statements'              
```

连接到对应的数据库，创建拓展
```
CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION plpythonu;
```
创建自定义方法, 使用supper user 用户执行如下sql. 注意将下面的pql 信息中的用户信息替换成自己的数据库连接用户。
```
该目录下为所有的自定义方法
https://github.com/cybertec-postgresql/pgwatch2/tree/master/pgwatch2/sql/metric_fetching_helpers

https://github.com/cybertec-postgresql/pgwatch2/blob/master/pgwatch2/sql/metric_fetching_helpers/stat_statements_wrapper.sql

https://github.com/cybertec-postgresql/pgwatch2/blob/master/pgwatch2/sql/metric_fetching_helpers/cpu_load_plpythonu.sql
```

 服务端

使用docker-compose 来管理服务，切都变得那么easy！

```
cat docker-compose.yaml 
version: '2'
services:
  pgw2:
    restart: unless-stopped
    image: cybertec/pgwatch2
    container_name: pw2
    ports:
      - 3000:3000 
      - 8080:8080 
    volumes:
      - ./data/pg:/var/lib/postgresql
      - ./data/influx:/var/lib/influxdb
      - ./data/grafana:/var/lib/grafana
      - ./data/pw2:/pgwatch2/persistent-config
#    environment:
#      - NOTESTDB=1 
```

说明：  
端口 3000 grafana界面展示端口 , 8080 后台管理端口  
数据卷 data 挂在到实体主机的位置。

##### 配置

访问8080端口进行后台配置，

DBs 数据库监控连接信息
Metrics 度量
Logs 日志信息， 配置后查看日志信息，多数为缺少自定义的方法，在被监控的数据库中定义就好。

访问 3000 端口，查看数据库指标。
