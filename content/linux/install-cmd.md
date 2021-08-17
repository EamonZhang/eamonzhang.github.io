---
title: "软件安装"
date: 2020-03-20T09:35:08+08:00
draft: false
---

#### Centos7

```
查看是否存在需要安装的软件
yum search xxxx

查看具体版本详情
yum list xxxx

查看已安装
rpm -qa | grep xxxx
```

```
安装
yum install xxxx
rpm -i xxxx.rpm
```

```
删除
yum erase xxxx
rpm -r xxxx
```

#### Unbuntu

```
查看是否存在需要安装的软件
apt-cache search xxxx

查看具体版本及信息
apt show xxxx 

查看已安装
dpkg -l

安装
apt-get install xxxx 
dpkg -l 

删除
apt-get remove xxxx
```
