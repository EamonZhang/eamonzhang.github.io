---
title: "mdadm 软Raid 管理"
date: 2018-12-03T13:39:39+08:00
draft: false
---

#### 背景

mdadm是linux下用于创建和管理软件RAID的命令，是一个模式化命令。但由于现在服务器一般都带有RAID阵列卡，并且RAID阵列卡也很廉价，且由于软件RAID的自身缺陷（不能用作启动分区、使用CPU实现，降低CPU利用率），因此在生产环境下并不适用。但为了学习和了解RAID原理和管理，因此仍然进行一个详细的讲解：

#### 安装

```
yum install mdadm -y
```

#### 组建raid

```
组装raid 
mdadm -C /dev/md0 -a yes -n 4 -l 10 /dev/sdb /dev/sdc /dev/sdd /dev/sde

说明 : 
专用选项：
-l 级别
-n 设备个数
-a {yes|no} 自动为其创建设备文件
-c 指定数据块大小（chunk）
-x 指定空闲盘（热备磁盘）个数，空闲盘（热备磁盘）能在工作盘损坏后自动顶替
注意：创建阵列时，阵列所需磁盘数为-n参数和-x参数的个数和
```

```
查看状态, 组装进度等
mdadm -D /dev/md0

也可以通过mdstat查看状态
cat /proc/mdstat

Personalities : [raid10] 
md127 : active raid10 sdd[2] sda[3] sdb[0] sdc[1]
      999950336 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      bitmap: 1/8 pages [4KB], 65536KB chunk

unused devices: <none>
```
```
如下信息说明： 提示软raid 不能作为启动分区
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
```



#### 管理

选项：-a(--add)，-d(--del),-r(--remove),-f(--fail)

##### 模拟损坏  
```
mdadm /dev/md1 -f /dev/sdb5
```
##### 移除损坏的磁盘  
```
mdadm /dev/md1 -r /dev/sdb5
```
##### 添加新的硬盘到已有阵列   
```
mdadm /dev/md1 -a /dev/sdb7     
注意:   
1 新增加的硬盘需要与原硬盘大小一致    
2 如果原有阵列缺少工作磁盘（如raid1只有一块在工作，raid5只有2块在工作），这时新增加的磁盘直接变为工作磁盘，如果原有阵列工作正常，则新增加的磁盘为热备磁盘。 
```
##### 重新添加
```
mdadm /dev/md1 --re-add /dev/sdb7
```
##### 停止阵列  
```
选项：-S = --stop
mdadm -S /dev/md1
```
##### 启动阵列   
```
选项：-R= --run
mdadm -R  /dev/md1
```

[详情](https://www.cnblogs.com/zhangeamon/p/6866429.html)



```
For Manage mode:
       -t, --test
              Unless a more serious error occurred, mdadm will exit with a status of 2 if no changes were made to the array and 0 if at least one change was made.  This can be useful when an indirect specifier such as missing, detached or faulty  is  used  in
              requesting an operation on the array.  --test will report failure if these specifiers didn't find any match.

       -a, --add
              hot-add  listed devices.  If a device appears to have recently been part of the array (possibly it failed or was removed) the device is re-added as described in the next point.  If that fails or the device was never part of the array, the device
              is added as a hot-spare.  If the array is degraded, it will immediately start to rebuild data onto that spare.

              Note that this and the following options are only meaningful on array with redundancy.  They don't apply to RAID0 or Linear.

       --re-add
              re-add a device that was previously removed from an array.  If the metadata on the device reports that it is a member of the array, and the slot that it used is still vacant, then the device will be added back to the array in the same  position.
              This  will normally cause the data for that device to be recovered.  However based on the event count on the device, the recovery may only require sections that are flagged a write-intent bitmap to be recovered or may not require any recovery at
              all.

              When used on an array that has no metadata (i.e. it was built with --build) it will be assumed that bitmap-based recovery is enough to make the device fully consistent with the array.

              When used with v1.x metadata, --re-add can be accompanied by --update=devicesize, --update=bbl, or --update=no-bbl.  See the description of these option when used in Assemble mode for an explanation of their use.

              If the device name given is missing then mdadm will try to find any device that looks like it should be part of the array but isn't and will try to re-add all such devices.

              If the device name given is faulty then mdadm will find all devices in the array that are marked faulty, remove them and attempt to immediately re-add them.  This can be useful if you are certain that the reason for failure has been resolved.

       --add-spare
              Add a device as a spare.  This is similar to --add except that it does not attempt --re-add first.  The device will be added as a spare even if it looks like it could be an recent member of the array.

       -r, --remove
              remove listed devices.  They must not be active.  i.e. they should be failed or spare devices.

              As well as the name of a device file (e.g.  /dev/sda1) the words failed, detached and names like set-A can be given to --remove.  The first causes all failed device to be removed.  The second causes any device which is no longer connected to the
              system (i.e an 'open' returns ENXIO) to be removed.  The third will remove a set as describe below under --fail.

       -f, --fail
              Mark  listed  devices  as  faulty.   As  well as the name of a device file, the word detached or a set name like set-A can be given.  The former will cause any device that has been detached from the system to be marked as failed.  It can then be
              removed.

              For RAID10 arrays where the number of copies evenly divides the number of devices, the devices can be conceptually divided into sets where each set contains a single complete copy of the data on the array.  Sometimes a RAID10 array will be  con‐
              figured so that these sets are on separate controllers.  In this case all the devices in one set can be failed by giving a name like set-A or set-B to --fail.  The appropriate set names are reported by --detail.

       --set-faulty
              same as --fail.

       --replace
              Mark  listed devices as requiring replacement.  As soon as a spare is available, it will be rebuilt and will replace the marked device.  This is similar to marking a device as faulty, but the device remains in service during the recovery process
              to increase resilience against multiple failures.  When the replacement process finishes, the replaced device will be marked as faulty.
```

##### 查看raid组装信息

```
cat /proc/mdstat 
Personalities : [raid10] 
md127 : active raid10 sdc[1] sdd[2] sda[3] sdb[0]
      999950336 blocks super 1.2 512K chunks 2 near-copies [4/4] [UUUU]
      bitmap: 1/8 pages [4KB], 65536KB chunk

unused devices: <none>
```
[UUUU] 启动正常U up?   
S spare   
R rebuiding  

##### state 状态 active 和 clean 的区别

clean - no pending writes, but otherwise active.
    When written to inactive array, starts without resync
    If a write request arrives then
      if metadata is known, mark 'dirty' and switch to 'active'.
      if not known, block and switch to write-pending
    If written to an active array that has pending writes, then fails.
active
    fully active: IO and resync can be happening.
    When written to inactive array, starts with resync


[更过详情](https://www.tecmint.com/category/raid/)

#### 异常处理

在组装过程中意外中断，机器重启，如下状态
```
 State : clean, resyncing (PENDING) 
```

解决
```
mdadm --readwrite /dev/md127 
```
