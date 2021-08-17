---
title: "Access Modify Change 三种时间戳"
date: 2018-12-20T13:56:24+08:00
draft: false
---

#### 三种时间对应关系
- 访问时间  Access  atime  
- 修改时间  Modify  mtime
- 状态改动时间  Change ctime   

#### 如何查看文件文件的三种时间戳
```
stat filename
```

#### 三种时间戳的解释

- 访问时间：读一次文件的内容，这个时间就会更新。比如more、cat等命令。ls、stat命令不会修改atime

- 修改时间：修改时间是文件内容最后一次被修改的时间。比如：vim操作后保存文件。ls -l列出的就是这个时间

- 状态改动时间。是该文件的inode节点最后一次被修改的时间，通过chmod、chown命令修改一次文件属性，这个时间就会更新。

#### 应用举例 查看数据库的建立时间

数据库的oid
```
select  oid , datname from pg_database ;
  oid  |   datname   
-------+-------------
 13806 | postgres
     1 | template1
 13805 | template0
 16629 | timescaledb
 16646 | normaldb
 16659 | pgwatch2
 26557 | awr
 42902 | pipelinedb
(8 行记录)

```
对应的存放位置
```
ll base/
总用量 216
drwx------ 2 postgres postgres 12288 12月 19 00:54 1
drwx------ 2 postgres postgres  8192 12月 17 12:45 13805
drwx------ 2 postgres postgres  8192 12月 15 02:32 13806
drwx------ 2 postgres postgres 36864 12月 19 00:55 16629
drwx------ 2 postgres postgres 32768 12月 20 11:23 16646
drwx------ 2 postgres postgres  8192 12月 17 12:44 16659
drwx------ 2 postgres postgres 12288 12月 15 02:33 26557
drwx------ 2 postgres postgres 20480 12月 18 22:11 42902
drwx------ 2 postgres postgres     6 12月 20 14:03 pgsql_tmp

```
查看时间
```
 stat PG_VERSION 
  文件："PG_VERSION"
  大小：3         	块：8          IO 块：4096   普通文件
设备：fd02h/64770d	Inode：1740036     硬链接：1
权限：(0600/-rw-------)  Uid：(   26/postgres)   Gid：(   26/postgres)
最近访问：2018-12-20 10:56:55.671680658 +0800
最近更改：2018-11-30 10:46:14.736271487 +0800
最近改动：2018-11-30 10:46:14.736271487 +0800
创建时间：-
```

禁用atime
```
cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Tue Jul 10 10:13:30 2018
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=ef850a59-8018-45f0-ad9e-54fa0b17d5dd /                       xfs     noatime,nodiratime        0 0
UUID=bece2732-9d2c-4b3b-9818-1ea939f45db8 /boot                   xfs     defaults        0 0
UUID=9d880ea3-0a7a-4d73-aeab-e972ea2af2f6 /home                   xfs     defaults        0 0
UUID=c63df49f-85f3-4cf8-b69c-bc10808b69e1 swap                    swap    defaults        0 0

```
