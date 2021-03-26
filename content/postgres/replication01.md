---
title: "主从流复制"
date: 2018-10-17T14:55:38+08:00
draft: false
---

[历史演变](http://peter.eisentraut.org/blog/2015/03/03/the-history-of-replication-in-postgresql/)

[replication](https://www.postgresql.org/docs/9.3/warm-standby.html#STREAMING-REPLICATION)

#### 主库配置

```
根据实际情况分配流复制权限
vi pg_hba.conf

host replication all 10.2.0.0/0 trust
```

```
vi postgresql.conf

max_wal_senders = 10
wal_level = logical # minimal, replica, or logical

hot_standby = on # 正常在从库配置，如果在主库配置完毕，因为从库复制主库配置不需要再修改从库配置。

wal_log_hints = on
```

#### 从库配置

1 [数据库安装](postgres/install01)

2 从主库复制数据
```
pg_basebackup -h 10.2.0.14 -U postgres -F p -P -R -D /var/lib/pgsql/10/data/ --checkpoint=fast -l postgresback20181219
```
pg_basebackup支持两种全量备份的方式，

- 以fetch的方式，先备份数据在备份日志 

- 以stream的方式，并行的备份数据和日志 

pg_basebackup对于全量备份的数据和日志，提供了串行备份和并行备份的方式。fetch模式也就是串行备份需要保证在备份数据的过程中，备份开始时刻的日志需要一直保存下来， 也就说pg的wal_keep_segments需要足够大去保存日志文件，如果备份数据期间，日志开始时刻的日志已经被移除，那么备份就会失败。而stream模式，也就是并行备份过程中wal_max_sender必须保证不小于2。 而stream模式不支持，将数据和日志以流的方式输出到标准输出

限速，在生产系统中防止对正常业务的影响
```
-r, --max-rate=RATE    maximum transfer rate to transfer data directory
                         (in kB/s, or use suffix "k" or "M")
```
注意新拷贝数据的权限
```
chown postgres:postgres data/ -R
chmod 0700 data 
```

查看数据
```
ll data
总用量 88
-rw-------. 1 postgres postgres   203 12月 19 13:45 backup_label.old
drwx------. 7 postgres postgres    67 12月 19 14:12 base
-rw-------. 1 postgres postgres    44 12月 19 14:28 current_logfiles
drwx------. 2 postgres postgres  4096 12月 19 14:28 global
drwx------. 2 postgres postgres  4096 12月 19 14:28 log
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_commit_ts
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_dynshmem
-rw-------. 1 postgres postgres  4340 12月 19 13:45 pg_hba.conf
-rw-------. 1 postgres postgres  1636 12月 19 13:45 pg_ident.conf
drwx------. 4 postgres postgres    68 12月 19 15:08 pg_logical
drwx------. 4 postgres postgres    36 12月 19 13:45 pg_multixact
drwx------. 2 postgres postgres    18 12月 19 14:28 pg_notify
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_replslot
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_serial
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_snapshots
drwx------. 2 postgres postgres     6 12月 19 14:28 pg_stat
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_stat_tmp
drwx------. 2 postgres postgres    18 12月 19 13:45 pg_subtrans
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_tblspc
drwx------. 2 postgres postgres     6 12月 19 13:45 pg_twophase
-rw-------. 1 postgres postgres     3 12月 19 13:45 PG_VERSION
drwx------. 3 postgres postgres 12288 12月 19 15:09 pg_wal
drwx------. 2 postgres postgres    18 12月 19 13:45 pg_xact
drwx------. 3 postgres postgres    17 12月 19 13:45 pipeline
-rw-------. 1 postgres postgres    88 12月 19 13:45 postgresql.auto.conf
-rw-------. 1 postgres postgres 22748 12月 19 14:28 postgresql.conf
-rw-------. 1 postgres postgres    58 12月 19 14:28 postmaster.opts
-rw-------. 1 postgres postgres    95 12月 19 14:28 postmaster.pid
-rw-r--r--. 1 postgres postgres   262 12月 19 13:45 recovery.conf
```

查看 recovery.conf
```
cat recovery.conf
standby_mode = 'on'
primary_conninfo = 'user=postgres host=10.2.0.14 port=5432 sslmode=disable sslcompression=1'


```

3 从库配置  

启动从库
```
systemctl start postgresql-10.service
systemctl enable postgresql-10.service
```
```
#recovery.conf

recovery_target_timeline='latest'
recovery_min_apply_delay = 5min   #延迟多少分钟应用
trigger_file = '/home/postgres.trigger' #从库变主库时应用
```


4 验证

```
主库创建一个数据库
psql -U postgres 
postgres=# create database testreplication;

从库查看结果
psql -U postgres
postgres=#\l
                                                  数据库列表
       名称        |     拥有者     | 字元编码 |  校对规则   |    Ctype    |             存取权限              
-------------------+----------------+----------+-------------+-------------+-----------------------------------
 postgres          | postgres       | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
 template0         | postgres       | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres                      +
                   |                |          |             |             | postgres=CTc/postgres
 template1         | postgres       | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/postgres                      +
                   |                |          |             |             | postgres=CTc/postgres
 testreplication   | postgres       | UTF8     | en_US.UTF-8 | en_US.UTF-8 | 
(5 行记录)
```

状态查看

[WAL Sender 信息说明](https://mp.weixin.qq.com/s/VlXRPUzu0On7aYPqGjfkrg)
```
主库 查看同步状态
postgres=# select * from pg_stat_replication ;
-[ RECORD 1 ]----+------------------------------
pid              | 21092
usesysid         | 10
usename          | postgres
application_name | walreceiver
client_addr      | 10.1.0.15
client_hostname  | 
client_port      | 14703
backend_start    | 2018-12-19 14:28:15.220479+08
backend_xmin     | 
state            | streaming
sent_lsn         | 2/B1BDC000
write_lsn        | 2/B1B3C000
flush_lsn        | 2/B1B3C000
replay_lsn       | 2/B1B3A3B0
write_lag        | 00:44:13.27416
flush_lag        | 00:44:13.27416
replay_lag       | 00:44:13.274217
sync_priority    | 0
sync_state       | async

从库 查看wal receiver的统计信息
select * from pg_stat_wal_receiver ;
-[ RECORD 1 ]---------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
pid                   | 9329
status                | streaming
receive_start_lsn     | 0/3000000
receive_start_tli     | 1
received_lsn          | 2/DA5FC000
received_tli          | 1
last_msg_send_time    | 2018-12-19 15:25:43.662966+08
last_msg_receipt_time | 2018-12-19 15:25:43.846309+08
latest_end_lsn        | A/D09F1758
latest_end_time       | 2018-12-19 15:25:40.694523+08
slot_name             | node_a_slot
conninfo              | user=postgres passfile=/root/.pgpass dbname=replication host=10.1.0.14 port=5432 fallback_application_name=walreceiver sslmode=prefer sslcompression=1 krbsrvname=postgres target_session_attrs=any

-- 暂停WAL的应用，例如要做一些排错时  
select pg_wal_replay_pause();  
-[ RECORD 1 ]-------+-  
pg_wal_replay_pause |   
  
-- 查看状态  
select pg_is_wal_replay_paused();  
-[ RECORD 1 ]-----------+--  
pg_is_wal_replay_paused | t  
 
-- 恢复wal 
select pg_wal_replay_resume();  
-[ RECORD 1 ]--------+-  
pg_wal_replay_resume |   
  
-- 查看状态
select pg_is_wal_replay_paused();  
-[ RECORD 1 ]-----------+--  
pg_is_wal_replay_paused | f  

```


5 wal 日志保持时效

PostgreSQL 9.4 新增的一个特性, replication slot, 
-  可以被流复制的sender节点用于自动识别它xlog中的数据在下面的standby中是否还需要(例如, standby断开连接后, 还未接收到的XLOG), 如果还需要的话, 那么这些XLOG将不会被删除.
-  对于tuples, 如果standby 配置了hot_standby_feedback=on, 那么发生冲突的tuples将不会在sender端被vacuum回收. 用于规避冲突.

配置比较简单, 需要在sender端使用函数创建slot, 在receiver端配置对应的slot name即可.
 
主库：
```
postgres=# SELECT * FROM pg_create_physical_replication_slot('node_a_slot');
  slotname   | xlog_position
-------------+---------------
 node_a_slot |

postgres=# SELECT * FROM pg_replication_slots;
  slot_name  | slot_type | datoid | database | active | xmin | restart_lsn
-------------+-----------+--------+----------+--------+------+-------------
 node_a_slot | physical  |      0 |          | f      |    
```

```
从库 
cat recovery.conf 
 
primary_slot_name = 'node_a_slot'
```
流复制协议也做了相应的改进 : 
 
使用slot的好处 :    

- 在没有replication slot这个特性以前, 有两种方法来保持standby需要的xlog, wal keep或者归档, 因为主节点不知道standby到底需要哪些XLOG信息, 配置一般需要较大的余量. slot可以解决这个浪费sender端存储wal空间的问题, 因为sender可以做到保留更精准的wal信息.
- 配合standby节点的feedback使用, 可以避免vacuum带来的冲突.

6 同步复制VS异步复制

PostgreSql的流复制是异步的，缺点是Standby上的数据落后于主库上的数据，如果使用Hot Standby做读写分离，就会存在数据一致性的问题。PostgreSql9.1版本后提供了同步流复制的架构。同步复制的要求在数据写入Standby数据库后，事务commit才返回。
存在问题：当Standby数据出现问题时，会导致主库被hang住。
解决方法：启动两个或两个以上的Standby数据库。

配置方法，在主从配置基础上

主库synchronous_standby_names 参数指定多个Standby的名称，各个名称通过逗号分割，而Standby连接到主库由application_name 参数指定

主库
```
vi postgresql.conf
synchronous_standby_names = 'standby01,standby02'
```

从库
```
cat recovery.conf 
standby_mode = 'on'
primary_conninfo = 'application_name=standby02 user=postgres host=10.2.0.14 port=5432 sslmode=disable sslcompression=1'
```

主库查看结果
```
psql -U postgres
postgres=# select sync_state from pg_stat_replication ;
```

7 从变主

##### 简单有效的方式

在从库中配置
cat recovery.conf
```
trigger_file = '/home/postgres.trigger'
```
重启从库

将从库变成主库
```
touch /home/postgres.trigger
```

##### pg_ctl promote

pg_ctl promte -D $PGDATA
server promoting

8 [pg_rewind](https://www.cnblogs.com/zhangeamon/p/7602269.html)

9 从库有查询业务时注意事项

```
 1. 如果备库有LONG query，同时需要实时性，可以设置hot_standby_feedback=on，同时建议将主库的autovacuum_naptime，autovacuum_vacuum_scale_factor设置为较大值（例如60秒，0.1），
    主库的垃圾回收唤醒间隔会长一点，如果突然产生很多垃圾，可能会造成一定的膨胀。
 2. 如果备库有LONG QUERY，并且没有很高的实时性要求，建议设置设置hot_standby_feedback=off, 同时设置较大的max_standby_archive_delay， max_standby_streaming_delay。
```

10 扩展阅读  
 
 - PostgreSQL 10加入了quorum based的同步复制功能，用户可以配置若干standby节点，并配置需要将WAL发送多少份才返回给客户端事务结束的消息。

 - [性能](https://m.aliyun.com/yunqi/articles/73540)   

11 冲突及解决

###### 冲突
```
FATAL:  terminating connection due to conflict with recovery  
DETAIL:  User query might have needed to see row versions that must be removed.  
HINT:  In a moment you should be able to reconnect to the database and repeat your command. 
```

###### 原因

报错是备库事务或者单SQL查询时间长，和备库的日志apply发生冲突，如果业务上有长事务、长查询，主库上又再修改同一行数据，很容易造成备库的wal日志无法apply。

wal无法apply数据库有两个策略：

- 备库告诉主库需要哪些版本，让主库保留，备库查询始终能拿到需要的版本，不阻塞apply，因为备库总能拿到需要的版本

- 备库apply进入等待，直到备库冲突查询结束，继续apply。可以设置超时时间。max_standby_streaming_delay

###### 对应解决方法

方法一
```
vacuum_defer_cleanup_age > 0
或
hot_standby_feedback=on

```

代价1，主库膨胀，因为垃圾版本要延迟若干个事务后才能被回收。

代价2，重复扫描垃圾版本，重复耗费垃圾回收进程的CPU资源。（n_dead_tup会一直处于超过垃圾回收阈值的状态，从而autovacuum 不断唤醒worker进行回收动作）。

代价3，如果期间发生大量垃圾，垃圾版本可能会在事务到达并解禁后，爆炸性的被回收，产生大量的WAL日志，从而造成WAL的写IO尖刺。

方法二
```
max_standby_streaming_delay

max_standby_archive_delay和max_standby_streaming_delay
```
代价，如果备库的QUERY与APPLY（恢复进程）冲突，那么备库的apply会出现延迟，也许从备库读到的是N秒以前的数据。

12 pg 12 变更

- recovery.conf 中的配置内容位置变更到postgresql.auto.conf

- trigger_file -> promte_trigger_file

- 增加 standby.signal recovery.signal

13 虚拟备库

```
pg_receivewal
```

备份增量wal日志，并可压缩备份。结合wal-g 做数据备份
