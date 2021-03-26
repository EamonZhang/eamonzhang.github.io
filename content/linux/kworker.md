---
title: "Kworker "
date: 2018-12-24T16:43:22+08:00
draft: false
---

#### 名字的意思

Kernel Worker

#### 什么时候有的

kworker是3.x内核引入的

#### 这么看

系统中查看

Linux下使用 ps -ef|grep kowrker

#### 显示的内容怎么看

显示的格式kworker/%u:%d%s

u：是unbound的缩写，代表没有绑定特定的CPU，kworker /u2:0中的 2 是 work_pool 的ID。

不带u的就是绑定特定cpu的workerq，它在init_workqueues中初始化，给每个cpu分配worker，如果该worker的nice小于0，说明它的优先级很高，所以就加了H属性。

具有负面价值的勤劳工人的名字后缀为'H'。

#### 有什么用

kworker 进程是内核工作进程，并且有很多进程是无害的。 
Linux系统中会将一个个的小任务分到不同的工作队列中，让工作队列里面的工人来完成 


内核工作线程可以做任何事情，例如一些随机的例子：

做页面缓存写回
处理某些种类的硬件事件 (如硬件中断,定时器，I / O等)
很多很多其他的东西
要知道任何kworker在做什么，你可以看看cat /proc/<kworker_pid>/stack。
