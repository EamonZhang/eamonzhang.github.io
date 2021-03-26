---
title: "时间点恢复"
date: 2019-01-24T11:08:54+08:00
draft: false
---

##### PITR
Point-in-time recovery


https://blog.csdn.net/a964921988/article/details/84957241

https://github.com/digoal/blog/blob/master/201608/20160823_03.md

https://github.com/digoal/blog/blob/master/201608/20160823_04.md


##### 依赖条件

- 历史完整备份
- 不间断wal日志

以上都可有wal-g 备份系统提供支持

##### 恢复到指定点

- 指定标签
- 具体时间点
- 具体事务 

###### 指定标签
```
recovery.conf
recovery_target_action= 'pause'  # promote ,shutdown
```

```
--- 打lable 
select pg_create_restore_point('my_daily_process_ended');

--- 恢复到指定的lable
recovery.conf
recovery_target_name = 'my_daily_process_ended'
```

###### 具体时间
```
restore_command = 'cp /data/arch/%f %p'            # e.g. 'cp /mnt/server/archivedir/%f %p'
recovery_target_time = '2020-12-23 09:37:17.010268'
recovery_target_inclusive = false
recovery_target_timeline = 'latest'
```

###### 具体事务
```
restore_command = 'cp /data/arch/%f %p'            # e.g. 'cp /mnt/server/archivedir/%f %p'
recovery_target_xid = '26897309' 
recovery_target_inclusive = false    
recovery_target_timeline = 'latest
```

###### wal内容解析具体位置，时间、事务

```
select pg_current_wal_lsn();
 pg_current_wal_lsn 
--------------------
 59/15000090
(1 行记录)

```
```
-- 当前wal位置
select pg_walfile_name(pg_current_wal_lsn());
     pg_walfile_name      
--------------------------
 000000020000005900000015
(1 行记录)

-- 00000002 TimeLine
-- 00000059 逻辑位置
-- 00000015 偏移
```

```
-- 解析wal内容
/usr/pgsql-10/bin/pg_waldump ./000000020000005900000013
rmgr: Heap        len (rec/tot):     54/    54, tx:   26897309, lsn: 59/13000028, prev 59/120007D8, desc: DELETE off 1 KEYS_UPDATED , blkref #0: rel 1663/389916/1276307 blk 0
rmgr: Heap        len (rec/tot):     54/    54, tx:   26897309, lsn: 59/13000060, prev 59/13000028, desc: DELETE off 2 KEYS_UPDATED , blkref #0: rel 1663/389916/1276307 blk 0
rmgr: Heap        len (rec/tot):     54/    54, tx:   26897309, lsn: 59/13000098, prev 59/13000060, desc: DELETE off 3 KEYS_UPDATED , blkref #0: rel 1663/389916/1276307 blk 0
rmgr: Heap        len (rec/tot):     54/    54, tx:   26897309, lsn: 59/130000D0, prev 59/13000098, desc: DELETE off 5 KEYS_UPDATED , blkref #0: rel 1663/389916/1276307 blk 0
rmgr: Transaction len (rec/tot):     46/    46, tx:   26897309, lsn: 59/13000108, prev 59/130000D0, desc: COMMIT 2020-12-23 09:37:17.010268 CST

-- 事务 tx： 26897309
-- 时间 2020-12-23 09:37:17.010268 CST
```

```
-- 根据 rel 1663/389916/1276307  查看具体是哪个表
select datname from pg_database where oid = 389916;
 datname 
---------
 test1
(1 行记录)

select relname from pg_class where oid=1276307;
 relname 
---------
 t_1
(1 行记录)
```


