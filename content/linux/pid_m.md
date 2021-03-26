---
title: "进程管理"
date: 2019-01-31T10:56:47+08:00
draft: false
---

##### 监控进程

查看系统TOP(f进入field选择)  
```
top  
```  

打印系统进程  
```
ps -efwL  
```

统计每个进程的开销  
```
pidstat -d -r -u -w -l -h -p ALL 5 1  
```
打印进程stack  
```
pstack -p pid  
```
打印进程系统调用  
```
strace -p pid  
```

#####  结束和管理进程

结束进程
```
kill pid  
```

强制结束进程(用户进程无法捕获-9信号，可能崩溃. -15信号稳妥些)
```
kill -9 pid  
```
管理周期进程

任务调度进程的管理

查看当前用户的当前调度任务
```
crontab -l  
```
配置当前用户的调度任务(命令一定要有user:x权限，否则不会被执行)
```
crontab -e  
  
# * 表示所有，支持-号范围，支持,号枚举  
# Example of job definition:  
# .---------------- minute (0 - 59)  
# |  .------------- hour (0 - 23)  
# |  |  .---------- day of month (1 - 31)  
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...  
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat  
# |  |  |  |  |  
# *  *  *  *  * user-name command to be executed  
```
##### 调整进程

进程优先级，Linux在分配计算资源时，优先分配给nice值低的进程。

nice等级的范围从-20-19，其中-20最高，19最低，只有系统管理者可以设置负数的等级。

启动时调整进程的优先级

启动时设置为-5  
```
nice -n -5 命令 &  
```

调整已存在进程的优先级
```
renice -5 -p 5200  
``` 
PID为5200的进程nice设为-5  
查看进程优先级
```
top -p pid  
```
NI 字段表示  
调整进程的CPU亲和(绑定CPU)
```
numactl --physcpubind=1,2,3 命令  
```
将命令的CPU绑定到1,2,3号核  
