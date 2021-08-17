---
title: "Dumb Init"
date: 2018-11-01T11:43:35+08:00
draft: false
---

##### 基础概念

- 孤儿进程：一个父进程退出，而它的一个或多个子进程还在运行，那么那些子进程将成为孤儿进程。孤儿进程将被init进程(进程号为1)所收养，并由init进程对它们完成状态收集工作。
- 僵尸进程：一个进程使用fork创建子进程，如果子进程退出，而父进程并没有调用wait或waitpid获取子进程的状态信息，那么子进程的进程描述符仍然保存在系统中。

##### 背景知识

Linux来说，pid为1的进程，有着特殊的使命：

- 传递信号，确保子进程完全退出
- 等待子进程退出

容器化环境中，往往直接运行应用程序，而缺少初始化系统（如systemd、sysvinit等），所有会造成两个问题:

1 无法向其子进程传递信号，可能导致容器发送SIGTERM信号之后，父进程等待子进程退出。此时，如果父进程不能将信号传递到子进程，则整个容器就将无法正常退出，除非向父进程发送SIGKILL信号，使其强行退出。

2 init进程另一个任务，是需要接管子进程，确保其能正常退出。但是一般应用程序，不会考虑实现接管进程功能。 当应用程序进程在容器中运行时，其子进程创建的子进程，就有可能成为僵尸进程。


dumb-init解决了上述两个问题：向子进程代理发送信号和接管子进程。

##### dumb-init使用

要在容器中使用dumb-init，可以直接安装[deb](https://github.com/Yelp/dumb-init/releases)包，或者从源码构建。容器启动时，使用dumb-init作为初始进程，确保所有子进程都由dumb-init进程创建：

```
docker run my_container dumb-init python -c 'while True: pass'
```

##### 其他

除了在容器中使用之外，dumb-init也可以直接在shell脚本中使用。使用dumb-init作为shell的父进程，可以解决shell创建的子进程优雅退出问题。这种场景使用方式类似于supervisord或者daemontools，直接将脚本的改成#!/usr/bin/dumb-init /bin/sh即可。
