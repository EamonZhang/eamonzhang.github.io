---
title: "Centos mail"
date: 2018-12-29T16:53:16+08:00
draft: false
---

##### 介绍

电子邮件系统包括两个组件：
- MUA(Mail User Agent,邮件用户代理）为用户提供的可以读写邮件的界面,例如 Foxmail, Outlook
- MTA(Mail Transport Agent,邮件传送代理）MTA是运行在底层，能够处理邮件的收发工作的程序

邮件的接收是MTA和MUA配合完成的。远程的MUA首先向远程MTA连接并验证发信人身份，然后由远程MTA向本地MTA发送邮件。
接受者通过本地MUA接收阅读邮件。邮件的发信也是MTA和MUA配合完成的，不过方向正好相反。本地MUA首先向本地的MTA连接并验证发信人身份，然后由本地MTA向远程MTA发送邮件，再由远程的MUA读取邮件。

##### mailx 和 sentmail

- mail和mailx即为负责查看、编写邮件和向MTA发送邮件的MUA。mailx是mail的功能加强版。 
- sendmail即为负责邮件在网络上传输的MTA，将邮件从一个MTA传送至另一个MTA。

##### mailx 安装及配置
```
yum install mailx -y

vi /etc/mail.rc 

set sendcharsets=iso-8859-1,utf-8
set from=xxx@XXX.com
set smtp=smtp.XXX.com:25
set smtp-auth-user=xxx@XXX.com  #认证用户
set smtp-auth-password=xxx    #认证密码
```

测试

```
echo"zabbix test " |mail -s "zabbix" xxx@xxx.com #如果邮箱中能收到邮件，表示测试成功。
```

