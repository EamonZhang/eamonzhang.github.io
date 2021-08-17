---
title: "linux time 命令"
date: 2019-12-10T09:04:09+08:00
draft: false
---

Linux time命令的用途，在于量测特定指令执行时所需消耗的时间及系统资源等资讯。

例如 CPU 时间、记忆体、输入输出等等。需要特别注意的是，部分资讯在 Linux 上显示不出来。这是因为在 Linux 上部分资源的分配函式与 time 指令所预设的方式并不相同，以致于 time 指令无法取得这些资料。

语法

```
time [options] COMMAND [arguments]
```

参数：

-o 或 --output=FILE：设定结果输出档。这个选项会将 time 的输出写入 所指定的档案中。如果档案已经存在，系统将覆写其内容。

-a 或 --append：配合 -o 使用，会将结果写到档案的末端，而不会覆盖掉原来的内容。

-f FORMAT 或 --format=FORMAT：以 FORMAT 字串设定显示方式。当这个选项没有被设定的时候，会用系统预设的格式。不过你可以用环境变数 time 来设定这个格式，如此一来就不必每次登入系统都要设定一次。

time 指令可以显示的资源有四大项，分别是：

- Time resources

- Memory resources

- IO resources

- Command info

##### 举例

```
# time date
 Sun Mar 26 22:45:34 GMT-8 2006

real    0m0.136s
user    0m0.010s
sys     0m0.070s
#

在以上实例中，执行命令"time date"(见第1行)。
系统先执行命令"date"，第2行为命令"date"的执行结果。
第3-6行为执行命令"date"的时间统计结果，其中第4行"real"为实际时间，第5行"user"为用户CPU时间，第6行"sys"为系统CPU时间。
以上三种时间的显示格式均为MMmNN[.FFF]s。
利用下面的指令
```
