---
title: "Ansible Modules"
date: 2018-10-25T10:12:59+08:00
draft: false
---

##### 准备工作

+ 安装 
 
```
yum install ansible-doc.noarch ansible.noarch -y

tree /etc/ansible/
/etc/ansible/
├── ansible.cfg
├── hosts
└── roles

ansible --version
ansible 2.7.0
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Jul 13 2018, 13:06:57) [GCC 4.8.5 20150623 (Red Hat 4.8.5-28)]
```

+ 配置清单

```
cat hosts 
[webservers]
10.1.88.72
10.1.88.73

```

+ [免密登录](../linux/no-passwd)


##### 常用命令
```
Usage: ansible <host-pattern> [options]

    常用选项：

        -m MOD_NAME  

        -a MOD_ARGS

获取模块列表：ansible-doc -l

获取指定模块的使用帮助：ansible-doc -s MOD_NAME
```
+ ping 

尝试连接到主机，验证并返回pong成功。  

```
ansible all -m ping
10.1.88.73 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
10.1.88.72 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}

```
+ command 

在远程主机执行命令, -m 默认模块为 commend, 可以省略 。 

```
ansible all -a 'cat /etc/centos-release' 
10.1.88.72 | CHANGED | rc=0 >>
CentOS Linux release 7.5.1804 (Core) 

10.1.88.73 | CHANGED | rc=0 >>
CentOS Linux release 7.5.1804 (Core) 
```

+ shell 

与command模快使用一致，但是，变量 和操作符号 "<", ">", "|", ";" and "&" 能正常工作 

```
ansible all -m shell -a 'echo $LANG'
10.1.88.73 | CHANGED | rc=0 >>
en_US.UTF-8

10.1.88.72 | CHANGED | rc=0 >>
en_US.UTF-8

```

+ script

把脚本复制到远程节点后，在远程节点本地运行脚本

```
cat script.sh 
#!/bin/bash
touch /tmp/a.tmp
echo 'ok'

ansible all -m script -a './script.sh '

``` 

+ copy
 
复制文件或目录到远程节点。默认会覆盖目标文件

```
文件
ansible all -m copy -a "src=./script.sh dest=/tmp/ mode=666"

目录
ansible all -m copy -a "src=/home dest=/tmp/ "
```
+ fetch

从远程获取文件（只能是文件）

```
单机
ansible 10.1.88.72 -m fetch -a "src=/var/log/messages dest=/tmp/"
组
ansible all -m fetch -a "src=/var/log/messages dest=/tmp/"

tree /tmp/
/tmp/
├── 10.1.88.72
│   └── var
│       └── log
│           └── messages
├── 10.1.88.73
│   └── var
│       └── log
│           └── messages

```
+ file 

设置远程节点的文件的文件属性

```
ansible all -m file -a 'path=/tmp/abc.txt state=touch mode=0666 owner=user1'   

- state 参数说明 
  - directory：如果目录不存在，创建目录
  - file：即使文件不存在，也不会被创建
  - link：创建软链接
  - hard：创建硬链接
  - touch：如果文件不存在，则会创建一个新的文件，如果文件或目录已存在，则更新其最后修改时间
  - absent：删除目录、文件或者取消链接文件。相当于rm -rf

```
+ cron

计划任务

+ yum

程序包管理

```
ansible all -m yum -a 'name=ntp state=latest'

- state 
  - present|latest 安装
  - absent 删除

查看源　& 验证
ansible all -a 'yum info ntp'

``` 
+ yum_repository

yum源管理

+ service

服务管理

```
ansible all -m service -a 'name=ntpd enabled=true  state=started'

- name 服务名
- enabled 是否开机启动
- state 
  - started 
  - reloaded
  - restarted
  - started
  - stopped

```
+ user

用户管理

```
新建用户
ansible all -m user -a "name=user123 state=present"
删除用户并清除home 目录
ansible all -m user -a "name=user123 state=absent remove=yes"

- name 用户名
- state 
  - present 新建
  - absent 删除
```

+ group 

用户组管理

```
ansible all -m group -a "name=group123 state=present"

- name 用户组
- state
  - present 创建
  - absent 删除
```

+ get_url

从 HTTP, HTTPS, or FTP 下载文件
```
ansible all -m get_url -a "url=https://resource.uucin.com/docker/docker-ce-18.03.1.ce-1.el7.centos.x86_64.rpm dest=/tmp mode=0666"

```

+ lineinfile

替换一个文件中特定的行

```
ansible all -m lineinfile -a "path=/etc/selinux/config regexp=^SELINUX= line=SELINUX=disabled"

```

+ replace

替换一个文件中符合匹配的所有行

+ setup

获取系统属性变量

+ sysctl

```
      ignoreerrors:          # Use this option to ignore errors about unknown keys.
      name:                  # (required) The dot-separated path (aka `key') specifying the sysctl variable.
      reload:                # If `yes', performs a `/sbin/sysctl -p' if the `sysctl_file' is updated. If `no', does not reload `sysctl' even if the `sysctl_file' is updated.
      state:                 # Whether the entry should be present or absent in the sysctl file.
      sysctl_file:           # Specifies the absolute path to `sysctl.conf', if not `/etc/sysctl.conf'.
      sysctl_set:            # Verify token value with the sysctl command and set with -w if necessary
      value:                 # Desired value of the sysctl key.
```

+ blockinfile
 
 name: Insert/update/remove a text block surrounded by marker lines

```
  insertafter 修改的标记点 
  insertbefore
  path 目标文件
  block 内容
```

