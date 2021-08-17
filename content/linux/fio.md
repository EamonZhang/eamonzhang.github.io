---
title: "fio 硬盘性能测试"
date: 2018-12-04T10:30:48+08:00
draft: false
---

#### 基本概念

使用FIO之前，首先要有一些SSD性能测试的基础知识。 包括线程，队列深度，Offset，同步异步，DirectIO，BIO。

##### 线程
线程指的是同时有多少个读或写任务在并行执行，一般来说，CPU里面的一个核心同一时间只能运行一个线程。如果只有一个核心，要想运行多线程，只能使用时间切片，每个线程跑一段时间片，所有线程轮流使用这个核心。Linux使用Jiffies来代表一秒钟被划分成了多少个时间片，一般来说Jiffies是1000或100，所以时间片就是1毫秒或10毫秒。

##### 同步
一般电脑发送一个读写命令到SSD只需要几微秒，但是SSD要花几百微秒甚至几毫秒才能执行完这个命令。如果发一个读写命令，然后线程一直休眠，等待结果回来才唤醒处理结果，这种叫做同步模式。可以想象，同步模式是很浪费SSD性能的，因为SSD里面有很多并行单元，比如一般企业级SSD内部有8-16个数据通道，每个通道内部有4-16个并行逻辑单元（LUN，Plane），所以同一时间可以执行32-256个读写命令。同步模式就意味着，只有其中一个并行单元在工作，暴殄天物。

##### 异步
为了提高并行性，大部分情况下SSD读写采用的是异步模式。就是用几微秒发送命令，发完线程不会傻傻的在那里等，而是继续发后面的命令。如果前面的命令执行完了，SSD通知会通过中断或者轮询等方式告诉CPU，CPU来调用该命令的回调函数来处理结果。这样的好处是，SSD里面几十上百个并行单元大家都能分到活干，效率暴增。

##### 队列深度
不过，在异步模式下，CPU不能一直无限的发命令到SSD。比如SSD执行读写如果发生了卡顿，那有可能系统会一直不停的发命令，几千个，甚至几万个，这样一方面SSD扛不住，另一方面这么多命令会很占内存，系统也要挂掉了。这样，就带来一个参数叫做队列深度。举个例子，队列深度64就是说，系统发的命令都发到一个大小为64的队列，如果填满了就不能再发。等前面的读写命令执行完了，队列里面空出位置来，才能继续填命令。

##### offset
一个SSD或者文件有大小，测试读写的时候设置Offset就可以从某个偏移地址开始测试。比如从offset=4G的偏移地址开始。

##### DirectIO
Linux读写的时候，内核维护了缓存，数据先写到缓存，后面再后台写到SSD。读的时候也优先读缓存里的数据。这样速度可以加快，但是一旦掉电缓存里的数据就没了。所以有一种模式叫做DirectIO，跳过缓存，直接读写SSD。

##### BIO
Linux读写SSD等块设备使用的是BIO，Block-IO，这是个数据结构，包含了数据块的逻辑地址LBA，数据大小和内存地址等。

#### 安装

[官网地址](https://github.com/axboe/fio)

```
./configure;make && make install
```

DEMO 如果缺失libaio驱动引擎可通过 yum install -y libaio-devel 安装后重新编译安装

```
fio -rw=randwrite  -ioengine=libaio -direct=1 -thread -numjobs=1  -iodepth=64 -filename=/data/1.data -size=10G \
  -name=job1 -offset=0MB -bs=4k -name=job2 -offset=10G -bs=16k \
  -output TestResult.log
```

简单说明

```
fio：软件名称。

-rw=randwrite：读写模式，randwrite是随机写测试，还有顺序读read，顺序写write，随机读randread，混合读写等。

-ioengine=libaio：libaio指的是异步模式，如果是同步就要用sync。

-direct=1：是否使用directIO。

-thread：使用pthread_create创建线程，另一种是fork创建进程。进程的开销比线程要大，一般都采用thread测试。

–numjobs=1：每个job是1个线程，这里用了几，后面每个用-name指定的任务就开几个线程测试。所以最终线程数=任务数* numjobs。

-iodepth=64：队列深度64.

-filename=/dev/sdb4：数据写到/dev/sdb4这个盘（块设备）。这里可以是一个文件名，也可以是分区或者SSD。

-size=10G：每个线程写入数据量是10GB。

-name=job1：一个任务的名字，名字随便起，重复了也没关系。这个例子指定了job1和job2，建立了两个任务，共享-name=job1之前的参数。-name之后的就是这个任务独有的参数。

-offset=0MB：从偏移地址0MB开始写。

-bs=4k：每一个BIO命令包含的数据大小是4KB。一般4KB IOPS测试，就是在这里设置。

-output TestResult.log：日志输出到TestResult.log。
```

结果查看 TestResult.log
``` 
job2: (g=0): rw=randwrite, bs=(R) 16.0KiB-16.0KiB, (W) 16.0KiB-16.0KiB, (T) 16.0KiB-16.0KiB, ioengine=libaio, iodepth=64
fio-3.12
Starting 2 threads
job1: Laying out IO file (1 file / 10240MiB)
job2: Laying out IO file (1 file / 20480MiB)

job1: (groupid=0, jobs=1): err= 0: pid=15506: Tue Dec  4 10:00:43 2018
  write: IOPS=20.6k, BW=80.6MiB/s (84.5MB/s)(10.0GiB/127037msec)                 IOPS　每秒IO次数 
    slat (usec): min=5, max=598750, avg=43.94, stdev=1586.09                     slat是发命令时间　min 最小　max 最大　avg 平均　stdev 方差
    clat (usec): min=43, max=603566, avg=3052.73, stdev=12877.32                 clat是命令执行时间
     lat (usec): min=54, max=603643, avg=3096.88, stdev=12981.71                 lat 总延迟
    clat percentiles (usec):
     |  1.00th=[   947],  5.00th=[  1483], 10.00th=[  1582], 20.00th=[  1680],
     | 30.00th=[  1729], 40.00th=[  1762], 50.00th=[  1795], 60.00th=[  1844],
     | 70.00th=[  2008], 80.00th=[  3130], 90.00th=[  3785], 95.00th=[  4490],
     | 99.00th=[ 10028], 99.50th=[ 30802], 99.90th=[219153], 99.95th=[312476],
     | 99.99th=[400557]
   bw (  KiB/s): min=  488, max=137212, per=43.04%, avg=71046.59, stdev=42517.77, samples=253
   iops        : min=  122, max=34303, avg=17761.47, stdev=10629.30, samples=253
  lat (usec)   : 50=0.01%, 100=0.08%, 250=0.17%, 500=0.28%, 750=0.25%
  lat (usec)   : 1000=0.31%
  lat (msec)   : 2=68.89%, 4=22.19%, 10=6.83%, 20=0.42%, 50=0.17%
  lat (msec)   : 100=0.11%, 250=0.23%, 500=0.07%, 750=0.01%
  cpu          : usr=4.48%, sys=43.73%, ctx=1226774, majf=0, minf=8
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=0,2621440,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64
job2: (groupid=0, jobs=1): err= 0: pid=15507: Tue Dec  4 10:00:43 2018
  write: IOPS=9368, BW=146MiB/s (153MB/s)(10.0GiB/69957msec)
    slat (usec): min=6, max=598777, avg=97.43, stdev=3165.14
    clat (usec): min=85, max=603836, avg=6720.55, stdev=25230.77
     lat (usec): min=111, max=603933, avg=6818.24, stdev=25431.27
    clat percentiles (usec):
     |  1.00th=[  1319],  5.00th=[  2245], 10.00th=[  2671], 20.00th=[  3064],
     | 30.00th=[  3326], 40.00th=[  3490], 50.00th=[  3621], 60.00th=[  3752],
     | 70.00th=[  4015], 80.00th=[  4359], 90.00th=[  5211], 95.00th=[  7767],
     | 99.00th=[122160], 99.50th=[202376], 99.90th=[371196], 99.95th=[383779],
     | 99.99th=[526386]
   bw (  KiB/s): min= 2816, max=308704, per=91.17%, avg=150510.73, stdev=91950.50, samples=139
   iops        : min=  176, max=19294, avg=9406.87, stdev=5746.90, samples=139
  lat (usec)   : 100=0.01%, 250=0.10%, 500=0.13%, 750=0.14%, 1000=0.18%
  lat (msec)   : 2=2.87%, 4=66.49%, 10=26.78%, 20=1.41%, 50=0.27%
  lat (msec)   : 100=0.41%, 250=0.90%, 500=0.29%, 750=0.02%
  cpu          : usr=2.51%, sys=25.66%, ctx=536398, majf=0, minf=2
  IO depths    : 1=0.1%, 2=0.1%, 4=0.1%, 8=0.1%, 16=0.1%, 32=0.1%, >=64=100.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.1%, >=64=0.0%
     issued rwts: total=0,655360,0,0 short=0,0,0,0 dropped=0,0,0,0
     latency   : target=0, window=0, percentile=100.00%, depth=64

Run status group 0 (all jobs):
  WRITE: bw=161MiB/s (169MB/s), 80.6MiB/s-146MiB/s (84.5MB/s-153MB/s), io=20.0GiB (21.5GB), run=69957-127037msec

Disk stats (read/write):
    md0: ios=4/3310805, merge=0/0, ticks=0/0, in_queue=0, util=0.00%, aggrios=1/1698898, aggrmerge=0/484, aggrticks=0/749089, aggrin_queue=749104, aggrutil=70.32%
  sdb: ios=2/1698906, merge=0/486, ticks=1/780800, in_queue=780980, util=69.54%
  sdc: ios=0/1698928, merge=0/464, ticks=0/661183, in_queue=661093, util=69.63%
  sdd: ios=2/1698888, merge=0/487, ticks=1/798317, in_queue=798188, util=69.86%
  sde: ios=0/1698873, merge=0/502, ticks=0/756057, in_queue=756156, util=70.32%

```

[更多详解英文](https://tobert.github.io/post/2014-04-17-fio-output-explained.html) 
[更多详解中文](https://www.cnblogs.com/zhangeamon/p/7446814.html)

#### 配置文件方式

vi fio.conf

```
[global]
  ioengine=libaio ;同步sync 异步libaio 
  rw=randwrite ;randwrite randread wite read randrw
  direct=1
  thread
  numjobs=1
  iodepth=64 
  filename=/data/1.data ;测试文件，块设备
  size=10G
;--start jobs
[job1]
  name=job1
  offset=0MB 
  bs=4k
[job2]
  name=job2
  offset=10G 
  bs=16k
;--end jobs
```

运行
```
$fio fio.conf 
```
