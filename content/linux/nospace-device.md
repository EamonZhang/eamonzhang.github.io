---
title: "no space left on device"
date: 2019-01-09T08:32:26+08:00
draft: false
---

#### 问题描述

 Linux 系统中出现磁盘空间不足错误： 

- No space left on device …
- 在linux环境下，用vi打开某文件时，提示Write error in swap file

#### 原因分析

导致该问题的可能原因包括：

- 磁盘分区空间使用率达到百分之百 
- 磁盘分区inode使用率达到百分之百 
- 僵尸文件：已删除文件因句柄被占用未释放导致相应空间未释放 

#### 解决方法

##### 磁盘分区空间使用率达到百分之百 

查看磁盘使用情况
```
 df -h
文件系统        容量  已用  可用 已用% 挂载点
/dev/vda2        91G   21G   70G   23% /
devtmpfs        3.9G     0  3.9G    0% /dev
tmpfs           3.9G   56K  3.9G    1% /dev/shm
tmpfs           3.9G   49M  3.8G    2% /run
tmpfs           3.9G     0  3.9G    0% /sys/fs/cgroup
/dev/vda3      1014M   33M  982M    4% /home
/dev/vda1      1014M  210M  805M   21% /boot
tmpfs           783M     0  783M    0% /run/user/0
```

进入对应目录找出文件占用情况
```
cd /home

du -sh * 
```
根据实际情况删除对应的文件或扩容磁盘

##### 磁盘分区inode使用率达到百分之百 

关于linux中[inode介绍](http://www.ruanyifeng.com/blog/2011/12/inode.html)

查看磁盘inode情况
```
df -i
文件系统          Inode 已用(I)  可用(I) 已用(I)% 挂载点
/dev/vda2      47249920  110191 47139729       1% /
devtmpfs         998480     382   998098       1% /dev
tmpfs           1001188       2  1001186       1% /dev/shm
tmpfs           1001188     534  1000654       1% /run
tmpfs           1001188      16  1001172       1% /sys/fs/cgroup
/dev/vda3        524288      10   524278       1% /home
/dev/vda1        524288     341   523947       1% /boot
tmpfs           1001188       1  1001187       1% /run/user/0
```

进入对应目录找出文件使用inode情况
```
cd /home 
for i in *; do echo $i; find $i | wc -l; done
```

根据实际情况删除对应的文件或扩容文件。

如果inode数量与磁盘的容量比例在实际的应用中严重失调的情况下，如磁盘剩余空间很大但是inode已经耗尽时也可修改inode数量。

修改inode方法:

1 卸载磁盘
```
umount /home 
```
2 重新格式化磁盘，在格式化时使用 -N 指定inode数量 

```
mkfs.ext4 /dev/sdb -N 2589666666
```

3 挂在磁盘 

```
mount /dev/sdb /home
```
或修改/etc/fstab ,开机自动挂载。

4 查看inode 

ext3 ext4 文件格式

```
dumpe2fs -h /dev/sdb
```

xfs 文件格式对应命令

```
xfs_info 
xfs_growfs
```

##### 僵尸文件  

未被清除句柄的僵死文件。这些文件实际上已经被删除，但是有服务程序在使用这些文件，导致这些文件一直被占用，无法释放磁盘空间。如果这些文件过多，会占用很大的磁盘空间。 

查看僵尸文件情况 
```
lsof | grep delete | more
```

如果遇到如下情况
```
lsof: no pwd entry for UID 105

ps -U 105 查看是哪个用户

```

重启对应的服务 



