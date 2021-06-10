---
title: "远程管理卡 命令管理IPMI"
date: 2021-05-10T16:58:56+08:00
draft: false
toc: false
categories: ['linux']
tags: []
---

## IPMI

IPMI，即智能平台管理接口（Intelligent Platform Management Interface），IPMI的核心是一个专用芯片/控制器(BMC)，独立于操作系统、BIOS和处理器，因此属于带外管理设备。正是因为如此，我们可以通过BMC来控制或者获取系统的各种信息，而不需要关注系统是否正常。比如，系统卡住了，可以通过ipmi reset系统，而不需要跑到机房断电；系统无法登录也可以远程屏幕查看是什么问题。

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
```

#### 设置用户 2 可用(默认即可用)

```
ipmitool -I open user enable 2
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

## 常用命令

```
1. 查看机箱电源状态：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) power status
2. 开机：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) power on
3. 关机：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) power off
4. 重启机器：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) power reset
5. pxe安装系统：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) chassis bootdev pxe
6. 远程查看屏幕：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) sol activate
7. 关闭当前远程查看屏幕的会话：
ipmitool -I lanplus -H (IP) -U (用户名) -P (密码) sol deactivate
8. 查看机器重启原因：
ipmitool -I open chassis restart_cause


```

## BMC 重启

```
ipmitool mc reset [warm/cold]
```

## BMC 恢复默认出厂设置

```
TODO 待验证
ipmitool raw ** **
```

## 扩展功能 设置来电自启动

当发生意外断电时，在来电后自启动，通常在bios中电源管理项中可配置。但是每天机器都重启进入bios配置太麻烦了。

查看现有策略
```
#ipmitool  chassis status
System Power         : on
Power Overload       : false
Power Interlock      : inactive
Main Power Fault     : false
Power Control Fault  : false
Power Restore Policy : always-on
```

修改策略
```
支持策略类型
#ipmitool  chassis policy list
Supported chassis power policy:  always-off always-on previous
```

```
设置策略
# ipmitool  chassis policy always-on
Set chassis power restore policy to always-on
```

## TODO 远程屏幕

需要BIOS 中配置 Serial Communication 重定向到COM2 口。

默认是将显示信息输出到COM1，本地显示器。


## 补充 远程屏幕管理

利用自带的远程管理卡功能

1 登陆到远程管理卡界面

2 Launch 下载jveiwer.jnlp 文件到本地

3 本地运行

```
javaws --config jviewer.jnlp
```

可能遇见问题 1

```
cannot grant permissions to unsigned JARs
```

当前环境

- Unbutu Desktop

- jdk 1.8

- javaws IcedTea

IcedTea 是openjdk 的一个补充,封装，包含了javaws（java Web Start）。 修改javaws 的安全策略没用

原因： java 安全配置问题，jdk 8 后默认安全等级发生变更， 解决方法

vi /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

删除 DM5
```
jdk.jar.disabledAlgorithms=MD2,MD5,RSA keySize < 1024
jdk.jar.disabledAlgorithms=MD2,RSA keySize < 1024
```

可能问题 2

```
java Index OUT
```

jdk 版本问题。 请安装open JDK 8

