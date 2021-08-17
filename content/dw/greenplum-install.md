---
title: "Greenplum6 安装"
date: 2019-12-06T14:29:04+08:00
toc: false
categories: ["数仓"]
draft: false
---

## 环境准备

```
/ect/hosts

groupadd gpadmin
useradd gpadmin -r -m -g gpadmin

passwd gpadmin

su gpadmin
ssh-keygen -t rsa -b 4096

visudo


%wheel        ALL=(ALL)       NOPASSWD: ALL

usermod -aG wheel gpadmin

```

## 软件安装

```
wget https://github.com/greenplum-db/gpdb/releases/download/6.1.0/greenplum-db-6.1.0-rhel7-x86_64.rpm

sudo yum install ./greenplum-db-<version>-<platform>.rpm

sudo chown -R gpadmin:gpadmin /usr/local/greenplum*

source /usr/local/greenplum-db-<version>/greenplum_path.sh

vi /home/gpadmin/.bashrc
```


ssh 免密打通

1-n

ssh-copy-id mdw

n-n

vi /home/gpadmin/hostfile_exkeys

mdw
smdw
sdw1
sdw2
sdw3
sdw4
sdw5
sdw6


gpssh-exkeys -f hostfile_exkeys


## 创建存储目录

master 
mkdir -p /data/master

segment

mkdir -p /data/primary1
mkdir -p /data/primary2

mkdir -p /data/mirror1
mkdir -p /data/mirror2

chown -R gpadmin /data/*


## 性能测试

网络
```
 gpcheckperf -f hostfile_gpchecknet_ic1 -r N -d /tmp > subnet1.out
```

IO 250G

```
gpcheckperf -f hostfile_gpcheckperf -r ds -D -d /data/primary1 -d  /data/primary2  -d /data/mirror1 -d  /data/mirror2 

gpcheckperf -f  gpconfigs/hostfile_gpcheckperf -r ds -D -d /data/primary1 -d  /data/primary2  -d /data/mirror1 -d  /data/mirror2 -V -S 10G
```

## 初始化安装

```
gpinitsystem -c gpconfigs/gpinitsystem_config -h gpconfigs/hostfile_gpinitsystem -s smdw -S -v
```

## 配置环境变量

vi ~/.bashrc

```
source /usr/local/greenplum-db/greenplum_path.sh

export MASTER_DATA_DIRECTORY=/data/master/gpseg-1
export PGPORT=5432
export PGUSER=gpadmin
export PGDATABASE=gptestdb
```

## 管理

```
启动

gpstart

停止

gpstop

重启 
gpstop -r

重新加载

gpstop -u

恢复未启动的节点

gprecoverseg

恢复数据重新分布为最初状态

gprecoverseg -r

```


## 问题


```
select * from gp_segment_configuration;

set allow_system_table_mods=true;

update gp_segment_configuration set hostname = address;

```

