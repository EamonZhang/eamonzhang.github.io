---
title: "Linux查看内存条信息"
date: 2019-01-14T15:38:29+08:00
draft: false
---

1.查看内存槽及内存条
```
$ sudo dmidecode -t memory
```
2.查看内存的插槽数,已经使用多少插槽.每条内存多大
```
$ sudo dmidecode -t memory | grep Size
```
3.查看服务器型号、序列号
```
$ sudo dmidecode | grep "System Information" -A9 | egrep "Manufacturer|Product|Serial"
```

