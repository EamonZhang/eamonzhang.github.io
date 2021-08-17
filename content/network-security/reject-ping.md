---
title: "Linux 禁Ping"
date: 2020-01-02T09:26:15+08:00
draft: false
---

#### 修改配置文件/etc/sysctl.conf

在这个文件的最后添加一行:

```
net.ipv4.icmp_echo_ignore_all=1
 
（0 代表允许 1 代表禁止）
```

#### 执行sysctl -p 使新配置生效

