---
title: "CPU频率管理"
date: 2021-04-08T09:44:39+08:00
draft: false
toc: false
categories: ["linux"]
tags: []
---

## 介绍

CPU动态节能技术用于降低服务器功耗，通过选择系统空闲状态不同的电源管理策略，可以实现不同程度降低服务器功耗，更低的功耗策略意味着CPU唤醒更慢对性能影响更大。对于对时延和性能要求高的应用，建议关闭CPU的动态调节功能，禁止 CPU休眠，并把CPU频率固定到最高。


## cpufreq的五种模式

cpufreq是一个动态调整cpu频率的模块


- performance 激进模式，频率固定在最高、耗能
- Userspace 主权交个用户应用管理
- powersave 节能模式，频率固定在最低
- ondemand  动态模式，系统根据负载状况进行动态调节。相当于变速车，有几个档位。
- conservative 动态模式，与ondemand不同的是，无级变速。平滑连续变化频率。

## 查看CPU 频率信息
```
#cpupower frequency-info
analyzing CPU 0:
  driver: acpi-cpufreq
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  maximum transition latency:  Cannot determine or is not supported.
  hardware limits: 1.50 GHz - 2.35 GHz
  available frequency steps:  2.35 GHz, 2.00 GHz, 1.50 GHz
  available cpufreq governors: conservative userspace powersave ondemand performance
  current policy: frequency should be within 1.50 GHz and 2.35 GHz.
                  The governor "conservative" may decide which speed to use
                  within this range.
  current CPU frequency: 1.50 GHz (asserted by call to hardware)
  boost state support:
    Supported: yes
    Active: yes
    Boost States: 0
    Total States: 3
    Pstate-P0:  2350MHz
    Pstate-P1:  2000MHz
    Pstate-P2:  1500MHz
```

## 可用模式
```
#cpupower frequency-info --governors
analyzing CPU 0:
  available cpufreq governors: conservative userspace powersave ondemand performance
```

## 现使用模式

```
#cpupower frequency-info --policy
analyzing CPU 0:
  current policy: frequency should be within 1.50 GHz and 2.35 GHz.
                  The governor "conservative" may decide which speed to use
                  within this range.
```

## 设置模式

```
cpupower frequency-set --governor performance
```

## CPU 信息监控

```
cpupower monitor
    |Nehalem                    || Mperf              || Idle_Stats                                                   
CPU | C3   | C6   | PC3  | PC6  || C0   | Cx   | Freq || POLL | C1-S | C1E- | C3-S | C6-S | C7s- | C8-S | C9-S | C10- 
   0|  0.00|  0.00|  0.00|  0.00|| 99.47|  0.53|  3809||  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   1|  0.36| 32.11|  0.00|  0.00||  1.40| 98.60|  3809||  0.00|  0.12|  1.87|  0.59| 33.68|  0.00| 62.41|  0.00|  0.00
   2|  0.67| 34.48|  0.00|  0.00||  1.18| 98.82|  3810||  0.00|  0.29|  0.54|  0.89| 36.17|  0.00| 61.00|  0.00|  0.00
   3|  0.00|  0.00|  0.00|  0.00|| 99.47|  0.53|  3809||  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
   4|  0.34| 26.12|  0.00|  0.00||  1.03| 98.97|  3809||  0.00|  0.01|  0.81|  0.42| 27.41|  0.10| 70.28|  0.00|  0.00
   5|  0.00|  0.00|  0.00|  0.00|| 99.47|  0.53|  3809||  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00|  0.00
```

## 效果

由 powersave 调整为 performance , cpu 利用率效果很显著

![image](/images/cpufreset.jpg)
