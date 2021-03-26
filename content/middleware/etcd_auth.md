---
title: "etcd 访问控制"
date: 2021-01-29T09:37:26+08:00
draft: false
---

##### 介绍

  etcd 默认没有开启访问控制。 在生产环境中使用属于裸奔。

开启访问控制有两种方式

- 密钥证书验证

- 用户名密码验证

本篇实验用户名密码验证方式

##### 用户

开启访问认证需要创建root 用户，root 用户默认自动拥有root角色的权限，及超级管理员。

##### 角色

角色理解为指定权限的集合，权限包括 read 、write、 readwrite

角色用于对访问权限的管理控制。

系统默认拥有角色root 、guest。

系统通过授权用户不同权限的角色，实现对用户的访问控制。

##### 用户管理

```
 etcdctl user --help
NAME:
   etcdctl user - user add, grant and revoke subcommands

USAGE:
   etcdctl user command [command options] [arguments...]

COMMANDS:
     add     add a new user for the etcd cluster
     get     get details for a user
     list    list all current users
     remove  remove a user for the etcd cluster
     grant   grant roles to an etcd user
     revoke  revoke roles for an etcd user
     passwd  change password for a user

OPTIONS:
   --help, -h  show help
```

##### 角色管理

```
etcdctl role --help
NAME:
   etcdctl role - role add, grant and revoke subcommands

USAGE:
   etcdctl role command [command options] [arguments...]

COMMANDS:
     add     add a new role for the etcd cluster
     get     get details for a role
     list    list all roles
     remove  remove a role from the etcd cluster
     grant   grant path matches to an etcd role
     revoke  revoke path matches for an etcd role

OPTIONS:
   --help, -h  show help
```

##### 一个例子
```
-- 创建测试目录
etcdctl mkdir /service001

-- 添加角色
etcdctl role add r001
Role r001 created

-- 角色设置权限
etcdctl role grant --path /service001/* --rw r001
Role r001 updated

-- 添加用户
etcdctl  user add u001
New password: 
User u001 created

-- 用户绑定角色
etcdctl  user grant --roles r001 u001
User u001 updated

-- 查看用户角色
etcdctl  user get u001
User: u001
Roles:  r001

-- 查看角色权限
etcdctl role get r001
Role: r001
KV Read:
	/service001/*
KV Write:
	/service001/*

```

##### 开启认证访问

```
-- 开启认证需要系统拥有root用户，创建root用户会自动关联root角色
etcdctl user add root 
New password: 
User root created
```

```
-- 开启认证模式
etcdctl auth enable
Authentication Enabled
```

```
-- 无认证仍然可访问。。。
etcdctl ls /service001
```

###### 注意事项

因为在 Etcd 开启 Basic Auth 之后，默认会启用两个角色 root 和 guest， root 和 guest 角色都拥有所有权限，

当我们未指定身份的时候其实是通过 guest 角色进行的操作，这里需要注意的是两个角色都不要删除，否则你可能会遇到意想不到的Bug，既然无法删除，

那么为们可以通过收回权限的方式对 guest 的权限进行限制

```
-- 回收guest角色的所有权限
etcdctl --username root role revoke guest --path=/* --readwrite
Password: 
Role guest updated

-- 查看guest角色权限
etcdctl --username root role  get guest
Password: 
Role: guest
KV Read:
KV Write:
```

```
-- 无认禁止证访问
etcdctl get /service001/a
Error:  110: The request requires user authentication (Insufficient credentials) [0]
```

```
-- 使用认证访问 用户名 u001 密码 123456
etcdctl --username u001:123456 set /service001/a 1
1

etcdctl --username u001:123456 get /service001/a
2
```

