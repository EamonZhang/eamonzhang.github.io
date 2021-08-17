---
title: "cgroups"
date: 2019-01-14T09:28:49+08:00
draft: false
---

https://www.certdepot.net/rhel7-get-started-cgroups/

https://www.oracle.com/technical-resources/articles/linux/resource-controllers-linux.html

iops和bps限制

限制sda 的读写

```
lsblk 

NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 931.5G  0 disk /data
sdb      8:16   0 223.6G  0 disk 
├─sdb1   8:17   0   200M  0 part /boot/efi
├─sdb2   8:18   0     1G  0 part /boot
├─sdb3   8:19   0   7.8G  0 part [SWAP]
└─sdb4   8:20   0 214.6G  0 part /
```

```
cd /sys/fs/cgroup/blkio/

echo "8:0 102400" > blkio.throttle.read_bps_device
echo "8:0 10" > blkio.throttle.read_iops_device
echo "8:0 204800" > blkio.throttle.write_bps_device
echo "8:0 20" > blkio.throttle.write_iops_device
```
