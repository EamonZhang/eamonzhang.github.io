---
title: "锁等待"
date: 2020-03-27T16:27:02+08:00
draft: false
---

##### 锁等待场景

一个事务尚未执行提交时持有锁，当另一个事务需要持有改行的锁时则需要等待。

Session 1

```
postgres=# \d+ wt
                                     Table "public.wt"
 Column |  Type   | Collation | Nullable | Default | Storage  | Stats target | Description 
--------+---------+-----------+----------+---------+----------+--------------+-------------
 id     | integer |           |          |         | plain    |              | 
 t      | text    |           |          |         | extended |              | 

postgres=# begin;
BEGIN
postgres=# update wt set t = 'aaaa' where id = 1;
UPDATE 1
postgres=# select pg_backend_pid();
 pg_backend_pid 
----------------
          20034
(1 row)
```

Session 2 
```
postgres=# begin ;
BEGIN
postgres=# update wt set t = 'bbbb' where id = 1;
```

Session 3

```
select * from pg_stat_activity;

-[ RECORD 3 ]----+----------------------------------------
datid            | 436980
datname          | postgres
pid              | 20476
usesysid         | 10
usename          | postgres
application_name | psql
client_addr      | 
client_hostname  | 
client_port      | -1
backend_start    | 2020-03-27 16:40:50.706409+08
xact_start       | 2020-03-27 16:40:55.515366+08
query_start      | 2020-03-27 16:41:09.139546+08
state_change     | 2020-03-27 16:41:09.13955+08
wait_event_type  | Lock
wait_event       | transactionid
state            | active
backend_xid      | 22112130
backend_xmin     | 22112129
query            | update wt set t = 'bbbb' where id = 1;
backend_type     | client backend
-[ RECORD 4 ]----+----------------------------------------
datid            | 436980
datname          | postgres
pid              | 20034
usesysid         | 10
usename          | postgres
application_name | psql
client_addr      | 192.168.6.78
client_hostname  | 
client_port      | 56464
backend_start    | 2020-03-27 16:33:27.223241+08
xact_start       | 2020-03-27 16:39:46.160577+08
query_start      | 2020-03-27 16:40:41.602471+08
state_change     | 2020-03-27 16:40:41.603281+08
wait_event_type  | Client
wait_event       | ClientRead
state            | idle in transaction
backend_xid      | 22112129
backend_xmin     | 
query            | update wt set t = 'aaaa' where id = 1;
backend_type     | client backend

```

第二个Session中的事务在等待着第一个事务的提交。

未提交事务特点 wait_event = idle in transaction

等待事务特点 wait_event_type = Lock ,wait_event = transactionid ,state=active

#### 查看数据库中的锁等待

```
with      
t_wait as      
(      
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,     
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,      
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name     
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted     
),     
t_run as     
(     
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,     
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,     
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name     
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted     
),     
t_overlap as     
(     
  select r.* from t_wait w join t_run r on     
  (     
    r.locktype is not distinct from w.locktype and     
    r.database is not distinct from w.database and     
    r.relation is not distinct from w.relation and     
    r.page is not distinct from w.page and     
    r.tuple is not distinct from w.tuple and     
    r.virtualxid is not distinct from w.virtualxid and     
    r.transactionid is not distinct from w.transactionid and     
    r.classid is not distinct from w.classid and     
    r.objid is not distinct from w.objid and     
    r.objsubid is not distinct from w.objsubid and     
    r.pid <> w.pid     
  )      
),      
t_unionall as      
(      
  select r.* from t_overlap r      
  union all      
  select w.* from t_wait w      
)      
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,     
string_agg(     
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||     
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||     
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||      
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||      
'SQL (Current SQL in Transaction): '||chr(10)||    
case when query is null then 'NULL' else query::text end,      
chr(10)||'--------'||chr(10)      
order by      
  (  case mode      
    when 'INVALID' then 0     
    when 'AccessShareLock' then 1     
    when 'RowShareLock' then 2     
    when 'RowExclusiveLock' then 3     
    when 'ShareUpdateExclusiveLock' then 4     
    when 'ShareLock' then 5     
    when 'ShareRowExclusiveLock' then 6     
    when 'ExclusiveLock' then 7     
    when 'AccessExclusiveLock' then 8     
    else 0     
  end  ) desc,     
  (case when granted then 0 else 1 end)    
) as lock_conflict    
from t_unionall     
group by     
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;
```

#### 消除锁等待

```
select pg_cancel_backend(pid);


select pg_terminate_backend(pid);
```

##### 监控方案

长事务监控
```
select extract(epoch from max(age(now(), query_start))) from pg_stat_activity where state <> 'idle' and (backend_xid is not null or backend_xmin is not null);
```

长事务查看
```
select * from pg_stat_activity  pg_stat_activity where state <> 'idle' and (backend_xid is not null or backend_xmin is not null) order by query_start asc limit 1;

select * from pg_stat_activity  pg_stat_activity where state <> 'idle' and (backend_xid is not null or backend_xmin is not null) and backend_type = 'client backend' order by query_start asc limit 1;
```

2pc

```
select * from pg_prepared_statements;
```

##### 日志记录

当堵塞时间大于deadlock (1s) 时

全局
```
 set log_lock_waits TO ON;
```

指定数据库
```
 alter database dbname set log_lock_waits TO ON;
```


日志内容如下

```
2020-03-31 09:16:32.704 CST,"postgres","postgres",25436,"[local]",5e8299b7.635c,5,"UPDATE waiting",2020-03-31 09:15:35 CST,4/52140,22112144,LOG,00000,"process 25436 still waiting for ShareLock on transaction 22112143 after 1000.162 ms","Process holding the lock: 24758. Wait queue: 25436.",,,,"while updating tuple (0,39) in relation ""wt""","update wt set t = 'bbbb' where id = 1;",,,"psql"
2020-03-31 09:18:25.946 CST,"postgres","postgres",25436,"[local]",5e8299b7.635c,6,"UPDATE waiting",2020-03-31 09:15:35 CST,4/52140,22112144,LOG,00000,"process 25436 acquired ShareLock on transaction 22112143 after 114242.016 ms",,,,,"while updating tuple (0,39) in relation ""wt""","update wt set t = 'bbbb' where id = 1;",,,"psql"
2020-03-31 09:18:25.946 CST,"postgres","postgres",25436,"[local]",5e8299b7.635c,7,"UPDATE",2020-03-31 09:15:35 CST,4/52140,22112144,LOG,00000,"duration: 114244.352 ms",,,,,,,,,"psql"
plate_number
```

25436 被 24758 堵塞

##### 查看谁堵塞了谁

```
pg_blocking_pids(pid)
```
