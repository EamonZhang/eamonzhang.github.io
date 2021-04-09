---
title: "CPU亲和性(亲和力)"
date: 2021-04-09T09:35:25+08:00
draft: false
toc: true 
categories: ["linux"]
tags: []
---

## 基础知识

#### 查看cpu

```
#lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                128
On-line CPU(s) list:   0-127
Thread(s) per core:    2
Core(s) per socket:    32
Socket(s):             2
NUMA node(s):          2
```

```
# 查看物理CPU个数
cat /proc/cpuinfo|grep "physical id"|sort -u|wc -l

# 查看每个物理CPU中core的个数(即核数)
cat /proc/cpuinfo|grep "cpu cores"|uniq

# 查看逻辑CPU的个数
cat /proc/cpuinfo|grep "processor"|wc -l

# 查看CPU的名称型号
cat /proc/cpuinfo|grep "name"|cut -f2 -d:|uniq
```

- 关系 CPU数量 = Thread(s) per core x Socket(s) x Core(s) per socket 

#### Linux查看某个进程运行在哪个逻辑CPU上

```
ps -eo pid,args,psr
#参数的含义：
pid  - 进程ID
args - 该进程执行时传入的命令行参数
psr  - 分配给进程的逻辑CPU

例子:
[~]# ps -eo pid,args,psr | grep nginx
9073 nginx: master process /usr/   1
9074 nginx: worker process         0
9075 nginx: worker process         1
9076 nginx: worker process         2
9077 nginx: worker process         3
13857 grep nginx                   3
```
## CPU亲和性(亲和力)

CPU affinity 是一种调度属性(scheduler property), 它可以将一个进程"绑定" 到一个或一组CPU上.

CPU affinity 使用位掩码(bitmask)表示

##  taskset命令

以checkpointer 进程为例, 查看进程号 26349
```
#ps -ef | grep checkpointer
postgres 26349 26302  0 3月15 ?       00:00:00 postgres: checkpointer 
```

查看进程 26349 可使用的cpu
```
taskset -pc 26349
pid 26349's current affinity list: 0-5
```

将进程 26349 绑定在cpu (2-3) 范围内, 之间用逗号分开。 绑定在固定的2号cpu上， taskset -pc 2,2 26349
```
#taskset -pc 2,3 26349
pid 26349's current affinity list: 0-5
pid 26349's new affinity list: 2,3
```

查看 26349 可使用的cpu
```
#taskset -pc 26349
pid 26349's current affinity list: 2,3
```

查看 26349 运行情况
``` 
#ps -eo pid,args,psr | grep checkpointer
26349 postgres: checkpointer        4
```


