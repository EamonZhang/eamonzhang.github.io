---
title: "Keepalived 问题集"
date: 2018-11-05T10:08:23+08:00
draft: false
---

- Q1 

##### 问题描述 
```
  ip address associated with VRID 51 not present in MASTER advert : 10.1.7.58
```
其中 51 为 virtual_router_id 10.1.7.58 为虚拟IP

##### 可能原因
 
1. ntp 时间不同步

2. 局域网内 virtual_router_id 与其他集群配置冲突。 另外 router_id 主机标示，一般为hostname即可。

 解决方法： unicast_peer{ } 配置成单播模式
