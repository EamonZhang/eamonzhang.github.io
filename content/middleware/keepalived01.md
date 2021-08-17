---
title: "Keepalived 问题集"
date: 2018-11-05T10:08:23+08:00
draft: false
categories: ["中间件"]
---

## 问题描述 
- Q1 
```
  ip address associated with VRID 51 not present in MASTER advert : 10.1.7.58
```
其中 51 为 virtual_router_id 10.1.7.58 为虚拟IP

可能原因
 
1. ntp 时间不同步

2. 局域网内 virtual_router_id 与其他集群配置冲突。 另外 router_id 主机标示，一般为hostname即可。

 解决方法： unicast_peer{ } 配置成单播模式

- Q2
```
keepalived ping不通
```
解决办法,注释掉配置文件中的
```
vrrp_strict
```

- Q3
```
not a regular file
```

解决方法

```
chmod 644 keepalived.conf
```

- Q4

```
virtual_server 
```

该部分是用来管理LVS的，是实现keepalive和LVS相结合的模块


- Q5

```
VRRP , Virtual Router Redunday Protocol  。虚拟路由冗余协议
```

- Q6

```
Keepalived工作方式：抢占式、非抢占式

抢占式 ， 主从模式 。 state: MASTER ，BUCKUP

非抢占式， 在配置中添加 nopreempt 标识为非抢占模式
```


## 一个简单的配置DEMO

```
! Configuration File for keepalived
  
global_defs {
   router_id LVS_DEVEL # 组名。同一个网络空间，组名一致为同一个组
   vrrp_skip_check_adv_addr
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_instance VI_1 {
    state MASTER       # MASTERE BACKUP 
    interface eno1     # 网卡名
    virtual_router_id 51  # 组内唯一标识
    priority 100    # 优先等级
    advert_int 1
    authentication { # 组内安全认证
        auth_type PASS
        auth_pass admin
    }
    virtual_ipaddress { # VIP 设置
        192.168.1.8/24
    }
}
```

## 检测后端程序

以nginx为例

cat /server/scripts/check_list 
```
nginxpid=$(ps -C nginx --no-header|wc -l)
#1.判断Nginx是否存活,如果不存活则尝试启动Nginx
if [ $nginxpid -eq 0 ];then
    systemctl start nginx
    sleep 3
    #2.等待3秒后再次获取一次Nginx状态
    nginxpid=$(ps -C nginx --no-header|wc -l) 
    #3.再次进行判断, 如Nginx还不存活则停止Keepalived,让地址进行漂移,并退出脚本  
    if [ $nginxpid -eq 0 ];then
        systemctl stop keepalived
   fi
fi
```

cat /etc/keepalived/keepalived.conf
```
! Configuration File for keepalived
global_defs {
    router_id lb01
}

vrrp_script check {
    script "/server/scripts/check_list"
    interval  10
}

vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 50
    priority 150
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
}
    virtual_ipaddress {
       192.168.1.8/24
    }
    track_script  {
    check
   }
}
```

## 发生主从切换通知

```
notify_master /server/scripts/tobe_master.sh  //当切换为MASTER时将触发

notify_backup /server/scripts/tobe_slave.sh // 当切换为BACKUP时将触发
```
