---
title: "Haproxy 算法"
date: 2018-11-26T08:53:09+08:00
draft: false
---

1. blance roundrobin # 轮询，软负载均衡基本都具备这种算法 

2. balance static-rr # 根据权重，建议使用 

3. balance leastconn # 最少连接者先处理，建议使用 

4. balance source # 根据请求源IP，建议使用 

5. balance uri # 根据请求的URI 

6. balance url_param，# 根据请求的URl参数'balance url_param' requires an URL parameter name 

7. balance hdr(name) # 根据HTTP请求头来锁定每一次HTTP请求 

8. balance rdp-cookie(name) # 根据据cookie(name)来锁定并哈希每一次TCP请求 

配置

https://www.jianshu.com/p/baa296770bd5
