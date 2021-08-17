---
title: "MySQL常用性能分析命令"
date: 2019-01-29T14:06:55+08:00
draft: false
---

MySQL常用性能突发事件分析命令：

1. SHOW PROCESSLIST; —当前MySQL数据库的运行的所有线程
 
2. INNODB_TRX; — 当前运行的所有事务

3. INNODB_LOCKS; — 当前出现的锁

4. INNODB_LOCK_WAITS; — 锁等待的对应关系计
 
5. SHOW OPEN TABLES where In_use >0; — 当前打开表

6. SHOW ENGINE INNODB STATUS  \G; —Innodb状态

7. SHOW STATUS LIKE  'innodb_row_lock_%'; — 锁性能状态

8. SQL语句EXPLAIN; — 查询优化器
