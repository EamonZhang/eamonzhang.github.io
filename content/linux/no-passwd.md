---
title: "ssh 免密码登&跳板机配置"
date: 2018-10-18T14:46:58+08:00
draft: false
---

#### Linux 免密码登录实现

1.说明

DES算法 加/解速度快,密钥量短,采用对称加密　

RSA算法好 算法复杂,加/解速度慢,采用非对称加密　

2.生成秘钥

```
$ssh-keygen -t dsa -P ''
Generating public/private dsa key pair.
Enter file in which to save the key (/root/.ssh/id_dsa): 
Your identification has been saved in /root/.ssh/id_dsa.
Your public key has been saved in /root/.ssh/id_dsa.pub.
The key fingerprint is:
SHA256:/K/dqHKbkmm/0qw9IOFvZwRAPx36+yQtXtLM353spns root@kvm71
The key's randomart image is:
+---[DSA 1024]----+
|     ..   .      |
|      .. o .     |
|       .+ .      |
|      ...o       |
|     . .S..      |
|      o ...*     |
|       o B* B    |
|        XoB@ +.Eo|
|       o.XX*=oO+o|
+----[SHA256]-----+

```
查看本地生成的公钥和私钥

```
$ ll ~/.ssh/
total 16
-rw------- 1 root root 600 10月 18 15:14 authorized_keys
-rw------- 1 root root 668 10月 18 15:01 id_dsa
-rw-r--r-- 1 root root 600 10月 18 15:01 id_dsa.pub
-rw-r--r-- 1 root root 516 10月 18 15:13 known_hosts
```

3.拷贝公钥到目标机

```
[root@kvm71 ~]# ssh-copy-id 10.1.88.72
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_dsa.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
root@10.1.88.72's password: 

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh '10.1.88.72'"
and check to make sure that only the key(s) you wanted were added.

```

在10.1.88.72上查看 

```
$ cat ~/.ssh/authorized_keys 
ssh-dss AAAAB3NzaC1kc3MAAACBAOpJ6cmiyh504HrttEpLbECs8GbNNZAKbKRNvAhZYGYkUNTFM4/G6Obom+PNHaTYh0H4gQ+Zqluo0jyk7UGaGv2fWL9VBMq57BumXpG33XkmzQHmOdxc4E7BuIZyqEBtyObbDtB2QMfaIb6jnurSl2RdIWmGB42eaBpUPxzFYgDpAAAAFQDbQCsDfqhxJQfFLcT8PX0bkuuIJwAAAIAdTYC7dkP+Se2JGWNFUpcGTJQsAVQmTXuXOCe9JBwSJkFc2Ed6VLOLLnk04gawTHBUMrKaT6dvzl/Wm0B3FLkSsMzuJA191ezp7USmR1aDnHmncZcVLsLPaN5Bx15+v6QlFrJISro5AQZWbTHmoIjYJ1jTvrPYSDaZp3iTzJVQAAAAAIBMNhLMxe+Ojl3ppbIe4jISPymzwvev3ud/1JypLZyAIBd5ViTfwjw0oKOcRHJ7xCcMxDrmKaAY5z10xGkQtNIkdYWe5iPXB6f4BO28WgRfmhkk9dDyfGzUEjcXpjBg0De2wnZzZeyOrxjHQVIHpp5VeCJ5H3iolhXUCeWOmlS3Hg== root@kvm71
```

4.验证
```
[root@kvm71 ~]# ssh '10.1.88.72'
[root@kvm72 ~]# 

```

成功!!!

#### ssh 跳板机

ssh proxycommand

1. 说明 ：

- 客户端 C
- 跳板机 J
- 服务器 S

传统方式 C 通过先登陆J ,再登陆S
跳板机方式  C 可以直接登陆S，不需要先登陆J

2. 配置

- C 的公钥拷贝到S
- 配置C 的用户下的.ssh/config文件

```
Host 10.1.88.72
    User root
    Port 22
    ForwardAgent yes
    ProxyCommand ssh -p 22 root@10.1.88.1 -W %h:%p 2> /dev/null
```  
10.1.88.72 S 服务器  
10.1.88.1  J 跳板机 


登陆方式 

```
ssh root@10.1.88.72
```

3. 通配符方式

当存在更过的服务器，或新增服务器时，如果每次都修改配置文件难免显得不够方便，太low。 由于无论是先有的服务器还是新增的服务器ip应该是在同一个网段或有规律。这样更方便生成通配符来匹配。

```
host 10.1.88.*
    User root
    Port 22
    ForwardAgent yes
    ProxyCommand ssh -p 22 root@10.1.88.1 -W %h:%p 2> /dev/null
```

登陆方式

```
ssh root@10.1.88.72
```
