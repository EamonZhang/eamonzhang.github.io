---
title: "定时任务"
date: 2019-01-09T10:11:10+08:00
draft: false
---

#### Linux 系统中的定时任务

- 重复执行
- 一次执行

#### 重复执行

详见 /etc/crontab 配置

anacron 用于以天为单位的频率运行命令。它的工作与 cron 稍有不同，它假设机器不会一直开机。

cron 也适合在那些不会 24X7 运行如笔记本以及桌面电脑的机器上运行每日、每周以及每月的计划任务（LCTT 译注：不适合按小时、分钟执行任务）。

假设你有一个计划任务（比如备份脚本）要使用 cron 在每天半夜运行，也许你以及睡着，那时你的桌面/笔记本电脑已经关机。你的备份脚本就不会被运行。

然而，如果你使用 anacron，你可以确保在你下次开启桌面/笔记本电脑的时候，备份脚本会被执行。

#### 一次执行

我们使用at 命令来管理Linux中单次执行任务

安装与启动
```
yum install at -y
systemctl start atd  
```

常用命令及参数讲解

- at和batch读取标准输入或一个指定文件，它们将会在稍后被执行。   
- at在指定的时间执行命令。   
- atq列出用户待处理作业（jobs），如果是超级用户，所有用户的（待处理）作业都将被列出。输出格式：作业号、日期、小时、队列和用户名。  
- atrm删除作业，由作业号标识。   

```
-t time run the job at time, given in the format [[CC]YY]MMDDhhmm[.ss]
-c cats the jobs listed on the command line to standard output.
```

#### 例子说明

新建一个定期任务 ctrl + d 退出
```
# at -t 201901091123.00
at> touch /home/11.23.at     
at> <EOT>
job 9 at Wed Jan  9 11:23:00 2019
# at -t 201901091124.00
at> touch /home/11.24.at 
at> <EOT>
job 10 at Wed Jan  9 11:24:00 2019
```

查看任务
```
# atq
9	Wed Jan  9 11:23:00 2019 a root
10	Wed Jan  9 11:24:00 2019 a root
```

根据任务id 查看任务具体内容

```
# at -c 9
```

删除任务

```
# atrm 9 
```

##### 扩展内容

centos 7

```
# ll -a /var/spool/at/
总用量 12
drwx------  3 root root   75 1月   9 10:27 .
drwxr-xr-x. 9 root root   97 1月   9 09:49 ..
-rwx------  1 root root 3081 1月   9 10:27 a0000901896c6b
-rwx------  1 root root 3082 1月   9 10:28 a0000a01896c6c
-rw-------  1 root root    6 1月   9 10:27 .SEQ
drwx------  2 root root    6 1月   9 10:23 spool
```

.SEQ 序列

a0000901896c6b 任务内容，at -c id 输出的内容

可以直接执行对应的脚本文件进行测试

```
sh a0000901896c6b
```

ubuntu 

```
/var/spool/cron/atjobs
```

##### 执行日志

```
cat /var/log/messages | grep atd
Jan  9 10:00:36 kvm74 atd[27978]: Starting job 1 (a0000101896c10) for user 'root' (0)
Jan  9 10:04:00 kvm74 atd[29511]: Starting job 2 (a0000201896c1c) for user 'root' (0)
Jan  9 10:07:00 kvm74 atd[31902]: Starting job 4 (a0000401896c1f) for user 'root' (0)
Jan  9 10:18:28 kvm74 atd[6985]: Starting job 5 (a000050181670b) for user 'root' (0)
Jan  9 10:20:28 kvm74 atd[8173]: Starting job 6 (a000060181670e) for user 'root' (0)
Jan  9 10:21:33 kvm74 atd[9617]: Starting job 7 (a000070181670f) for user 'root' (0)
Jan  9 10:23:00 kvm74 atd[10016]: Starting job 8 (a0000801896c2f) for user 'root' (0)
Jan  9 11:23:00 kvm74 atd[13963]: Starting job 9 (a0000901896c6b) for user 'root' (0)
Jan  9 11:24:00 kvm74 atd[14248]: Starting job 10 (a0000a01896c6c) for user 'root' (0)
Jan 10 08:57:00 kvm74 atd[13667]: Starting job 11 (a0000b01897179) for user 'root' (0)
```

#### 错误总汇

```
cat /var/log/syslog* | grep atd
Jan 11 08:29:00 atd[14999]: Exec failed for mail command: No such file or directory
```
https://ubuntuforums.org/showthread.php?t=1777706

上面的问题在系统环境中没有出现，在执行docker时出现

如执行命令为
```
docker exec -it docker-name date
```
