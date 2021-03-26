---
title: "Ansible Overview"
date: 2018-10-25T09:16:22+08:00
draft: false
---

+ 主要模块

  - PLAYBOOKS： 任务剧本（任务集），编排定义Ansible任务集的配置文件，由Ansible顺序依次执行，通常是JSON格式的YML文件 
  - INVENTORY： Ansible管理主机的清单/etc/anaible/hosts 
  - MODULES：   Ansible执行命令的功能模块，多数为内置的核心模块，也可自定义,ansible-doc –l 可查看模块 
  - PLUGINS：   模块功能的补充，如连接类型插件、循环插件、变量插件、过滤插件等，该功能不常用 
  - API：       供第三方程序调用的应用程序编程接口 
  - ANSIBLE：   ansible命令工具，其为核心执行工具

+ 常用命令

  - /usr/bin/ansible	主程序，临时命令执行工具
  - /usr/bin/ansible-doc	查看配置文档，模块功能查看工具
  - /usr/bin/ansible-playbook	定制自动化任务，编排剧本工具
  - /usr/bin/ansible-pull	远程执行命令的工具
  - /usr/bin/ansible-vault	文件加密工具
  - /usr/bin/ansible-console	基于Console界面与用户交互的执行工具
  - /usr/bin/ansible-galaxy	下载/上传优秀代码或Roles模块的官网平台

+ 配置文件
  
  - /etc/ansible/ansible.cfg        主配置文件，配置ansible工作特性
  - /etc/ansible/hosts      主机清单
  - /etc/ansible/roles/     存放角色的目录

+ 配置说明  
  /etc/ansible/ansible.cfg

``` 
  [defaults]
   #inventory = /etc/ansible/hosts # 主机列表配置文件
   #library = /usr/share/my_modules/ # 库文件存放目录
   #remote_tmp = $HOME/.ansible/tmp #临时py命令文件存放在远程主机目录
   #local_tmp = $HOME/.ansible/tmp # 本机的临时命令执行目录
   #forks = 5 # 默认并发数
   #sudo_user = root # 默认sudo 用户
   #ask_sudo_pass = True #每次执行ansible命令是否询问ssh密码
   #ask_pass = True      #连接时提示输入ssh密码
   #remote_port = 22     #远程主机的默认端口，生产中这个端口应该会不同
   #log_path = /var/log/ansible.log #日志
   #host_key_checking = False # 检查对应服务器的host_key，建议取消注释。也就是不会弹出
  
```

+ Inventory 主机清单  
Ansible必须通过Inventory 来管理主机。Ansible 可同时操作属于一个组的多台主机,组和主机之间的关系通过 inventory 文件配置。 

##### 句法格式

```
单台主机
green.example.com    >   FQDN
192.168.100.10       >   IP地址
192.168.100.11:2222  >   非标准SSH端口

[webservers]         >   定义了一个组名     
alpha.example.org    >   组内的单台主机
192.168.100.10 

[dbservers]
192.168.100.10       >   一台主机可以是不同的组，这台主机同时属于[webservers] 

[group:children]     >  组嵌套组，group为自定义的组名，children是关键字，固定语法，必须填写。
dns                  >  group组内包含的其他组名
db                   >  group组内包含的其他组名

[webservers] 
www[001:003].hunk.tech > 有规律的名称列表，
这里表示相当于：
www001.hunk.tech
www002.hunk.tech
www003.hunk.tech

[databases]
db-[a:c].example.com   >   定义字母范围的简写模式,
这里表示相当于：
db-a.example.com
db-b.example.com
db-c.example.com

最后还有一个隐藏的分组，那就是all，代表全部主机,这个是隐式的，不需要写出来的
``` 
 
##### 参数说明 

```
ansible_ssh_host
      将要连接的远程主机名.与你想要设定的主机的别名不同的话,可通过此变量设置.

ansible_ssh_port
      ssh端口号.如果不是默认的端口号,通过此变量设置.这种可以使用 ip:端口 192.168.1.100:2222

ansible_ssh_user
      默认的 ssh 用户名

ansible_ssh_pass
      ssh 密码(这种方式并不安全,我们强烈建议使用 --ask-pass 或 SSH 密钥)

ansible_sudo_pass
      sudo 密码(这种方式并不安全,我们强烈建议使用 --ask-sudo-pass)

ansible_sudo_exe (new in version 1.8)
      sudo 命令路径(适用于1.8及以上版本)

ansible_connection
      与主机的连接类型.比如:local, ssh 或者 paramiko. 

ansible_ssh_private_key_file
      ssh 使用的私钥文件.适用于有多个密钥,而你不想使用 SSH 代理的情况.

ansible_shell_type
      目标系统的shell类型.默认情况下,命令的执行使用 'sh' 语法,可设置为 'csh' 或 'fish'.

ansible_python_interpreter
      目标主机的 python 路径
```

+ Ansible 的命令执行过程

```
1. 加载自己的配置文件，默认/etc/ansible/ansible.cfg
    Using /etc/ansible/ansible.cfg as config file

2. 匹配主机清单
    Parsed /etc/ansible/hosts inventory source with ini plugin

3. 加载指令对应的模块文件，如command，生成.py的文件到本机的临时目录，这个目录就是在/etc/ansible/ansible.cfg定义的
    Using module file /usr/lib/python2.7/site-packages/ansible/modules/commands/command.py
    PUT /tmp/tmp4JvsLH TO /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/command.py

4. 通过ansible将模块或命令生成对应的临时py文件，并将该文件传输至远程服务器的对应执行用户$HOME/.ansible/tmp/ansible-tmp-数字/XXX.PY文件，
    这个目录就是在/etc/ansible/ansible.cfg定义的
    ( umask 77 && mkdir -p "` echo /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861 `" ....)
    sftp> put /tmp/tmp4JvsLH /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/command.py\n'

5. 给文件+x 权限
    'chmod u+x /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/ /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/command.py && sleep 0'

6. 执行并返回结果
    '/usr/bin/python /root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/command.py;

7. 删除临时py文件，sleep 0退出
    rm -rf "/root/.ansible/tmp/ansible-tmp-1517301292.6-155771303493861/" > /dev/null 2>&1 && sleep 0

8. 断开远程主机连接
    'Shared connection to 7-db-3.hunk.tech closed.\r\n')

```

+ 执行结果状态  
绿色：执行成功并且不需要做改变的操作  
×××：执行成功并且对目标主机做变更  
红色：执行失败 


