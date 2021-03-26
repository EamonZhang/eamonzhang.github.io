---
title: "Consul DNS 服务发现"
date: 2020-06-29T11:09:52+08:00
draft: false
---

#### 实现目标

- 多IP解析，负载轮询
- 自动检查后端服务状态，自动剔除不可用后端
- 别名配置
- 上游DNS支持
- ttl cache 支持

前两点由cousul实现  
后两点由dnsmasq实现  
别名配置未实现  

#### 简单应用

集群配置 

10.1.88.84  
10.1.88.85  
10.1.88.86  

```
consul agent -server -bootstrap-expect=3 -data-dir=/tmp/consul -node=10.1.88.84 -bind=10.1.88.84 -client=0.0.0.0 -datacenter=bj -domain=zhangeamon.com -config-dir=/etc/consul.d -ui
consul agent -server -bootstrap-expect=3 -data-dir=/tmp/consul -node=10.1.88.85 -bind=10.1.88.85 -client=0.0.0.0 -datacenter=bj -domain=zhangeamon.com -join=10.1.88.84 -config-dir=/etc/consul.d -ui
consul agent -server -bootstrap-expect=3 -data-dir=/tmp/consul -node=10.1.88.86 -bind=10.1.88.86 -client=0.0.0.0 -datacenter=bj -domain=zhangeamon.com -join=10.1.88.84 -config-dir=/etc/consul.d -ui
```

服务发现配置

cat /etc/consul.d/web/json
```
{
  "services":[
    {
      "id": "web01",
      "name": "web",
      "address": "10.1.88.84",
      "tags": [
        "rails"
       ],
        "check": {
          "name": "SSH",
          "tcp": "10.1.88.84:22",
          "interval": "1s",
          "timeout": "1s",
          "success_before_passing": 3,
          "failures_before_critical": 3
      }
    },
    { 
      "id": "web02",
      "name": "web",
      "address": "10.1.88.85",
      "tags": [
        "rails"
      ],
      "check": {
          "name": "SSH",
          "tcp": "10.1.88.85:8000",
          "interval": "1s",
          "timeout": "1s",
          "success_before_passing": 3,
          "failures_before_critical": 3
      }
     }
  ]
}
```
加载服务发现配置
consul reload

测试
```
dig @127.0.0.1 -p 8600 web.service.zhangeamon.com
```

在 10.1.88.85 启动服务8000端口
```
python -m SimpleHTTPServer 8000
```
服务开启时解析到 10.1.88.85 服务关闭时 10.1.88.85 被剔除。

###### dnsmasq  配置

vi /etc/dnsmasq.conf
```
conf-dir=/etc/dnsmasq.d,.rpmnew,.rpmsave,.rpmorig
all-servers
# 多个上游dns配置 后缀为 zhangeamon.com 上游走consul,实现支持上游dns功能
server=119.29.29.29#53
server=/zhangeamon.com/10.1.88.84#8600
server=/zhangeamon.com/10.1.88.85#8600
server=/zhangeamon.com/10.1.88.86#8600
#resolv-file=/etc/resolv.dnsmasq.conf
log-facility=/var/log/dnsmasq/dnsmasq.log
log-async=100
# 缓存配置
cache-size=1000000
#no-hosts
dns-forward-max=1000000
log-queries

#cname 配置未生效
#cname=web.zhangeamon.com,web.service.zhangeamon.com 
#cname=a.a.com,a.b.com
```

