---
title: "Github DNS 加速"
date: 2021-03-17T14:34:26+08:00
draft: false
toc: true
---

## IP 查询

https://www.ipaddress.com/

直接点击下面链接查询

 - [github.com](https://github.com.ipaddress.com/)
 - [assets-cdn.github.com](https://github.com.ipaddress.com/assets-cdn.github.com)
 - [github.global.ssl.fastly.net](https://fastly.net.ipaddress.com/github.global.ssl.fastly.net)


## 修改本地dns

vi /etc/hosts
```
140.82.114.4 github.com
185.199.108.153 assets-cdn.github.com
199.232.69.194 github.global.ssl.fastly.net
```
