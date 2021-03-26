---
title: "代理"
date: 2018-10-31T14:42:10+08:00
draft: false
---

#### 科普

- 正向代理 对服务端来说是无感的，服务端无需配置，要在客户端指定。代理的是客户端。 
  - 访问原来无法访问的资源  
  - 用作缓存，加速访问速度  
  - 对客户端访问授权，上网进行认证  
  - 代理可以记录用户访问记录（上网行为管理），对外隐藏用户信息 
- 反向代理  对客户端来说的无感的，客户端无需配置，要在服务端实现。代理的是服务端。
  - 保护内网安全 
  - 负载均衡 
  - 缓存，减少服务器的压力 

- 透明代理 与正向代理相同，但是客户端无需指定

  透明代理服务器阻断网络通信，并且过滤出访问外部的HTTP（80端口）流量。如果客户端的请求在本地有缓冲则将缓冲的数据直接发给用户，如果在本地没有缓冲则向远程web服务器发出请求，
其余操作和正向代理服务器完全相同。对于linux操作系统来说，透明代理使用Iptables或者Ipchains实现。因此不需要对浏览器作任何设置，所以，透明代理对于ISP（Internet服务器提供商）特别有用。

#### 应用 squid

docker-compose.yaml

```
version: '2'
services:
   squid3:
    image: sameersbn/squid:3.3.8-14
    ports:
     - 3128:3128
    volumes:
     - /etc/squid3/squid.conf:/etc/squid3/squid.conf
     - /var/log/squid3://var/log/squid3
     - /var/spool/squid3:/var/spool/squid3
    restart: always
    container_name: squid3

```

/etc/squid3/squid.conf  
```
acl Safe_ports port 80 # http
acl Safe_ports port 443 # https
acl CONNECT method CONNECT
cache_dir ufs /var/spool/squid3  100 16 256
http_access allow all
http_port 3128
visible_hostname proxy
```
#ufs:缓存数据的存储格式
#/var/spool/squid    缓存目录
#100：缓存目录占磁盘空间大小（M）
#16：缓存空间一级子目录个数
#256：缓存空间二级子目录个数

客户端使用配置
```
Environment=HTTP_PROXY={SERVER_IP}:3128
Environment=HTTPS_PROXY={SERVER_IP}:3128
```

示例
```
curl -x "https://SERVER_IP:3128" -LO https://lang-python.s3.amazonaws.com/heroku-16/runtimes/python-3.7.0.tar.gz
```

```
ll /var/spool/squid3

drwxr-x--- 258 13 13 8192 10月 31 11:39 00
drwxr-x--- 258 13 13 8192 10月 31 11:39 01
drwxr-x--- 258 13 13 8192 10月 31 11:39 02
drwxr-x--- 258 13 13 8192 10月 31 11:39 03
drwxr-x--- 258 13 13 8192 10月 31 11:39 0F
....
-rw-r-----   1 13 13   72 10月 31 11:39 swap.state
```

#### Varnish VS squid

##### varnish

- Varnish 可以认为是内存缓存，速度一流，但是内存缓存也限制了其容量，缓存页面和图片一般是挺好的； 
- varnish本身的技术上优势要高于squid，它采用了“Visual Page Cache”技术，在内存的利用上，Varnish比Squid具有优势，它避免了Squid频繁在内存、磁盘中交换文件，性能要比Squid高。 
- varnish是不能cache到本地硬盘上的。 
- Varnish可以使用正则表达式快速、批量地清除部分缓存 
- varnish的内存管理完全交给内核，当缓存内容超过内存阈值时，内核会自动将一部分缓存存入swap中让出内存。以挪威一家报社的经验，1台varnish可以抵6台squid的性能。 
- varnish用来做网站和小文件的缓存，相当给力的,做图片cache之类的合适 
- varnish没有专门的存储引擎 

##### squid

- squid是功能最全面的比较传统的web cache server，有自己的存储引擎。，但是架构太老，性能不怎样。 
- squid可以用于缓存更多更大的内容，属于专业用语缓存的功能，比如尤其适合缓存图片、文档等； 
- squid可以说是越俎代庖自己实现了一套内存页/磁盘页的管理系统，但这个虚拟内存swap其实linux内核已经可以做得很好，squid的多此一举反而影响了性能 
- squid支持正向代理缓存，而这方面varnish、nginx cache做不到 
