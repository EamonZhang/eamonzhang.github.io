---
title: "DNS"
date: 2019-10-28T09:23:00+08:00
draft: false
---

 DNS：Domain Name System 域名管理系统

 A记录 A（Address）记录是用来指定主机名（或域名）对应的IP地址记录

 NS记录 NS（Name Server）记录是域名服务器记录，用来指定该域名由哪个DNS服务器来进行解析

 MX记录 MX（Mail Exchanger）记录是邮件交换记录，它指向一个邮件服务器，用于电子邮件系统发邮件时根据收信人的地址后缀来定位邮件服务器。

 CNAME记录 CNAME（Canonical Name ）别名记录，允许您将多个名字映射到同一台计算机。

 TXT记录，一般指某个主机名或域名的说明

 TTL值 TTL（Time-To-Live）

 PTR值 PTR是pointer的简写，用于将一个IP地址映射到对应的域名，也可以看成是A记录的反向，IP地址的反向解析


#### skydns

##### 软件安装
skydns rpm 下载 for centos 7

etcd 使用 centos7 官方自带软件

##### skydns 配置

/etc/skydns/skydns.conf
```
ETCD_MACHINES="http://127.0.0.01:2379"
SKYDNS_ADDR="0.0.0.0:53"
SKYDNS_NAMESERVERS="119.29.29.29:53"
```

说明

ETCD_MACHINES
指定当前 etcd 集群地址

SKYDNS_ADDR
本地 dns 监听地址

SKYDNS_NAMESERVERS
上层 DNS 服务器


##### etcd 配置方法

另一种配置方法, 只需要在 skydns.conf 中配置对应的 etcd 连接地址即可.

其他配置选项在 etcd 中进行配置

```
 etcdctl set /skydns/config '{"dns_addr":"0.0.0.0:53","ttl":30, "nameservers": ["119.29.29.29:53"], "domain":"mydomain.com."}'
```

##### 参考作用

```
dns_addr: IP:port on which SkyDNS should listen, defaults to 127.0.0.1:53.
domain: domain for which SkyDNS is authoritative, defaults to skydns.local..
dnssec: enable DNSSEC
hostmaster: hostmaster email address to use.
local: optional unique value for this skydns instance, default is none. This is returned when queried for local.dns.skydns.local.
round_robin: enable round-robin sorting for A and AAAA responses, defaults to true. Note that packets containing more than one CNAME are exempt from this (see issue #128 on Github).
nameservers: forward DNS requests to these (recursive) nameservers (array of IP:port combination), when not authoritative for a domain. This defaults to the servers listed in /etc/resolv.conf. Also see no_rec.
no_rec: never (ever) provide a recursive service (i.e. forward to the servers provided in -nameservers).
read_timeout: network read timeout, for DNS and talking with etcd.
ttl: default TTL in seconds to use on replies when none is set in etcd, defaults to 3600.
min_ttl: minimum TTL in seconds to use on NXDOMAIN, defaults to 30.
scache: the capacity of the DNSSEC signature cache, defaults to 10000 signatures if not set.
rcache: the capacity of the response cache, defaults to 0 messages if not set.
rcache_ttl: the TTL of the response cache, defaults to 60 if not set.
ndots: how many labels a name should have before we allow forwarding. Default to 2.
systemd: bind to socket(s) activated by systemd (ignores -addr).
path-prefix: backend(etcd) path prefix, defaults to skydns (i.e. if it is set to mydns, the SkyDNS's configuration object should be stored under the key /mydns/config).
etcd3: flag that toggles the etcd version 3 support by skydns during runtime. Defaults to false.
```
##### service 文件

```
[Unit]
Description=SkyDNS service
#After=etcd.service             <- 假如 etcd 不在本地, 那么这里需要屏蔽

[Service]
Type=simple
EnvironmentFile=-/etc/skydns/skydns.conf
User=skydns                      <- 默认使用 skydns 用户启动, 但该用户无法启用 < 1024 端口的服务
ExecStart=/usr/bin/skydns

[Install]
WantedBy=multi-user.target
```
##### 授权服务启动

```
setcap cap_net_bind_service+ep /usr/bin/skydns   (允许该命令可以监听 53 端口)
systemctl daemon-reload
```

##### 服务管理

```
systemctl start skydns
systemctl stop skydns
```

##### 添加A记录

```
ectctl set /skydns/com/mydomain/test/x1 '{"host":"10.1.0.1"}'
ectctl set /skydns/com/mydomain/test/x2 '{"host":"10.1.0.2"}'

```
