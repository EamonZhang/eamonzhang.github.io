---
title: "Docker 本地网络"
date: 2018-11-02T16:34:06+08:00
draft: false
---

#### 基础命令概览

```
docker network --help

Usage:	docker network COMMAND

Manage networks

Commands:
  connect     Connect a container to a network
  create      Create a network
  disconnect  Disconnect a container from a network
  inspect     Display detailed information on one or more networks
  ls          List networks
  prune       Remove all unused networks
  rm          Remove one or more networks

```
#### 默认网络

```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
0770a8275bff        bridge              bridge              local
b6617326f199        host                host                local
31c55ffcf0a8        none                null                local

```

创建容器时通过 --network=  指定网络类型

- none 这个网络下的容器除了 lo，没有其他任何网卡。 
- host 共享Host的网络栈，容器的网络配置与 host 完全一样。
 -- 优点效率高
 -- 不足由于没有隔离，与host资源容易冲突。
- bridge 默认的网络类型 

#### Bridge 网络

Linux提供了许多虚拟设备，这些虚拟设备有助于构建复杂的网络拓扑，满足各种网络需求。

- 网桥（bridge）
网桥是一个二层设备，工作在链路层，主要是根据MAC学习来转发数据到不同的port。 看做物理设备中的交换机 ，或vlan
```
# 创建网桥
brctl addbr br0
# 添加设备到网桥
brctl addif br0 eth1
# 查询网桥mac表
brctl showmacs br0
```

- veth
veth pair是一对虚拟网络设备，一端发送的数据会由另外一端接受，常用于不同的网络命名空间。
```
# 创建veth pair
ip link add veth0 type veth peer name veth1
# 将veth1放入另一个netns
ip link set veth1 netns newns
```
- TAP/TUN 
TAP/TUN设备是一种让用户态程序向内核协议栈注入数据的设备，TAP等同于一个以太网设备，工作在二层；而TUN则是一个虚拟点对点设备，工作在三层。
```
ip tuntap add tap0 mode tap
ip tuntap add tun0 mode tun
```

Docker 安装后默认有一个名称为docker0 的bridge, 新建的容器都会挂接到docker0 上。

```
brctl show # yum install bridge-utils
bridge name	bridge id		STP enabled	interfaces
docker0		8000.024262081be1	no		veth16209e7
``` 
<font color=#0099ff face="黑体">veth16209e7</font>

实体机网络

```
ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 52:54:00:69:69:aa brd ff:ff:ff:ff:ff:ff
    inet 10.1.88.72/16 brd 10.1.255.255 scope global noprefixroute eth0
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:62:08:1b:e1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
13: veth16209e7@if12: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether 92:94:68:8c:0d:2a brd ff:ff:ff:ff:ff:ff link-netnsid 1

```

容器内网络

```
 docker exec -it 8d525f4dae3c ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
12: eth0@if13: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

###### 原来 veth16209e7 和 eth0@if13 是一对 veth pair

再看下现在的docker bridge network 

```
docker inspect network bridge 
[
    {
        "Name": "bridge",
        "Id": "0770a8275bfffd2c036d1761576c30c7618be5e016013f9a202bc305a7d88c88",
        "Created": "2018-11-02T13:21:53.778809347+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
brew cask install emacs        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },

```
网关 172.17.0.1 是实体机中docker0 网卡

#### 自定义bridge 网络

```
docker network create --driver bridge my_bridge
a24a9805f63da7d0878e5791973cb340ab519d06c04f76c4b59503d9d1bc7797
```
```
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
0770a8275bff        bridge              bridge              local
b6617326f199        host                host                local
a24a9805f63d        my_bridge           bridge              local
31c55ffcf0a8        none                null                local

```
```
docker inspect network my_bridge 
[
    {
        "Name": "my_bridge",
        "Id": "a24a9805f63da7d0878e5791973cb340ab519d06c04f76c4b59503d9d1bc7797",
        "Created": "2018-11-05T11:14:31.542338714+08:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
```

```
 brctl show
bridge name	bridge id		STP enabled	interfaces
br-a24a9805f63d		8000.0242a87f1d16	no		
docker0		8000.024262081be1	no		veth16209e7

```

创建了一个与默认的bridge类似的network

下面创建一个新的容量挂载到 my_bridge 网络中 

```
 docker run -it --network=my_bridge busybox 
/ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
17: eth0@if18: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue 
    link/ether 02:42:ac:12:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.18.0.2/16 brd 172.18.255.255 scope global eth0
       valid_lft forever preferred_lft forever
```

##### 不同的bridge间的网络不通,相同bridge的网络可以通信。

#### 容器间的通信 

- IP 容器创建时通过 --network 指定相应的网络，或者通过 docker network connect 将现有容器加入到指定网络
- DNS 通过 docker 自带的 DNS 服务, ping containername
- joined 共享一个网络栈，共享网卡和配置信息，joined 容器之间可以通过 127.0.0.1 直接通信. --network=container:name


#### 实际应用
---

##### 背景介绍

在使用过程中应用docker-compose 来管理本地的docker, docker-compose默认为每个docker-compose应用创建自己的网络.

```
ip r
default via 10.1.7.50 dev eth0 proto static metric 100 
10.1.0.0/16 dev eth0 proto kernel scope link src 10.1.88.74 metric 100 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 
172.19.0.0/16 dev br-130b4184e72e proto kernel scope link src 172.19.0.1 
172.21.0.0/16 dev br-f277f9a2b577 proto kernel scope link src 172.21.0.1 
172.22.0.0/16 dev br-24d29dd54a64 proto kernel scope link src 172.22.0.1 
172.23.0.0/16 dev br-caf35e9eae30 proto kernel scope link src 172.23.0.1 
192.168.0.0/16
```

很容易与实体机的网络环境发生冲突

需要使用docker network 来统一管理分配

##### 创建网桥

```
# 创建网络
docker  network create --subnet 172.19.0.0/16 --gateway 172.19.0.1 service;
docker  network create --subnet 172.18.0.0/16 --gateway 172.18.0.1 web;

# 查看网络
docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
201b9332eb9a        bridge              bridge              local
ac97b8f65d31        host                host                local
7ca81ce4f054        none                null                local
130b4184e72e        service             bridge              local
24d29dd54a64        web                 bridge              local

# 具体信息

docker inspect service
docker inspect web

```

#### 在docker-compose 中应用网络


```
# 配置网络
cat docker-compose.yaml 

version: '2'
services:
  web:
   image: busybox
   command: sleep 3600
   ports:
     - "8000:8000"
   container_name: web
networks:
  default:
    external:
      name: web 

# 启动容器

docker-compose up -d

# 查看容器网络

docker-compose ps  


docker exec -it 容器ID ip a
```


