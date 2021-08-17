---
title: "修改远程管理卡密码"
date: 2021-03-29T16:09:34+08:00
draft: false
toc: false
categories: ["linux"]
---

## 更改BMC密码

BMC：基板管理控制器 Baseboard Management Controller 　

更改BMC密码，需要基于Ipmitool工具实现，需要先下载该工具
安装ipmitool

ubuntu安装命令：
```
sudo apt-get -y install ipmitool
```
centos安装命令：
```
yum  -y install epel-release（先）
yum -y install ipmitool（后）
```

查看登陆账户名列表
```
ipmitool user list 2（技嘉主板是这个命令，不同主板的1或者2不同）

#ipmitool user list
ID  Name             Callin  Link Auth  IPMI Msg   Channel Priv Limit
1                    true    false      false      Unknown (0x00)
2   ADMIN            true    false      false      Unknown (0x00)
```
```
ipmitool user set password 1 newpassword（1表示ID序号，第一个ID就是1，第二个ID就是2，我们需更改的是2，newpassword表示新密码）
```
