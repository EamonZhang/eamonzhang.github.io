---
title: "minio 轻量级对象存储"
date: 2019-03-18T16:59:48+08:00
draft: false
---

##### 简单了解

minio 完全实现了s3协议，使用简单方便。 支持多机模式，提高数据可用性和整体容量。

限制， 最多5T存储。 单个文件最大5T。 

缺点， 不能在线扩容。开发者认为扩容应该是开发人员需要解决的问题。


##### 安装及简单使用

服务端
```
#下载
wget https://dl.minio.io/server/minio/release/linux-amd64/minio
mv minio /usr/local/bin/
chmod 777 /usr/local/bin/minio 

#启动服务
minio server minidata/

Endpoint:  http://10.1.88.74:9000  http://172.17.0.1:9000  http://172.19.0.1:9000  http://172.21.0.1:9000  http://172.22.0.1:9000  http://172.23.0.1:9000  http://127.0.0.1:9000      
AccessKey: ZSYLNWA109W0Q4DWDS73 
SecretKey: kuqn+i1MpR0yoE9RoT59gYjRuB5IJdz8IhIZOqP9 

Browser Access:
   http://10.1.88.74:9000  http://172.17.0.1:9000  http://172.19.0.1:9000  http://172.21.0.1:9000  http://172.22.0.1:9000  http://172.23.0.1:9000  http://127.0.0.1:9000      

Command-line Access: https://docs.minio.io/docs/minio-client-quickstart-guide
   $ mc config host add myminio http://10.1.88.74:9000 ZSYLNWA109W0Q4DWDS73 kuqn+i1MpR0yoE9RoT59gYjRuB5IJdz8IhIZOqP9

Object API (Amazon S3 compatible):
   Go:         https://docs.minio.io/docs/golang-client-quickstart-guide
   Java:       https://docs.minio.io/docs/java-client-quickstart-guide
   Python:     https://docs.minio.io/docs/python-client-quickstart-guide
   JavaScript: https://docs.minio.io/docs/javascript-client-quickstart-guide
   .NET:       https://docs.minio.io/docs/dotnet-client-quickstart-guide

#后台启动,也可做成服务模式，由systemd管理
nohup minio server minidata/ > log &
```

客户端

```
#下载
wget https://dl.minio.io/client/mc/release/linux-amd64/mc
mv mc /usr/local/bin/
chmod 777 /usr/local/bin/mc 
#根据服务启动信息配置连接
mc config host add myminio http://10.1.88.74:9000 ZSYLNWA109W0Q4DWDS73 kuqn+i1MpR0yoE9RoT59gYjRuB5IJdz8IhIZOqP9

#简单应用
mc  cp  /var/lib/pgsql/10/data/pg_wal/00000001000000C40000006A myminio/mb1
...sql/10/data/pg_wal/00000001000000C40000006A:  16.00 MB / 16.00 MB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 100.00% 96.81 MB/s 0s

```
