---
title: "Cgroup Namespaces"
date: 2018-11-02T14:17:44+08:00
draft: false
---

#### cgroup 实现资源限额 

cgroup 全称 Control Group。Linux 操作系统通过 cgroup 可以设置进程使用 CPU、内存 和 IO 资源的限额。

在启动容器时可使用参数 docker run --blkio-weight-device --cpu-shares --memory 等 。

```
ll /sys/fs/cgroup/cpu/docker/
ll /sys/fs/cgroup/memory/docker 
ll /sys/fs/cgroup/blkio/docker
```

#### namespace 实现资源隔离 

##### Mount 
Mount namespace 让容器看上去拥有整个文件系统。
容器有自己的 / 目录，可以执行 mount 和 umount 命令。当然我们知道这些操作只在当前容器中生效，不会影响到 host 和其他容器。

##### UTS hostname  

简单的说，UTS namespace 让容器有自己的 hostname。 默认情况下，容器的 hostname 是它的短ID，可以通过 -h 或 --hostname 参数设置。
##### IPC
IPC namespace 让容器拥有自己的共享内存和信号量（semaphore）来实现进程间通信，而不会与 host 和其他容器的 IPC 混在一起。

##### PID
<br/>
##### Network
Network namespace 让容器拥有自己独立的网卡、IP、路由等资源

##### User
