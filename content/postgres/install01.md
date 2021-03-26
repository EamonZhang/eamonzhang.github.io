---
title: "安装 Postgresql"
date: 2018-10-17T14:37:56+08:00
draft: false
---

[官网](https://www.postgresql.org/download/linux/redhat/)

1.准备源

```
清除历史残余，有些是系统自带的旧版本数据库

rpm -qa | grep postgres

rpm -r ****

安装新数据源

yum install https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

可将所有的软件更新到最新版本如 ， postgresql-10.2 更新到当前最新的postgresql-10.6

yum update -y 

```
2.安装

```
yum install -y postgresql10-server postgresql10  postgresql10-contrib
```

3.初始化

```
默认
/usr/pgsql-10/bin/postgresql-10-setup initdb

自定义
/usr/pgsql-10/bin/initdb -D $PGDATA -U postgres -E UTF-8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8 -k

-D 数据存放位置
-U 超级用户
-E 默认编码
--lc-collate 区域 Collate会影响中文的排序，在zh_CN的区域下中文按拼音排序，其它区域按字符编码排序。
--lc-ctype 字符类型Ctype会影响pg_trgm和部分正则匹配的结果，比如Ctype为'C'时，pg_trgm将无法支持中文。
-k 使用 data checksums
```

可将数据存放到其他目录下，使用[软连接](linux/ln-s)的方式。

为什么会使用软连接而不是更改PGDATA环境变量，因为升级数据库的时 PGDATA 被指回默认值。

通过软连接的方式不改变初始值:   
1 升级的时候不用修改PGDATA   
2 数据位置存放固定，便于以后管理。  

4.启动服务　＆　开机自启

```   
systemctl start postgresql-10.service

systemctl enable postgresql-10.service
```

5.设置访问权限

　  vi postgresql.conf

```
  listen_addresses ='*'
```

  　vi pg_hba.conf

```
  # "local" is for Unix domain socket connections only
  local   all             all                                     trust
  # IPv4 local connections:
  host    all             all             127.0.0.1/32            trust
  host    all             all             0.0.0.0/0               md5
  # IPv6 local connections:
  host    all             all             ::1/128                 ident

```

```
systemctl restart postgresql-10.service
```

6.设置密码

```
  #psql -U postgres
  
  postgres=# ALTER USER postgres WITH PASSWORD 'postgres'
  \q

```

#### 进一步优化

##### 系统Linux 内核参数

vi /etc/sysctl.conf 

```
kernel.shmall = 4294967296  
kernel.shmmax=135497418752  
kernel.shmmni = 4096  
kernel.sem = 50100 64128000 50100 1280  
fs.file-max = 7672460  
fs.aio-max-nr = 1048576  
net.ipv4.ip_local_port_range = 9000 65000  
net.core.rmem_default = 262144  
net.core.rmem_max = 4194304  
net.core.wmem_default = 262144  
net.core.wmem_max = 4194304  
net.ipv4.tcp_max_syn_backlog = 4096  
net.core.netdev_max_backlog = 10000  
#net.ipv4.netfilter.ip_conntrack_max = 655360  
net.ipv4.tcp_timestamps = 0  
net.ipv4.tcp_tw_recycle=1  
net.ipv4.tcp_timestamps=1  
net.ipv4.tcp_keepalive_time = 72   
net.ipv4.tcp_keepalive_probes = 9   
net.ipv4.tcp_keepalive_intvl = 7  
vm.zone_reclaim_mode=0  
vm.dirty_background_bytes = 40960000  
vm.dirty_ratio = 80  
vm.dirty_expire_centisecs = 6000  
vm.dirty_writeback_centisecs = 50  
vm.swappiness=0  
vm.overcommit_memory = 0  
vm.overcommit_ratio = 90  
```

sysctl -p 生效

##### 系统Linux 最大句柄数

vi /etc/security/limits.conf   
  
```
* soft    nofile  131072  
* hard    nofile  131072  
* soft    nproc   131072  
* hard    nproc   131072  
* soft    core    unlimited  
* hard    core    unlimited  
* soft    memlock 500000000  
* hard    memlock 500000000 

```

#### ntp

```
yum install ntp -y

systemctl start ntpd
systemctl enable ntpd
``` 



reboot 生效


#### 数据库参数

[参见](postgres/params/)

#### 常见问题

```
Package: postgresql12-devel-12.3-1PGDG.rhel7.x86_64 (pgdg12)
           Requires: llvm-toolset-7-clang >= 4.0.1
install CentOS SCLo RH repository and install llvm-toolset-7-clang to resolve it.
yum install centos-release-scl-rh
yum install llvm-toolset-7-clang
```
