---
title: "Mysql 入门"
date: 2019-02-21T14:31:26+08:00
draft: false
categories: ["mysql"]
toc: true

---
## 安装 & 启动

#### 安装
```
rpm -i https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
yum install mysql-community-server.x86_64
```

#### 启动
```
systemctl start mysqld
systemctl enable mysqld
```

### 查看临时密码
```
#sudo grep 'temporary password' /var/log/mysqld.log
2019-05-15T06:42:54.826106Z 5 [Note] [MY-010454] [Server] A temporary password is generated for root@localhost: DVjSsl-ZX5f7
```

#### 修改密码
```
#mysql -uroot -p
ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass4!';
```
## 常用命令

#### 连接
```
mysql -h127.0.0.1 -P 3306  -uroot -p
```

#### 版本

```
#mysql -V
mysql  Ver 8.0.26 for Linux on x86_64 (MySQL Community Server - GPL)

```

数据库命令
```
mysql>help show

```

## 权限管理 

mysql登陆用户权限校验主要是通过用户名密码+访问来源主机方式

#### 创建用户
```
CREATE USER 'finley'@'localhost' IDENTIFIED BY 'password';
```

#### 赋权限
```
GRANT ALL ON *.*  TO 'finley'@'localhost' WITH GRANT OPTION;
```

#### 收回权限
```
REVOKE ALL ON *.*  FROM 'finley'@'localhost';
```

#### 查看
```
select host,user from mysql.user;

SHOW GRANTS FOR 'finley'@'localhost';
```

#### 删除
```
DROP USER 'finley'@'localhost';
```

## 常见错误

```
连接时被拒绝
ERROR 1130 (HY000): Host '10.1.88.32' is not allowed to connect to this MySQL server

修改访问来源IP
update user set host = '%' where host= 'localhost' and user = 'finley';
FLUSH PRIVILEGES;
```

```
连接时客户端报错
ERROR 2059 (HY000): Authentication plugin 'caching_sha2_password' cannot be loaded: /usr/lib64/mysql/plugin/caching_sha2_password.so: cannot open shared object file: No such file or directory

修改plugin类型
ALTER USER 'custom'@'%' IDENTIFIED WITH mysql_native_password BY '1qa@WS3ed';
FLUSH PRIVILEGES;

select host,user ,plugin from mysql.user;
``` 


## 配置管理

#### 命令行配置
```
查看所用配置参数
show variables;

查看某个指定的配置参数
show variables like '%max_heap_table_size%';  
+---------------------+----------+   
| Variable_name       | Value    |
+---------------------+----------+
| max_heap_table_size | 16777216 |
+---------------------+----------+

设置参数
set max_heap_table_size = 167772160;                                                   
```

#### 配置文件,基本配置
vi /etc/my.cnf
```
[mysql]
prompt = [\\u@\\p][\\d]>\\_
tee = "/tmp/tee.log"  ##设置客户端的查询日志
pager = "less -i -n -S"  ##分页显示查询出的数据，方便搜索查询到的数据
auto-rehash  ##预读取元数据,可以tab 补齐表名
#lower_case_table_names=1 ##对表名大小写不敏感
max_allowed_packet = 20M ## 服务端接收最大数据包

## 慢查询
slow_query_log=on
slow_query_log_file=/var/log/slow_mysql.log
long_query_time=10

skip-name-resolve # 跳过对连接的客户端进行DNS反向解析

```


## 数据类型 

## 数据库备份 

```
-- 数据导出
mysqldump -h 10.1.88.74 -u custom -P 3306 --databases sbtest  -v -p > backup.sql

-- 数据导入
mysql -h 10.1.88.74 -u custom -P 3306  -D sbtest -p < backup.sql 
```

## 状态查看
```
#1.显示状态信息：
#1.1.session（默认）：取出当前窗口的执行；
#1.2.global：从mysql启动到现在
mysql> SHOW [SESSION|GLOBAL] STATUS LIKE '%Status_name%';
#2.查看查询次数（插入次数com_insert、修改次数com_insert、删除次数com_delete）
mysql> SHOW STATUS LIKE 'com_select';
#3.查看连接数(登录次数)
mysql> SHOW STATUS LIKE 'connections';
#4.数据库运行时间
mysql> SHOW STATUS LIKE 'uptime';
#5.查看慢查询次数
mysql> SHOW STATUS LIKE 'slow_queries';
#6.查看索引使用的情况：
#6.1。handler_read_key：这个值越高越好，越高表示使用索引查询到的次数。
#6.2.handler_read_rnd_next：这个值越高，说明查询低效。
mysql> SHOW STATUS LIKE 'handler_read%';
```

#### 高可用&主从架构

#### 监控 

#### explain执行计划  

#### 增量，全量备份

#### 周边工具 

- 客户端命令自动补齐工具 [mycli](https://github.com/dbcli/mycli)
 
