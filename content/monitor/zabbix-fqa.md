---
title: "Zabbix FQA"
date: 2018-12-24T16:53:20+08:00
draft: false
---
## 如何使用篇

- 如何安装  

[安装文档](https://www.zabbix.com/download?zabbix=4.0&os_distribution=centos&os_version=7&db=PostgreSQL)

架构模型为服务端、被监控端。   
被监控端agent安装在需要被监控的主机上，负责收集被监控主机相关状态的信息指标如内存，cup，网络等。  
服务端负责汇总所有agent的信息，如存储，处理，展现。数据存放在指定的数据库中如mysql pg。

需安装软件说明

zabbix-server-pgsql 服务端   
zabbix-web-pgsql    服务端界面  
zabbix-agent        被监控端，与被监控端安装在一起


- 常用模块说明

``` 
Administration
   Users 新建属于自己的用户，禁用guest，慎用admin
      user 用户名 密码
      media 接收信息
      premissions 权限

   Media type 媒体类型，用于配置发送报警媒介， Email或自定义脚本
     Email 配置系统发送邮件 163为例 
            Name email
            Type Email
            SMTP server smtp.163.com
SMTP server port 25
     SMTP helo   smtp.163.com
     SMTP email  注册的邮箱地址
       Username  注册的用户名
       password  密码

Configuration 
   Hosts 管理被监控的主机
     host 配置被监控的主机
     Templates 监控的内容模版
   Actions 触发报警时的动作，一般给管理员方法信息
   Discovery 自动发现

Monitoring

```  

## FQA

- Too Many Process

原因: 被监控的主机进程数过多或默认的触发条件过低 
分析: 

```
获取当前进程数 ， 127.0.0.1 改为对应节点IP
zabbix_get -s 127.0.0.1 -k 'proc.num[]'  

查询是哪个应用占有的,如查看zabbix-agent占有进程数量
zabbix_get -s 127.0.0.1 -k 'proc.num[zabbix]'

比较有效的方法,将zabbix 换成想要查看的应用

ps -ef | wc
ps -ef | grep zabbix | wc  

```

[更多](https://www.zabbix.com/documentation/4.0/zh/manual/appendix/items/proc_mem_num_notes?s[]=proc&s[]=num)

默认的触发值过低300 在实际的生产环境中改为1000

- zabbix poller processes more than 75% busy

原因: 当被监控的主机逐渐增多时。zabbix server 端如果采用被动模式时，server 主机的性能会遇到瓶颈。

处理方法:  StartPollers 增加 

vi zabbix_server.conf
```
### Option: StartPollers
#       Number of pre-forked instances of pollers.
#
# Mandatory: no
# Range: 0-1000
# Default:
# StartPollers=5
StartPollers=20
```

注意观察数据库连接数

- 修改数据库连接配置

```
vi /etc/zabbix/web/zabbix.conf.php
```
