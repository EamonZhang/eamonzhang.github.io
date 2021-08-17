---
title: "Linux wheel 用户组"
date: 2018-10-18T10:33:14+08:00
draft: false
---


### wheel 用户组


1.在Linux系统中root用户作为超级管理员拥有至高无上的权限，其他用户可以使用su命令将自己切换为root用户。为了加强系统的安全性,对系统用户权限进行限制。
   设置为只有wheel用户组的成员拥有su 权利，其他用户不再具备切换到root 用户的权限。

2.设置 
     
　2.1 新建user1 用户并添加用到wheel组 

```  
  $ useradd user1 
  $ passwd user1
  $ gpasswd -a user1 wheel
```  
　2.2 验证 

```
  $ sudo su - user1
  $ [user1@kvm73 ~]$ sudo su - root
  $ [user1@kvm73 ~]$ sudo su - root
```

3.限制其他用户  

```
  $vi /etc/pam.d/su 
   #auth required pam_wheel.so use_uid 这一行去掉注释。 
 
  $vi /etc/login.defs 
  SU_WHEEL_ONLY yes 　这一行加入到文件末尾。
```
