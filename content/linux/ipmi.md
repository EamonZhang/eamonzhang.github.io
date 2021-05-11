---
title: "ipmi 配置远程管理卡"
date: 2021-05-10T16:58:56+08:00
draft: false
toc: false
categories: ['linux']
tags: []
---

## 使用ipmi 配置远程管理

远程管理卡的基本信息通常通过BIOS进行配置

缺点： 需要重启机器。不灵活。

下面通过Linux 系统命令行工具实现对管理卡的配置

#### 安装

```
yum install OpenIPMI OpenIPMI-tools
```

## 网络信息配置管理

#### 查看现有管理卡配置信息

```
ipmitool lan print 1
```

#### 设置网络信息

```
ipmitool -I open lan set 1 ipsrc static
ipmitool -I open lan set 1 ipaddr x.x.x.x
ipmitool -I open lan set 1 netmask x.x.x.x
ipmitool -I open lan set 1 defgw ipaddr x.x.x.x
ipmitool -I open lan set 1 access on
```

#### 通信安全增强

```
ipmitool -I open lan set 1 snmp COMUNIATION
```

## 用户信息配置管理

#### 查看现有用户配置

```
# ipmitool -I open user list 1
ID  Name             Callin  Link Auth  IPMI Msg   Channel Priv Limit
1                    false   false      true       ADMINISTRATOR
2   admin            false   false      true       ADMINISTRATOR
```

#### 设置用户 2 密码

```
ipmitool -I open user set password 2
````

## 验证测试

#### 获取本机状态信息

```
ipmitool -H 管理卡IP地址 -U 用户名 -P 密码 sensor 
```

#### 获取远程机器状态信息

```
ipmitool -I lan -H 远程机器管理卡IP地址 -U 用户名 -P 密码 sensor 
```

#### 远程机器电源管理

```
ipmitool -I lan -H 远程机器管理卡IP地址 -U 用户名 -P 密码 chassis power off/reset/on/status
```

其他管理扩展
```
#ipmitool chassis status

System Power         : on
Power Overload       : false
Power Interlock      : inactive
Main Power Fault     : false
Power Control Fault  : false
Power Restore Policy : always-off
Last Power Event     : ac-failed
Chassis Intrusion    : inactive
Front-Panel Lockout  : inactive
Drive Fault          : false
Cooling/Fan Fault    : false
Front Panel Control  : none
```

## 命令简单说明

- channel 概念理解，所有的配置都对应着相应channel。 

- -I 参数， open(本机) lan(远端)
