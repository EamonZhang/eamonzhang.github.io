---
title: "nginx"
date: 2019-04-09T15:42:15+08:00
draft: false
---

[性能优化](https://mp.weixin.qq.com/s/YoZDzY4Tmj8HpQkSgnZLvA)

- 错误码 502   ， error.log 中错误信息 [error] 236#236: *8371899 upstream sent too big header while reading response header from upstream,

问题 header 过大
```
proxy_buffer_size 64k;
proxy_buffers   4 32k;
proxy_busy_buffers_size 64k;
```
[官网说明](http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffer_size)


#### 利用nginx设置用户登陆认证

如下举例设置用户访问kibana时登陆认证
```
server {
   listen 80;
   server_name kibana.×××.com;
   location / {
      auth_basic "secret";
      auth_basic_user_file /etc/nginx/db/passwd.db;
      proxy_pass http://****:5601;
      proxy_set_header Host $host:5601;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header Via "nginx";
   }
   access_log off;
}
```

2、配置登录用户名(admin)，密码

```
htpasswd -c /etc/nginx/db/passwd.db admin
New password: 
Re-type new password: 
Adding password for user admin
```
htpasswd是apache自带的小工具，如果找不到该命令，尝试用yum install httpd安装

```
cat db/passwd.db 
admin:$apr1$Jc.x0rme$BWrmulBqUj.g6BeeoEM79/
```

[访问频率控制](https://www.cnblogs.com/zhangeamon/p/9341807.html)

[backend 后端服务健康检测](https://www.cnblogs.com/zhangeamon/p/9341788.html)




