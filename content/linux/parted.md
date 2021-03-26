---
title: "linux分区命令parted的用法"
date: 2019-12-27T17:13:00+08:00
draft: false
---

##### linux分区命令parted的用法

###### parted的适用场景
创建操作大于2T的分区
一般情况下，我们都是选择使用fdisk工具来进行分区，但是目前在实际生产环境中使用的磁盘空间越来越大，呈TiB级别增长；而常用的fdisk这个工具对分区是有大小限制的，它只能划分小于2T的磁盘，所以在划大于2T磁盘分区的时候fdisk就无法满足要求了；这个时候有2个方法，其一是通过卷管理来实现，其二就是通过parted工具来实现对GPT磁盘进行分区操作；这里我们采用parted的方法来实现管理。

###### 环境

操作系统
CentOS 7.5
磁盘信息
待管理磁盘
/dev/sdb
磁盘总大小
18T
分区需求
将整个/dev/sdb划分到同一个分区里，并挂载到**/gfsdata01目录下。

###### 选择操作磁盘

parted命令后跟上欲操作磁盘的名字即可选择此设备进行操作。

```
[root@kvm ~]# parted /dev/sdb
GNU Parted 3.1
Using /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
```
新建磁盘标签类型为GPT

因为parted命令只能针对gpt格式的磁盘进行操作，所以这里必须将新建的磁盘标签格式设为gpt。

```
(parted) mklabel gpt

```
分区 命令格式

```
mkpart PART-TYPE [FS-TYPE] START END
PART-TYPE(分区类型)
primary
主分区
logical
逻辑分区
extended
扩展分区
FS-TYPE(文件系统类型)
ext4
ext3
ext2
xfs
其他......
START
设定磁盘分区起始点；可以为0，numberMiB/GiB/TiB；
0
设定当前分区的起始点为磁盘的第一个扇区；
1G
设定当前分区的起始点为磁盘的1G处开始；
END
设定磁盘分区结束点；
-1
设定当前分区的结束点为磁盘的最后一个扇区；
10G
设定当前分区的结束点为磁盘的10G处；
将/dev/sdb整个空间分给同一个分区
```

```
(parted) mkpart primary 0 -1                                              
Warning: The resulting partition is not properly aligned for best performance.
Ignore/Cancel? I
(parted) p                                                                
Model: AVAGO AVAGO (scsi)
Disk /dev/sdb: 18.0TB
Sector size (logical/physical): 512B/4096B
Partition Table: gpt
Disk Flags: 

Number  Start   End     Size    File system  Name     Flags
 1      17.4kB  18.0TB  18.0TB               primary
(parted) q                                                                
Information: You may need to update /etc/fstab.
```

##### 格式化分区

因为整个/dev/sdb只分了一个区，则这个分区名默认会分配为/dev/sdb1；使用mkfs命令将/dev/sdb1分区格式化为ext4。

```
[root@kvm ~]# mkfs -t ext4 /dev/sdb1                 
mke2fs 1.42.9 (28-Dec-2013)
/dev/sdb1 alignment is offset by 244736 bytes.
This may result in very poor performance, (re)-partitioning suggested.
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=64 blocks, Stripe width=64 blocks
274659328 inodes, 4394530311 blocks
219726515 blocks (5.00%) reserved for the super user
First data block=0
134111 block groups
32768 blocks per group, 32768 fragments per group
2048 inodes per group
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000, 214990848, 512000000, 550731776, 644972544, 1934917632, 
        2560000000, 3855122432

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done
```

##### 设定分区label(非必要)

```
[root@kvm ~]# e2label /dev/sdb1 /gfsdata01
```

##### 创建挂载目录

```
[root@kvm ~]# mkdir /gfsdata01
``` 
###### 临时挂载分区

```
[root@kvm ~]# mount /dev/sdb1 /gfsdata01
[root@kvm ~]# df -h
Filesystem                   Size  Used Avail Use% Mounted on
/dev/mapper/root_vg-lv_root   89G  2.6G   82G   4% /
devtmpfs                     126G     0  126G   0% /dev
tmpfs                        126G     0  126G   0% /dev/shm
tmpfs                        126G  2.0M  126G   1% /run
tmpfs                        126G     0  126G   0% /sys/fs/cgroup
/dev/sda1                    976M  216M  694M  24% /boot
/dev/sda7                     99G   61M   94G   1% /home
/dev/sda8                     62G   53M   59G   1% /tmp
/dev/sda6                     99G   61M   94G   1% /app
tmpfs                         26G     0   26G   0% /run/user/1014
tmpfs                         26G     0   26G   0% /run/user/0
/dev/sdb1                     17T   20K   16T   1% /gfsdata01
```

###### 开机自动挂载(永久挂载)

即修改/etc/fstab文件。

```
[root@kvm ~]# blkid

```
