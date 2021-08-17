---
title: "Nginx 状态监控"
date: 2020-04-20T11:12:28+08:00
draft: false
---

#### Nginx 开启status用以监控状态信息

Nginx 可以通过with-http_stub_status_module模块来监控nginx的一些状态信息。

##### 通过nginx -V来查看是否有with-http_stub_status_module该模块。

```
# nginx -V

nginx version: nginx/1.16.1
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-39) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-ipv6 --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-stream_ssl_preread_module --with-http_addition_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_perl_module=dynamic --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_ssl_module --with-google_perftools_module --with-debug --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -specs=/usr/lib/rpm/redhat/redhat-hardened-cc1 -m64 -mtune=generic' --with-ld-opt='-Wl,-z,relro -specs=/usr/lib/rpm/redhat/redhat-hardened-ld -Wl,-E'

```

##### 修改nginx.conf 

```
# 加入如下代码

  location =/nginx_status/ {
        # Turn on nginx stats
        stub_status on;
        # I do not need logs for stats
        access_log   off;
        # Security: Only allow access from IP #
        allow zabbix_server;
        # Send rest of the world to /dev/null #
        deny all;
    }

# end 
  ....
  
  location / {
    ....
  }

```

##### 重新启动nginx，并访问http://localhost/ngx_status。

```
Active connections: 1 
server accepts handled requests
 3 3 57 
Reading: 0 Writing: 1 Waiting: 0 
```

Active connections:  表示Nginx正在处理的活动连接数。

server: 表示Nginx启动到现在共处理了多少个连接

accepts: 表示Nginx启动到现在共成功创建几次握手

handled requests: 表示总共处理请求数

Reading:  Nginx 读取到客户端的 Header 信息数

Writing: Nginx 返回给客户端 Header 信息数

Waiting: Nginx 已经处理完正在等候下一次请求指令的驻留链接（开启keep-alive的情况下，这个值等于Active-(Reading+Writing)


[zabbix监控nginx](https://github.com/vicendominguez/nginx-zabbix-template)

[nginx-exporter](https://github.com/hnlq715/nginx-vts-exporter)
