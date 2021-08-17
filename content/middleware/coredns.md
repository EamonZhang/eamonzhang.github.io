---
title: "coredns"
date: 2020-06-22T13:25:08+08:00
draft: false
---

#### 背景

致力于打造云原生中的dns服务和服务发现。

各种功能都是通过插件方式实现

#### 简单例子

服务

cat /usr/lib/systemd/system/coredns.service 
```
[Unit]
Description=CoreDNS DNS server
Documentation=https://coredns.io
After=network.target

[Service]
PermissionsStartOnly=true
LimitNOFILE=1048576
LimitNPROC=512
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
NoNewPrivileges=true
User=coredns
WorkingDirectory=~
ExecStart=/usr/local/bin/coredns -conf=/etc/coredns/Corefile
ExecReload=/bin/kill -SIGUSR1 $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

配置文件
cat /etc/coredns/Corefile 
```
.:53 {
  # 绑定interface ip
  bind 127.0.0.1
  # 先走本机的hosts
  # https://coredns.io/plugins/hosts/
  
  hosts {
    # 自定义sms.service search.service 的解析
    # 因为解析的域名少我们这里直接用hosts插件即可完成需求
    # 如果有大量自定义域名解析那么建议用file插件使用 符合RFC 1035规范的DNS解析配置文件
    10.6.6.2 sms.service
    10.6.6.3 search.service
    # ttl
    ttl 60
    # 重载hosts配置
    reload 1m
    # 继续执行
    fallthrough
  }
  # 通过 curl localhost:9253/metrics 获取监控指标
  # 插件
  prometheus localhost:9253
  # file enables serving zone data from an RFC 1035-style master file.
  # https://coredns.io/plugins/file/
  # file service.signed service
  # 最后所有的都转发到系统配置的上游dns服务器去解析
  forward . /etc/resolv.conf
  # 缓存时间ttl
  cache 120
  # 自动加载配置文件的间隔时间
  reload 6s
  # 输出日志
  log
  # 输出错误
  errors
  # 健康检查插件
  health localhost:8092 {
        lameduck 1s
    }
}

```

#### 更多

将服务注册在etcd中

#### 遗留

不支持对后端服务的健康检查
