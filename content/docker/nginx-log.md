---
title: "Nginx log 切割"
date: 2018-12-05T11:00:10+08:00
draft: false
---

#### Docker nginx 日志切割
docker 在运行 nginx 日志容器时，将日志挂载到实体机/var/log/nginx/* .log　中.

一般直接运行的nginx服务都会自带logrotate进行日志切分, 由docker方式安装的nginx 缺失日志切割功能!

##### 添加logrotate

cat /etc/logrotate.d/nginx 
```
/var/log/nginx/*.log {
        daily
        missingok
        rotate 52
        compress
        delaycompress
        notifempty
        create 666 root root
        sharedscripts
        postrotate
           # [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
            docker inspect -f '{{ .State.Pid }}' nginx | xargs kill -USR1
        endscript
}

```


