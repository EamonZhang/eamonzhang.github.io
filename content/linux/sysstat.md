---
title: "Linux 系统性能检测"
date: 2018-12-06T14:58:27+08:00
draft: false
---

##### 整体篇
---
安装

```
yum install sysstat -y
```


- top
- htop
- atop
- vmstat -wt 1
- dstat

#### 内存篇
---

由于Linux 内存的占用属于饥饿式，所以看到的结果只能作为参考

cat /proc/meminfo 

[结果具体含义](linux/meminfo/) 

#### I/O 篇

整体io情况
```
iostat -dmx 1
Linux 3.10.0-862.14.4.el7.x86_64 (rjyd) 	2018年12月06日 	_x86_64_	(40 CPU)

Device:         rrqm/s   wrqm/s     r/s     w/s    rMB/s    wMB/s avgrq-sz avgqu-sz   await r_await w_await  svctm  %util
sda               0.00     0.05    0.06    0.11     0.00     0.00    53.87     0.00    1.35    0.60    1.78   0.23   0.00
sdb               0.00     0.02    0.08    6.65     0.00     0.07    21.00     0.00    0.49    0.42    0.50   0.26   0.17
```
[详细说明](https://blog.csdn.net/shaochenshuo/article/details/76212566)

哪些进程占用
```
iotop -oP
```

```
pidstat -d 1
```


#### cpu 篇

```
mpstat 1
Linux 3.10.0-862.14.4.el7.x86_64 (rjyd) 	2018年12月06日 	_x86_64_	(40 CPU)

15时02分19秒  CPU    %usr   %nice    %sys %iowait    %irq   %soft  %steal  %guest  %gnice   %idle
15时02分20秒  all    0.00    0.00    0.02    0.00    0.00    0.00    0.00    0.00    0.00   99.98
^C
Average:     all    0.00    0.00    0.02    0.00    0.00    0.00    0.00    0.00    0.00   99.98

```

```
sar 1
Linux 3.10.0-862.14.4.el7.x86_64 (rjyd) 	2018年12月06日 	_x86_64_	(40 CPU)

15时03分14秒     CPU     %user     %nice   %system   %iowait    %steal     %idle
15时03分15秒     all      0.03      0.00      0.00      0.00      0.00     99.98
15时03分16秒     all      0.03      0.00      0.05      0.03      0.00     99.90
15时03分17秒     all      0.03      0.00      0.00      0.00      0.00     99.97
15时03分18秒     all      0.00      0.00      0.03      0.00      0.00     99.98
15时03分19秒     all      0.00      0.00      0.03      0.00      0.00     99.97
^C

15时03分19秒     all      0.00      0.00      0.20      0.00      0.00     99.80
Average:        all      0.01      0.00      0.02      0.00      0.00     99.96

```

##### 网络篇 

检测网络中与其他节点的通信流量信息
```
yum install iftop
```

多个网卡时指定检测的网卡
```
sudo iftop -i wlan0
```
h 切换帮助界面。
n 是否解析域名。
s 切换源地址的显示，d 则切换目的地址的显示。
S 是否显示端口号。
N 是否解析端口；若关闭解析则显示端口号。
t 切换文本显示界面。默认的显示方式需要 ncurses。我个人认为图 1 的显示方式在组织性和可读性都更加良好。
p 暂停显示更新。
q 退出程序

只查看个某个IP之间的流量　-F 过滤
```
iftop -F  123.125.115.110/32
```

检测本机软件使用流量情况

```
yum install nethogs
```

统计流量使用情况

```
yum install vnstat
```
[网络监控工具](https://linux.cn/article-9284-1.html)


系统性能诊断

[perf](https://github.com/digoal/blog/blob/master/201611/20161127_01.md)

##### 扩展阅读
https://github.com/brendangregg/perf-tools

http://linuxperf.com/?page_id=2
