---
title: "Backgroud Writer 进程"
date: 2021-03-31T15:13:50+08:00
draft: false
toc: false
categories: ["postgres"]
tags: []
---

## 主要作用

负责将shared buffer 中的内容刷写到磁盘中，9.1版之后部分内容交给checkpoint完成。


## 参数配置
```
# - Background Writer -

#bgwriter_delay = 200ms                 # 10-10000ms between rounds
#bgwriter_lru_maxpages = 100            # 0-1000 max buffers written/round
#bgwriter_lru_multiplier = 2.0          # 0-10.0 multiplier on buffers scanned/round
#bgwriter_flush_after = 512kB           # measured in pages, 0 disables
```

- bgwriter_delay 
两次写入任务之间的睡眠间隔时间

- bgwriter_lru_maxpages 
每次bgwriter任务写buffer的最大page数，一旦达到这个数量，bgwriter就结束任务开始休息，也就是说bgwriter休眠200毫秒，然后写入几十毫秒就又开始了休息 

- bgwriter_lru_multiplier multiplier(乘数) 
用于评估下一次写任务的数量，其依据是这段时间内新申请的buffer数量的倍数，如果这个参数乘以新增加buffer分配的数量后小于bgwriter_lru_maxpages，那么有可能下一个写任务的数量会小于预期的写入量。将这个参数调大，会增加bgwriter回写脏块的数量，不过会增加写IO压力，将这个参数调小，可以降低写IO压力，不过可能导致backend写脏块的比例增加。不同负载的系统中，这个参数的值应该是需要做调整的，而不是只是用缺省值2。如果你发现你的系统的写IO压力还不大，但是 bgwriter写比例偏低，backend写比例偏高，那么尝试加大这个参数还是有效的

- bgwriter_flush_after 写入量超过阀值进行后进行同步刷 
