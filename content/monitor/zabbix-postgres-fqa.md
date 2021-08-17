---
title: "Zabbix Postgres Fqa"
date: 2018-12-24T17:18:11+08:00
draft: false
---

#### 如何使用篇
---
- 如何使用zabbix监控postgres

我们采用的是github中的开源项目[zabbix-extensions](https://github.com/lesovsky/zabbix-extensions)中的postgres，iostat对Postgres数据库性能指标及系统IO进行监控。   
以及对实体机进行监控，本文主要介绍对postgres的性能进行监控和分析


- 如何在现有的数据库系统中加入监控，需要哪些条件

哪些条件   
1 PostgreSQL version 9.4 and above   
2 Zabbix 3.4 and newer  

如何加入监控  
1 在数据服务的主机中加入zabbix-agent，在cp files/postgresql/postgresql.conf /etc/zabbix/zabbix_agentd.d/，zabbix界面端加入对应模板   
2 数据库访问权限，本地访问数据库权限，可在pg_hba.conf中设置， 加入一行'host all  all 127.0.0.1/32  trust',这个权限有些大，根据自己的情况设置。    
3 数据库中加入extends: pg_buffercache pg_stat_statements      

以上所有操作不需要重启数据库， reload即可生效    

- 监控是如何连接到数据库的

使用模板中的宏定义

```
 {$PG_CONNINFO}=-h 127.0.0.1 -p 5432 -U postgres -d zabbix
```

如果现在一套zabbix系统中监控多个数据库，数据库的端口，用户名不统一时，可以在各自的hosts中的宏定义中分别设置各自的连接方式。

- 如何指定哪些databases tables被监控

首先模板中包含3种自动发现机制分别是Discovery rule

PostgreSQL databases discovery  数据库中database  
PostgreSQL database tables discovery 数据库中的table   
PostgreSQL streaming stand-by discovery   流复制   

以上discovery 可根据具体需求进行开启关闭

在Filters中对发现规则的结果进行过滤，如对哪些databases哪些tables进行监控。

#### 如何调试

```
zabbix_get -s 10.1.88.74 -k pgsql.db.discovery['-h 127.0.0.1 -p 5432 -U postgres']

-s 数据库访问ip
-k key [参数]
``` 

#### 常见问题解读
---

- PostgreSQL: number of running processes 

分析
```
zabbix_get -s 10.1.88.74 -k proc.num[postgres]
0
```

返回结果为0 ， 

登陆到对应节点
```
ps -fu postgres
UID        PID  PPID  C STIME TTY          TIME CMD
postgres  4699     1  0 5月16 ?       00:25:14 /usr/pgsql-10/bin/postmaster -D /home/pgsql/10/data/
```
PID为1的进程应用名称为postmaster

```
zabbix_get -s 10.1.88.74 -k proc.num[postmaster]
31
```

解决方法：

在zabbix模版对应值进行修改{$PG_PROCESS_NAME}=postmaster 

当前postgers version 10.4 出现如上问题,10.6 没有


