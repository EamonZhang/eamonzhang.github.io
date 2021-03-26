---
title: "内核设置"
date: 2019-11-26T10:14:41+08:00
draft: false
---

##### 参数vm.dirty_ratio和vm.dirty_background_ratio

https://lonesysadmin.net/2013/12/22/better-linux-disk-caching-performance-vm-dirty_ratio/

文件缓存是一项重要的性能改进，在大多数情况下，读缓存在绝大多数情况下是有益无害的（程序可以直接从RAM中读取数据）。写缓存比较复杂，Linux内核将磁盘写入缓存，过段时间再异步将它们刷新到磁盘。这对加速磁盘I/O有很好的效果，但是当数据未写入磁盘时，丢失数据的可能性会增加。

当然，也存在缓存被写爆的情况。还可能出现一次性往磁盘写入过多数据，以致使系统卡顿。这些卡顿是因为系统认为，缓存太大用异步的方式来不及把它们都写进磁盘，于是切换到同步的方式写入。

这些都是可控制的选项，根据工作负载和数据，你可以决定如何设置它们：

```
$ sysctl -a | grep dirty
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 10
vm.dirty_bytes = 0
vm.dirty_ratio = 20
vm.dirty_writeback_centisecs = 500
vm.dirty_expire_centisecs = 3000
vm.dirtytime_expire_seconds = 43200
```

vm.dirty_background_ratio 是内存可以填充脏数据的百分比。这些脏数据稍后会写入磁盘，pdflush/flush/kdmflush这些后台进程会稍后清理脏数据。比如，我有32G内存，那么有3.2G的脏数据可以待着内存里，超过3.2G的话就会有后台进程来清理。

vm.dirty_ratio是可以用脏数据填充的绝对最大系统内存量，当系统到达此点时，必须将所有脏数据提交到磁盘，同时所有新的I/O块都会被阻塞，直到脏数据被写入磁盘。这通常是长I/O卡顿的原因，但这也是保证内存中不会存在过量脏数据的保护机制。

vm.dirty_background_bytes和vm.dirty_bytes是另一种指定这些参数的方法。如果设置_bytes版本，则_ratio版本将变为0，反之亦然。

vm.dirty_expire_centisecs 指定脏数据能存活的时间。在这里它的值是30秒。当 pdflush/flush/kdmflush 在运行的时候，他们会检查是否有数据超过这个时限，如果有则会把它异步地写到磁盘中。毕竟数据在内存里待太久也会有丢失风险。

vm.dirty_writeback_centisecs 指定多长时间 pdflush/flush/kdmflush 这些进程会唤醒一次，然后检查是否有缓存需要清理。

可以通过下面方式看内存中有多少脏数据：一共有106页的脏数据

```
$ cat /proc/vmstat | egrep "dirty|writeback"
nr_dirty 106
nr_writeback 0
nr_writeback_temp 0
nr_dirty_threshold 3934012
nr_dirty_background_threshold 1964604
```

###### 方法1：减少缓存

在很多情况下，我们有快速的磁盘子系统，它们有自己的大电池支持的NVRAM缓存，所以将东西保存在系统页面缓存中是有风险的。让我们尝试以更及时的方式向磁盘发送I/O，并减少本地操作系统(借用服务行业的话)“陷入困境”的机会。为了做到这一点，我们减小/etc/sysctl.conf中vm.dirty_background_ratio和vm.dirty_ratio的数值，并执行sysctl -p命令:

```
vm.dirty_background_ratio = 5
vm.dirty_ratio = 10
```

这是基于Linux的虚拟机管理程序的典型方法。不建议将这些参数设置为0，一些后台I/O可以很好地将应用程序性能与磁盘阵列在SAN(“峰值”)上的较短时间的较高延迟解耦。

###### 方法2：增加缓存

在某些情况下，显著提高缓存对性能有积极的影响。在这些情况下，Linux客户机上包含的数据不是关键的，可能会丢失，而且应用程序通常会重复或以可重复的方式写入相同的文件。理论上，通过允许内存中存在更多脏页，你将在缓存中一遍又一遍地重写相同的块，只需要每隔一段时间向实际磁盘写一次。为此，我们提出了以下参数:

```
vm.dirty_background_ratio = 50
vm.dirty_ratio = 80
```

有时候还会提高vm.dirty_expire_centisecs 这个参数的值，来允许脏数据更长时间地停留。除了增加数据丢失的风险之外，如果缓存已满并需要同步，还会有长时间I/O卡顿的风险，因为在大型虚拟机缓存中有大量数据。

###### 方法3：增减都用

有时候系统需要应对突如其来的高峰数据，它可能会拖慢磁盘。比如说：每小时或者午夜进行批处理作业、在Raspberry Pi上写SD卡等等。这种情况下，我们可以允许大量的写I/O存储在缓存中，这样后台刷新操作就可以慢慢异步处理它:

```
vm.dirty_background_ratio = 5
vm.dirty_ratio = 80
```

这个时候，系统后台进程在脏数据达到5%时就开始异步清理，但在80%之前系统不会强制同步写磁盘。在此基础上，你只需要调整RAM和vm.dirty_ratio大小以便能缓存所有的写数据。当然，磁盘上的数据一致性也存在一定风险。

###### 总结

无论你选择哪种方式，都应该始终收集数据来支持你的更改，并帮助你确定是在改进还是变得更糟。我们可以从应用程序，/proc/vmstat, /proc/meminfo, iostat, vmstat 以及/proc/sys/vm里面获得大量有用信息。

##### 参数overcommit_memory

0：表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。

1：表示内核允许分配所有的物理内存，而不管当前的内存状态如何。

2： 表示内核允许分配超过所有物理内存和交换空间总和的内存。


