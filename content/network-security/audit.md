---
title: "日志审计 audit"
date: 2020-05-08T08:52:03+08:00
draft: false
---

#### 介绍

auditd是Linux审计系统中用户空间的一个组件，负责将审计记录写到磁盘中。在CentOS7上默认就会有安装这个服务。

如果被卸载，可以直接使用yum进行安装：
```
yum -y install audit auditd-libs
```

#### 常用命令

```
1、auditctl : 即时控制审计守护进程的行为的工具，比如如添加规则等等。
audtitctl -l #查看规则
auditctl -D #清空规则
2、aureport : 查看和生成审计报告的工具。
aureport -l #生成登录审计报告
3、ausearch : 查找审计事件的工具
ausearch -i -p 4096
4、autrace : 一个用于跟踪进程的命令。
autrace -r /usr/sbin/anacron

```

#### 简单应用

###### 监控文件或者目录的更改
```
auditctl -w /etc/passwd -p rwxa -k passwd

-w path : 指定要监控的路径，上面的命令指定了监控的文件路径 /etc/passwd
-p : 指定触发审计的文件或者目录的访问权限
rwxa ： 指定的触发条件，r 读取权限，w 写入权限，x 执行权限，a 属性（attr）
```

运行这条命令之后就开始监控了，但是机器重启之后就失效了，因此要永久生效就需要写到规则文件里面。
vim /etc/auditd/rules.d/auditd.rules
将auditctl的命令参数写到这个文件里面即可。

###### 重启服务
```
service auditd restart
```
systemctl restart auditd 不可用


###### 查找日志ausearch

```
-a number #只显示事件ID为指定数字的日志信息，如只显示926事件：ausearch -a 926
-c commond #只显示和指定命令有关的事件，如只显示rm命令产生的事件：auserach -c rm
-i #显示出的信息更清晰，如事件时间、相关用户名都会直接显示出来，而不再是数字形式
-k #显示出和之前auditctl -k所定义的关键词相匹配的事件信息
```

##### 日志字段说明

```
参数说明：
time :审计时间。
name :审计对象
cwd :当前路径
syscall :相关的系统调用
auid :审计用户ID
uid和 gid :访问文件的用户ID和用户组ID
comm :用户访问文件的命令
exe :上面命令的可执行文件路径
```

###### 查看登陆信息

默认支持

```
aureport -l
aureport -h
```

类似命令

```
last  登陆成功
lastb 登陆失败
```
