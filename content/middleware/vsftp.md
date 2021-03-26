---
title: "Centos FTP 服务"
date: 2018-12-05T09:24:29+08:00
draft: false
---

#### 利用vsftpd 搭建FTP 服务器

##### 安装
```
yum -y install vsftpd
```

##### 添加用户及设置密码

```
useradd -s /sbin/nologin -d /home/ftp_test ftp_test
passwd ftp_test
```
-s 禁止ssh登录主机         
-d 设置ftp_test 用户home 目录，用于存放数据 

##### 基础配置
vi /etc/vsftpd/vsftpd.conf
```
# 禁止匿名访问
anonymous_enable=NO
# 禁止dns解析 
reverse_lookup_enable=NO
```
##### 启动&开机自启
```
systemctl start vsftpd.service
systemctl enable vsftpd.service
```
##### filezilla 客户端验证
```
host: 服务器IP
port: 默认
user: 
password:
```
测试本地上传，远程下载，一切OK,感觉那么顺畅完美。

but可以访问到服务器中的所有文件和目录,似乎权限也忒大了。

接下来是入坑时间，有史以来最折磨的经历，总结出如下绕坑指南。

##### 限制只能访问用户自己的目录，对其他目录不可见

vi /etc/vsftpd/vsftpd.conf
```
chroot_local_user=YES
chroot_list_enable=YES
# (default follows)
chroot_list_file=/etc/vsftpd/chroot_list
```

创建文件 
```
touch /etc/vsftpd/chroot_list
```
chroot_list 中的用户不受限制

创建存储目录　data
```
mkdir /home/ftp_test/data
```

修改对应权限
```
chmod 777 home/ftp_test/ -R
chmod a-w home/ftp_test/
```

重启vsftpd 服务    
重新连接filezilla

##### 遇到问题

问题1 没有chroot_list 文件
500 OOPS: could not read chroot() list file:/etc/vsftpd/chroot_list 解决 创建 chroot_list 文件

问题2 
当我们限定了用户不能跳出其主目录之后，使用该用户登录FTP时往往会遇到这个错误：

500 OOPS: vsftpd: refusing to run with writable root inside chroot ()

这个问题发生在最新的这是由于下面的更新造成的：

- Add stronger checks for the configuration error of running with a writeable root directory inside a chroot(). This may bite people who carelessly turned on chroot_local_user but such is life.

从2.3.5之后，vsftpd增强了安全检查，如果用户被限定在了其主目录下，则该用户的主目录不能再具有写权限了！如果检查发现还有写权限，就会报该错误。
要修复这个错误，可以用命令chmod a-w /home/user去除用户主目录的写权限，注意把目录替换成你自己的。或者你可以在vsftpd的配置文件中增加下列两项中的一项：

allow_writeable_chroot=YES

问题3 

vsftp上传文件出现553 Could not create file
```
首先在ftp的目录中创建一个目录，然后设置权限为777
$ sudo mkdir /var/ftp/write
$sudo chmod -R 777 /var/ftp/write
然后修改vsftp的配置文件/etc/vsftpd.conf文件
在最后添加上
local_root=/var/ftp
```
问题4

客户端建立连接慢，尤其是离线状态

reverse_lookup_enable=NO

问题5 

530  Login incorrect

如果是root用户 原因是因为在 /etc/vsftpd/user_list /etc/vsftpd/ftpusers 中的用户禁止登陆    
如果是虚拟用户 检查 /etc/shells 看是否包括如下配置   

```
cat /etc/shells 
/sbin/nologin
/usr/sbin/nologin

```

原因认证错误

如果是密码错误可在vsftpd 日志中看到

pam 认证问题 ,去掉认证试试

```
vi /etc/pam.d/vsftpd 
#auth       required     pam_shells.so
``` 

问题5

550 Ubuntu 下只有读权限没有写权限

```
write_enable=YES
```

