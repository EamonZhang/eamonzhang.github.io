---
title: "流复制同步级别"
date: 2021-03-17T11:14:17+08:00
draft: false

---

## 流复制过程

![主从流复制](/images/replcation.png)

```
synchronous_commit = on  ）              # synchronization level;  on default 
                                        # off, local, remote_write, or on  
```

## 同步级别

- remote_apply：事务commit或rollback时，等待其redo在primary、以及同步standby(s)已持久化，并且其redo在同步
standby(s)已apply。

- on：事务commit或rollback时，等待其redo在primary、以及同步standby(s)已持久化。

- remote_write：事务commit或rollback时，等待其redo在primary已持久化; 其redo在同步standby(s)已调用write接口(写到 OS, 但是还没有调用持久化接口如fsync)。

- local：事务commit或rollback时，等待其redo在primary已持久化;

- off：事务commit或rollback时，等待其redo在primary已写入wal buffer，不需要等待其持久化;

安全等级与性能影响综合考量

从上到下： 安全等级降低。

从下到上： 性能影响增加。
