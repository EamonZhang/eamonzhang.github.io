---
title: "数据库 ssl认证"
date: 2020-06-03T15:06:15+08:00
draft: false
---

#### SSL双向认证和SSL单向认证的区别


双向认证 SSL 协议要求服务器和用户双方都有证书。单向认证 SSL 协议不需要客户拥有CA证书，服务器端不会验证客户证书，以及在协商对称密码方案，对称通话密钥时，服务器发送给客户的是没有加过密的(这并不影响 SSL 过程的安全性)密码方案。

这样，双方具体的通讯内容，都是加过密的数据，如果有第三方攻击，获得的只是加密的数据，第三方要获得有用的信息，就需要对加密的数据进行解密，这时候的安全就依赖于密码方案的安全。

而幸运的是，目前所用的密码方案，只要通讯密钥长度足够的长，就足够的安全。这也是我们强调要求使用128位加密通讯的原因。

一般Web应用都是采用SSL单向认证的，原因很简单，用户数目广泛，且无需在通讯层对用户身份进行验证，一般都在应用逻辑层来保证用户的合法登入。但如果是企业应用对接，情况就不一样，可能会要求对客户端(相对而言)做身份验证。这时就需要做SSL双向认证。

由于单向认证和双向认证的区别仅在于创建连接阶段，数据的传输均为加密的，因此客户端与PG服务端的连接采取SSL单向认证即可，即仅在PG Server端配置SSL证书。

#### 生成自签名证书

- server.key – 私钥
- server.crt – 服务器证书
- root.crt – 受信任的根证书

```
创建私钥 ， 需要密码，随意输入
openssl genrsa -des3 -out server.key 1024

删除密码
openssl rsa -in server.key -out server.key

修改权限
chmod 400 server.key
```

```
创建基于server.key文件的服务器证书 有效期十年
openssl req -new -key server.key -days 3650 -out server.crt -x509

```

```
查看证书
openssl x509 -in server.crt -text -noout
```

```
为了得到自己签名的证书，把生成的服务器证书作为受信任的根证书，只需要复制并取一个合适的名字

cp server.crt root.crt
```


#### 数据库配置

将以上生成的证书文件拷贝到数据库的data目录下

修改所有者及访问属性

```
chown postgres:postgres server.key
chown postgres:postgres server.crt
chown postgres:postgres root.crt

chmod 400 server.key 
chmod 400 server.crt
chmod 400 root.crt 
```

修改数据库配置 postgresql.conf

```
ssl = on
ssl_ca_file = 'root.crt'
```

修改 pg_hba.conf

```
host all all 0.0.0.0/0 md5

# "host" is either a plain or SSL-encrypted TCP/IP socket,
# "hostssl" is an SSL-encrypted TCP/IP socket, 
# and "hostnossl" is a plain TCP/IP socket.
```
可对不同的database 分别设置

重新加载生效

```
systemctl reload postgresql-10
```

#### pgbouncer 配置

修改访问权限
```
chmod 644 server.key 
chmod 644 server.crt
chmod 644 root.crt
```
修改 pgbouncer 
```
;;;
;;; TLS settings for accepting clients
;;;

;; disable, allow, require, verify-ca, verify-full
client_tls_sslmode = require

;; Path to file that contains trusted CA certs
client_tls_ca_file = /etc/pgbouncer/ssl/root.crt

;; Private key and cert to present to clients.
;; Required for accepting TLS connections from clients.
client_tls_key_file = /etc/pgbouncer/ssl/server.key
client_tls_cert_file = /etc/pgbouncer/ssl/server.crt
```

重新加载生效

```
systemctl reload pgbouncer
```

#### 客户端连接

```
# psq -U postgres -p 5432 -h xxxx  
SSL 连接（协议：TLSv1.2，密码：ECDHE-RSA-AES256-GCM-SHA384，密钥位：256，压缩：关闭)
输入 "help" 来获取帮助信息.
```
