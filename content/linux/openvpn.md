---
title: "搭建VPN服务"
date: 2021-05-18T09:03:44+08:00
draft: false
toc: false
categories: ["linux"]
tags: []
---

## 利用Openven搭建VPN服务

#### 服务端

参考

https://github.com/kylemanna/docker-openvpn

初始化
```
OVPN_DATA="ovpn-data-example"
docker volume create --name $OVPN_DATA
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://VPN.SERVERNAME.COM
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
```
其中 
VPN.SERVERNAME.COM 为访问域名


启动服务
```
docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
```

生成key
```
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full CLIENTNAME nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient CLIENTNAME > CLIENTNAME.ovpn
```

客户端

```
openvpn --config CLIENTNAME.ovpn
```

验证

```
curl ipinfo.io
```

查看upd 端口

```
nc -vu ip port
```
