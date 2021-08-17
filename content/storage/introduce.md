---
title: "云存储介绍"
date: 2018-12-07T11:04:12+08:00
draft: false
---

#### 对象存储(oss)

适用于大量的小文件，RESFULL接口方式存储读取迅速,不能修改，不用担心元数据过大问题。通常的架构为使用其他的数据库软件如(Hbase,ES) 等来存放管理元数据。

swift minio

#### 块存储

这种接口通常以QEMU Driver或者Kernel Module的方式存在，这种接口需要实现Linux的Block Device的接口或者QEMU提供的Block Driver接口，如Sheepdog，AWS的EBS，青云的云硬盘和阿里云的盘古系统，还有Ceph的RBD(RBD是Ceph面向块存储的接口)。
理解成一块硬盘

ceph

#### 文件存储

支持POSIX接口，对应的传统的文件系统有Ext3、Ext4等，与传统文件系统的区别在于分布式存储提供了并行化的能力，如Ceph的CephFS，但是有时候又会把GFS，HDFS这种非POSIX接口的类文件存储接口归入此类
理解成格式化后的文件

glusterfs  
fastfs

