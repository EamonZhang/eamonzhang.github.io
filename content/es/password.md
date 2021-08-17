---
title: "设置密码"
date: 2019-09-12T15:31:15+08:00
draft: false
---

#### ElasticSearch 设置密码

以前在使用es的时候基本是裸，没有任何的权限管理。用户名密码设置。

配置 elasticsearch.yaml 添加，重启服务

```
xpack.security.enabled: true
xpack.security.transport.ssl.enabled: true
```

设置用户密码

```
/usr/share/elasticsearch/elasticsearch-setup-passwords interactive

Initiating the setup of passwords for reserved users elastic,kibana,logstash_system,beats_system.
You will be prompted to enter passwords as the process progresses.
Please confirm that you would like to continue [y/N]y
Enter password for [elastic]: 
passwords must be at least [6] characters long
Try again.
Enter password for [elastic]: 
Reenter password for [elastic]: 
Passwords do not match.
Try again.
Enter password for [elastic]: 
Reenter password for [elastic]: 
Enter password for [kibana]: 
Reenter password for [kibana]: 
Enter password for [logstash_system]: 
Reenter password for [logstash_system]: 
Enter password for [beats_system]: 
Reenter password for [beats_system]: 
Changed password for user [kibana]
Changed password for user [logstash_system]
Changed password for user [beats_system]
Changed password for user [elastic]

```


修改密码

```
curl -H "Content-Type:application/json" -XPOST -u elastic 'http://127.0.0.1:9200/_xpack/security/user/elastic/_password' -d '{ "password" : "123456" }'
```

##### 说明

elastic 为超级用户

#### 应用

修改kibana配置文件,config下的kibana.yml,添加如下内容

```
elasticsearch.username: "elastic"
elasticsearch.password: "123456"

```

修改logstash配置文件 logstash.yaml 及 conf

```
xpack.management.elasticsearch.username: "elastic"
xpack.management.elasticsearch.password: "123456"
xpack.management.elasticsearch.hosts: ["https://127.0.0.1:9200"]
```

```
 elasticsearch {
   hosts => "127.0.0.1:9200"
   manage_template => false
   index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
   user => "elastic"
   password => "123456"
 }
```
