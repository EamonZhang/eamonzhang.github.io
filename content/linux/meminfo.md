---
title: "meminfo Linux 内存信息"
date: 2019-01-08T09:04:15+08:00
draft: false
---

#### 介绍

/proc/meminfo是了解Linux系统内存使用状况的主要接口，我们最常用的”free”、”vmstat”等命令就是通过它获取数据的 

#### 内容解读

```
cat /proc/meminfo 
MemTotal:        8009504 kB  除了bios ，kernel本身占用的内存以外，可以被kernel所分配的内存。一般这个值固定不变。  
MemFree:         2385828 kB  未被使用的内存
MemAvailable:    4741232 kB  该值为系统估计值
Buffers:               0 kB  给文件做缓存大小
Cached:          4701848 kB  内存使用
SwapCached:        35516 kB  交换分区使用
Active:          4175652 kB  在活跃使用中的缓冲或高速缓冲存储器页面文件的大小，除非非常必要否则不会被移作他用. 
Inactive:        1037948 kB  在不经常使用中的缓冲或高速缓冲存储器页面文件的大小，可能被用于其他途径.
Active(anon):    2175852 kB
Inactive(anon):   570728 kB
Active(file):    1999800 kB
Inactive(file):   467220 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       1048572 kB
SwapFree:         904956 kB
Dirty:               708 kB 等待被写回到磁盘的内存大小。
Writeback:             0 kB 正在被写回到磁盘的内存大小。
AnonPages:        482164 kB 
Mapped:          1991344 kB
Shmem:           2234828 kB
Slab:             247824 kB
SReclaimable:     194368 kB
SUnreclaim:        53456 kB
KernelStack:        6976 kB
PageTables:        63760 kB  管理内存分页页面的索引表的大小。
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     5053324 kB
Committed_AS:    5182268 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       23696 kB
VmallocChunk:   34359707388 kB
HardwareCorrupted:     0 kB
AnonHugePages:     65536 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0    Hugepages在/proc/meminfo中是被独立统计的，与其它统计项不重叠
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      133084 kB
DirectMap2M:     8255488 kB

```
