---
title: "Centos 登陆安全管理"
date: 2020-05-09T16:20:05+08:00
draft: false
---

#### 禁用root登陆

注意： 创建一个非root用户 并加入wheel用户组（拥有sudo权限）
```
useradd NewUser

passwd NewUser

gpasswd -a NewUser wheel
```

###### 本地禁用root登陆


修改/etc/pam.d/login文件增加下面一行
```
auth required pam_succeed_if.so user != root quiet
```

###### 远程禁用root登陆

修改 /etc/ssh/sshd_config
```
#PermitRootLogin yes
PermitRootLogin no
```

#### 修改ssh默认端口

修改 /etc/ssh/sshd_config
```
#Port 22
Port 46608
```

#### 安全认证

```
LoginGraceTime 2m
PermitRootLogin no
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10
```

#### 超时退出

例如客户端60秒无操作自动退出
```
export TMOUT=60
```
加入系统环境变量中 如：/etc/profile


#### 密码过期时间

修改 /etc/login.defs
```
PASS_MAX_DAYS 90 #密码最长过期天数
PASS_MIN_DAYS 80 #密码最小过期天数
PASS_MIN_LEN 10 #密码最小长度
PASS_WARN_AGE 7 #密码过期警告天数
```

#### 登陆错误锁定

###### 使用方式直接使用ssh 密钥登陆 ， 后面的方法自找麻烦
```
ssh-keygen 生成钥匙

ssh-copy-id 将公钥上传到被访问的服务器

PermitRootLogin without-password 修改sshd_config文件设置禁止root密码登陆

PasswordAuthentication no  修改sshd_config文件禁止普通用户密码登陆
```

连续密码错误3次锁定账户，普通用户5分钟后解锁，root用户10分钟后解锁

###### 方法 一 

vi /etc/pam.d/system-auth
```
auth        required     pam_tally2.so    deny=3 unlock_time=300 even_deny_root root_unlock_time=600 
account     required     pam_tally2.so
```

查看 
```
pam_tally2 -u zhangeamon
```
手动解锁
```
pam_tally2 -u zhangeamon -r
```

###### 方法 二 

Centos 8 后 pam_tally2.so 过期，推荐 pam_faillock.so

vi /etc/pam.d/system-auth
```
auth  required  pam_faillock.so preauth silent audit deny=3 unlock_time=300 even_deny_root root_unlock_time=600
auth  sufficient pam_unix.so nullok try_first_pass
auth  [default=die] pam_faillock.so authfail audit deny=3
account  required  pam_faillock.so
```
注意顺序

查看
```
faillock -u zhangeamon
```
解锁
```
faillock -u zhangeamon -r
```



#### 密码复杂度

登陆失败可以重试3次；密码最小长度8；最少包括2个大写字母；最少包含4个小写字母；最少包含一个数字；最好包含一个特殊字符

vi /etc/pam.d/system-auth
```
password    requisite    pam_cracklib.so    try_first_pass retry=3 type= minlen=8 ucredit=-2 lcredit=-4 dcredit=-1 ocredit=-1  
```
