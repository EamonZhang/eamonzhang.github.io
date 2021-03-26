---
title: "Ubuntu 20.04 网络配置"
date: 2020-09-21T16:48:24+08:00
draft: false
---

##### 配置

vim /etc/netplan/00-installer-config.yaml 
```
# This is the network config written by 'subiquity'
network:
  ethernets:
    enp2s0:
      addresses:
      - 192.168.6.111/24
      gateway4: 192.168.6.1
      nameservers: 
        addresses: [119.29.29.29]
  version: 2
```

##### 生效
```
netplan apply
```
