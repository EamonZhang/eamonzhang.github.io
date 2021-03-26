---
title: "Firewall"
date: 2020-06-03T16:15:35+08:00
draft: false
---

#### 简单应用

###### 服务管理

```
# 查看全部支持的服务
$ firewall-cmd --get-service

# 查看开放的服务
$ firewall-cmd --list-service

# 开放服务
$ firewall-cmd --add-service=postgresql --permanent

# 关闭服务
$ firewall-cmd --remove-service=postgresql --permanent
```

permanent  参数修改对应的配置文件 /etc/firewalld/zones/public.xml

###### 端口管理

```
# 查看开放的端口
$ firewall-cmd --zone=public --list-ports 

# 开放指导端口
$ firewall-cmd --zone=public --add-port=80/tcp --permanent 

# 开放端口段
$ firewall-cmd --zone=public --add-port=8388-8389/tcp --permanent

# 关闭端口
$ firewall-cmd --zone=public --remove-port=80/tcp --permanent 
```

###### 规则管理

```
# 对 147.152.139.197 开放10000端口
$ firewall-cmd --permanent --zone=public --add-rich-rule='
        rule family="ipv4"
        source address="147.152.139.197/32"
        port protocol="tcp" port="10000" accept'       
        
# 拒绝端口：
$ firewall-cmd --permanent --zone=public --add-rich-rule='
              rule family="ipv4"
              source address="47.52.39.197/32"
              port protocol="tcp" port="10000" reject'  

# 开放全部端口给IP
$ firewall-cmd --permanent --zone=public --add-rich-rule='
              rule family="ipv4"
              source address="192.168.0.1/32" accept';

# 开放全部端口给网段
$ firewall-cmd --permanent --zone=public --add-rich-rule='
              rule family="ipv4"
              source address="192.168.0.0/16" accept';

# 删除规则
$4 firewall-cmd --permanent --zone=public --remove-rich-rule='
              rule family="ipv4"
              source address="192.168.0.0/16" accept';
```

##### 规则生效

```
# 查看所有规则
$ firewall-cmd   --list-all

规则生效
$ firewall-cmd --reload
```

tips1

```
先扫描下机器的端口使用情况
# tcp
nmap -p0-65535 127.0.0.01 
# udp
nmap -sU  127.0.0.1
```

tips
```
Panic Options 

恐慌模式 ， 开启后基本等同于断网。 自身ssh 也断。
```
