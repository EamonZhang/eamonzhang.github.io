---
title: "APM"
date: 2018-11-06T13:39:01+08:00
draft: false
---
https://www.elastic.co/solutions/apm

##### 应用程序性能监控

###### 整体架构

<img src="images/apm.png" width="60%" height="10%" />

###### 先搞起来

- agent 收集信息
- apm-server 接受agent信息并发送到ES
- ES 存储信息
- Kibana 信息检索展示

agent python django 
```
安装扩展包
 pip install elastic-apm

django 配置
# Add the agent to the installed apps
INSTALLED_APPS = (
   'elasticapm.contrib.django',
   #...
 
)


ELASTIC_APM = {
 #  Set required service name.
 # Allowed characters:
  # a-z, A-Z, 0-9, -, _, and space
  'SERVICE_NAME': 'my-app',
  #后台进程
  'TRANSPORT_CLASS': 'elasticapm.transport.http.AsyncTransport',
  # Use if APM Server requires a token
  #'SECRET_TOKEN': '',
 # 没有数据可以开启debug查看
 # 'DEBUG': True,
  # Set custom APM Server URL (
  # default: http://localhost:8200)
  #
  'SERVER_URL': 'http://10.1.88.73:8200',

}
# To send performance metrics, add our tracing middleware:
MIDDLEWARE = (
   'elasticapm.contrib.django.middleware.TracingMiddleware',
   #...
)


```
ElasticSearch

```
docker run -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:6.2.4
```
Kibana

```
docker run -d -e ELASTICSEARCH_URL=http://10.1.88.73:9200 -p 5601:5601 docker.elastic.co/kibana/kibana:6.2.4
```

APM-Server

```

wget https://artifacts.elastic.co/downloads/apm-server/apm-server-6.4.2-linux-x86_64.tar.gz
tar xf apm-server-6.4.2-linux-x86_64.tar.gz
cd apm-server-6.4.2-linux-x86_64
./apm-server setup
./apm-server -e

```

完成之后，打开Kibana，就能看到APM增加的Dashboard和APM UI。
