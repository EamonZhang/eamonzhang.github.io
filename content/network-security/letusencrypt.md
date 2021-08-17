---
title: "Let's Encrypt 通配符证书"
date: 2018-10-22T13:56:11+08:00
draft: false
---
1.介绍

##### 什么是 Let's Encrypt？
部署 HTTPS 网站的时候需要证书，证书由 CA 机构签发，大部分传统 CA 机构签发证书是需要收费的，这不利于推动 HTTPS 协议的使用。
Let's Encrypt 也是一个 CA 机构，但这个 CA 机构是免费的！也就是说签发证书不需要任何费用。
Let's Encrypt 由于是非盈利性的组织，需要控制开支，他们搞了一个非常有创意的事情，设计了一个 ACME 协议，目前该协议的版本是 v1。
那为什么要创建 ACME 协议呢，传统的 CA 机构是人工受理证书申请、证书更新、证书撤销，完全是手动处理的。而 ACME 协议规范化了证书申请、更新、撤销等流程，只要一个客户端实现了该协议的功能，通过客户端就可以向 Let's Encrypt 申请证书，也就是说 Let's Encrypt CA 完全是自动化操作的。
任何人都可以基于 ACME 协议实现一个客户端，官方推荐的客户端是Certbot 。

##### 什么是通配符证书
在没有出现通配符证书之前，Let's Encrypt 支持两种证书。

1）单域名证书：证书仅仅包含一个主机。

2）SAN 证书：一张证书可以包括多个主机（Let's Encrypt 限制是 20），也就是证书可以包含下列的主机：www.example.com、www.example.cn、blog.example.com 等等。
证书包含的主机可以不是同一个注册域，不要问我注册域是什么？注册域就是向域名注册商购买的域名。
对于个人用户来说，由于主机并不是太多，所以使用 SAN 证书完全没有问题，但是对于大公司来说有一些问题：
子域名非常多，而且过一段时间可能就要使用一个新的主机。
注册域也非常多。
读者可以思考下，对于大企业来说，SAN 证书可能并不能满足需求，类似于 sina 这样的网站，所有的主机全部包含在一张证书中，而使用 Let's Encrypt 证书是无法满足的。

##### Let's Encrypt 通配符证书
通配符证书就是证书中可以包含一个通配符，比如 .example.com、.example.cn，读者很快明白，大型企业也可以使用通配符证书了，一张证书可以防止更多的主机了。
这个功能可以说非常重要，从功能上看 Let's Encrypt 和传统 CA 机构没有什么区别了，会不会触动传统 CA 机构的利益呢？

##### 如何申请 Let's Encrypt 通配符证书
为了实现通配符证书，Let's Encrypt 对 ACME 协议的实现进行了升级，只有 v2 协议才能支持通配符证书。
也就是说任何客户端只要支持 ACME v2 版本，就可以申请通配符证书了，是不是很激动。

##### 如何验证域名的所属权

客户在申请 Let's Encrypt 证书的时候，需要校验域名的所有权，证明操作者有权利为该域名申请证书，目前支持三种验证方式：
dns-01：给域名添加一个 DNS TXT 记录。

http-01：在域名对应的 Web 服务器下放置一个 HTTP well-known URL 资源文件。

tls-sni-01：在域名对应的 Web 服务器下放置一个 HTTPS well-known URL 资源文件。

而申请通配符证书，只能使用 dns-01 的方式。

2.实践

2.1 基本环境准备  
 
yum -y install yum-utils  
yum-config-manager --enable rhui-REGION-rhel-server-extras rhui-REGION-rhel-server-optional  
sudo yum install python2-certbot-nginx  

2.2 申请证书

certbot  --server https://acme-v02.api.letsencrypt.org/directory -d "*.zhangeamon.top" --manual --preferred-challenges dns-01 certonly
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org
Obtaining a new certificate
Performing the following challenges:
dns-01 challenge for zhangeamon.top

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NOTE: The IP of this machine will be publicly logged as having requested this
certificate. If you're running certbot in manual mode on a machine that is not
your server, please ensure you're okay with that.

Are you OK with your IP being logged?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(Y)es/(N)o: y

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.zhangeamon.top with the following value:

Nyej3i187An7ZqIEeUQ_MC6-OrS0jyKOAxkMHuBbItQ

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/zhangeamon.top/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/zhangeamon.top/privkey.pem
   Your cert will expire on 2019-01-20. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le

```

2.3 注意事项  

在执行上面的命令时，需要使用txt类型的DNS记录。　在DNS上新建一条Txt 记录,并验证。
dig  -t txt  _acme-challenge.zhangeamon.top @8.8.8.8 
```
; <<>> DiG 9.9.4-RedHat-9.9.4-61.el7_5.1 <<>> -t txt _acme-challenge.zhangeamon.top @8.8.8.8
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 40197
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 512
;; QUESTION SECTION:
;_acme-challenge.zhangeamon.top.	IN	TXT

;; ANSWER SECTION:
_acme-challenge.zhangeamon.top.	599 IN	TXT	"Nyej3i187An7ZqIEeUQ_MC6-OrS0jyKOAxkMHuBbItQ"

;; Query time: 1169 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Oct 22 13:52:53 CST 2018
;; MSG SIZE  rcvd: 115
```

txt　记录生效后继续上面的执行，生成证书

/etc/letsencrypt/live/zhangeamon.top/fullchain.pem  
/etc/letsencrypt/live/zhangeamon.top/privkey.pem 

3.查看

certbot certificates -d "*.zhangeamon.top"
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following matching certs:

  Certificate Name: zhangeamon.top
    Domains: *.zhangeamon.top
    Expiry Date: 2019-01-20 04:39:47+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/zhangeamon.top/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/zhangeamon.top/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

```

[参见1](https://certbot.eff.org/lets-encrypt/centosrhel7-nginx)  
[参见2](http://www.infoq.com/cn/news/2018/03/lets-encrypt-wildcard-https)

[过期检测](https://github.com/caotritran/Zabbix_SSL_Check_Expired)
