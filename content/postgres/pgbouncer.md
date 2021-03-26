---
title: "pgbouncer 连接池"
date: 2018-12-27T09:00:49+08:00
draft: false
---

#### 背景介绍

- Pgbouncer是一个针对PostgreSQL数据库的轻量级连接池  
- pgbouncer 的目标是降低因为新连接到 PostgreSQL 的连接而导致的性能损失   

使用术语说明：  
为了后面的描述更清晰，使用如下术语

- Client : 指访问者  
- Pgboucer: 指连接池  
- Postgres: 指数据库。
- Connetions: 指彼此之间的连接

整体架构  

原来: Client -> Postgres
现在: Client -> Pgbounce -> Postgres

##### 优势  
内存消耗低(默认为2k/连接)，因为Bouncer不需要每次都接受完整的数据包。   
Postgres的连接是进程模型，pogbouncer 使用libevent进行socket 通信。  

总结： 数据访问过程中建立连接很耗资源，pgboucer就是为了减少数据访问中的建立连接次数，重复利用已建立的连接进而缓解数据库压力。

#### 三种连接池模型

- session 会话级 ； 比较友好
- transaction 事务级； 比较激进
- statement 一个sql ； 客户端强制autocommit 模式

#### 安装

```
查看当前系统中版本
yum list pgbouncer.x86_64
pgbouncer.x86_64                         1.9.0-1.rhel7

升级到最新版
yum update pgbouncer.x86_64

安装
yum install pgbouncer.x86_64 -y

启动
systemctl start pgbouncer 
systemctl enable pgbouncer

```



#### 简单配置
```
cat /etc/pgbouncer/pgbouncer.ini | grep -v '^;' | grep -v '^$' 
[databases]
postgres= host=127.0.0.1 port=5432 user=postgres dbname=postgres connect_query='select 1' pool_size=40
zabbix= host=10.1.88.74 port=5432 dbname=zabbix  connect_query='select 1' pool_size=40
[pgbouncer]
logfile = /var/log/pgbouncer/pgbouncer.log
pidfile = /var/run/pgbouncer/pgbouncer.pid
listen_addr = 0.0.0.0
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
admin_users = postgres
stats_users = stats, postgres
pool_mode = session
server_reset_query = DISCARD ALL
max_client_conn = 100
default_pool_size = 20
```

##### 说明:

##### [databases] 
主要思想承上启下的作用相当于代理，呈上对访问者，启下对后端数据库。   
第一项的名称是pgbouncer对外提供的数据库名 postgres ,等号后面是连接后端数据库名信息  
pool_mode = session  
pool_size , 指定database 连接到后端服务器的连接数的最大值。配合数据库中的database connection limit ;

关于user 配置后面细说
##### [pgbouncer] 
pgbouncer自身的配置   
max_client_conn=允许用户建立多少个连接到pgbouncer   ,类似于数据库中的max_connection。
default_pool_size 表示默认连接池中建立多少个到后端数据库的连接,全局。 

#### 关于用户 User的配置说明
主要配置
[databases]中 user 表示连接到后端数据库所使用的用户
[pgbouncer]中 user 表示用户连接到pgbouncer中所使用的用户

情况1： 如果在databases中指定user=zabbix Clinet无论使用的是哪个用户，连接postgres的用户都是zabbix

情况2:  如果在database中没有指定user ,连接postgres的用户为Client使用的用户

pg中查看当前用户
```
postgres=# select * from current_user;
 current_user 
--------------
 postgres
(1 行记录)
```

auth_file 内容
格式 "user" "password",注意需要双引号   
可以在数据库中获取内容
```
select usename,passwd from pg_shadow ; 
```
```
cat /etc/pgbouncer/userlist.txt  
"zabbix" "md520e0e8833ebe8947cd347f94b1c4977f"
```
认证方法: 在pgbouncer中执行
```
show config;
auth_query | SELECT usename, passwd FROM pg_shadow WHERE usename=$1
```

推荐： 不在database中配置user 在auth_file中配置user

#### 登陆pgboucer 控制台

```
psql -p 6432 -U postgres  -h 127.0.0.1 pgbouncer
psql (10.4, 服务器 1.9.0/bouncer)
输入 "help" 来获取帮助信息.

pgbouncer=# show clients
pgbouncer-# ;
 type |   user   | database  | state  |   addr    | port  | local_addr | local_port |    connect_time     |    request_time     | wait | wait_us | close_needed |    ptr    | link | remote_pid | tls 
------+----------+-----------+--------+-----------+-------+------------+------------+---------------------+---------------------+------+---------+--------------+-----------+------+------------+-----
 C    | postgres | pgbouncer | active | 127.0.0.1 | 57048 | 127.0.0.1  |       6432 | 2019-01-02 16:22:22 | 2019-01-02 16:22:29 |    0 |       0 |            0 | 0x1a938c0 |      |          0 | 
(1 行记录)

pgbouncer=# show pools;
     database     |   user    | cl_active | cl_waiting | sv_active | sv_idle | sv_used | sv_tested | sv_login | maxwait | maxwait_us | pool_mode 
------------------+-----------+-----------+------------+-----------+---------+---------+-----------+----------+---------+------------+-----------
 normandy_cloud_d | postgres  |         0 |          0 |         0 |       0 |       1 |         0 |        0 |       0 |          0 | session
 pgbouncer        | pgbouncer |         1 |          0 |         0 |       0 |       0 |         0 |        0 |       0 |          0 | statement
(2 行记录)

更多

show  help;
NOTICE:  Console usage
描述:  
	SHOW HELP|CONFIG|DATABASES|POOLS|CLIENTS|SERVERS|VERSION
	SHOW FDS|SOCKETS|ACTIVE_SOCKETS|LISTS|MEM
	SHOW DNS_HOSTS|DNS_ZONES
	SHOW STATS|STATS_TOTALS|STATS_AVERAGES
	SET key = arg
	RELOAD
	PAUSE [<db>]
	RESUME [<db>]
	DISABLE <db>
	ENABLE <db>
	RECONNECT [<db>]
	KILL <db>
	SUSPEND
	SHUTDOWN


```


#### 关于poolsize的说明

[databases]中 pool_size: 配置连接池的大小,如果没有配置，使用[pgbouncer]default_pool_size
[pgbouncer]中   
default_pool_size: 连接池的默认大小  
max_client_conn: client到pgbouncer的最大数  
pool_mode: 连接模式   
min_pool_size: 连接池的最小大小，即每个连接池至少会向后端数据库保持多少个连接。Pgboucer -> Postgres     
reserve_pool_size: How many additional connections to allow to a pool. 0 disables.  
reserve_pool_timeout: 保留连接的超时时间   
max_user_connections: Client -> pgbouncer 每个用户最大连接数 
max_db_connections: Client -> Pgbouncer 每个数据库最大连接数 
disable_pqexec:  禁止简单查询。 简单查询协议允许一个请求发送多条Sql，但是容易造成Sql注入风险。 

#### 关于日志信息配置说明
syslog: 是否打开syslog  
syslog_ident: Under what name to send logs to syslog.  Default: pgbouncer (program name)
log_disconnections:     
log_connections:     
log_pooler_errors: Client pgbouncer 之间的错误日志  

#### 关于访问pgbouncer配置 

admin_users:  可以登陆console执行所有命令的用户。 多个用户之间用','号分割
stats_users:  可以登陆console执行SHOW 命令(except SHOW FDS)的用户。 

#### 关于监控检查超时设置  
server_reset_query: 当一个后端的数据库连接会话被某一个客户端使用时，它的属性可能会被修改。当这个后端数据库连接被第二个客户端使用的时就有可能产生问题。如上个连接中有 ABORT or ROLLBACK ,下个使用此连接的用户肯能会很惨。   
所以需要将所有的属性清空。  Default: DISCARD ALL

server_check_delay： Default: 30.0   
server_check_query： select 1   

[更多配置信息](http://pgbouncer.github.io/config.html#console-access-control)
