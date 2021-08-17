---
title: "存储设备几个物理概念"
date: 2021-03-29T16:16:38+08:00
draft: false
toc: false
categories: ["linux"]
---

## 硬盘

 - HDD 机械硬盘
 - SSD 固态硬盘

## 物理接口

接口的物理形态

 - SATA
 - mSTATA 迷你SATA
 - m.2 曾用名NG(NEXT GERNERATION)   
 根据宽度分为(m.2 2242 2260 2280) 
 - u.2 统一了 SATA ，PCIe，SAS 接口
 - AIC ADD IN CARD 标准PCIe金手指

## 通信协议

数据通信逻辑协议标准

 - AHCI
 - SAS
 - NVME (Non-Volatile Memory Host Controller Interface)

## 总线标准

数据总线标准,硬盘与CPU通过总线传输数据

 - SATA
 - PCIE

在传统SATA硬盘中，当我们进行数据操作时，数据会先从硬盘读取到内存，再将数据提取至CPU内部进行计算，计算后写入内存，存储至硬盘中；

PCI-E就不一样了，数据直接通过总线与CPU直连，省去了内存调用硬盘的过程，传输效率与速度都成倍提升。


## 发展演变 
 
HDD和早期SSD绝大多数都是使用SATA接口，采用AHCI（Advanced Host Controller Interface），它是由intel联合多家公司研发的系统接口标准。

AHCI支持NCQ（Native Command Queuing）功能和热插拔技术。NCQ最大深度为32，即主机可以发最多32条命令给HDD或者SSD执行，跟之前硬盘只能一条命令一条命令执行相比，硬盘性能大幅提升。

这在HDD时代，或者SSD早期，AHCI协议和SATA接口足够满足系统性能需求，因为整个系统性能瓶颈在硬盘端（低速，高延时），而不是在协议和接口端。

然而，随着SSD技术的飞速发展，SSD盘的性能飙升，底层闪存带宽越来越宽，介质访问延时越来越低，系统性能瓶颈已经由下转移到上面的接口和协议处了。AHCI和SATA已经不能满足高性能和低延时SSD的需求，因此SSD迫切需要自己更快、更高效的协议和接口。

![images](/images/hard_store02.jpg) 
## 搭配关系

![images](/images/hard_store01.jpg) 
