---
title: "Ansible Playbooks"
date: 2018-10-25T15:47:50+08:00
draft: false
---
#### Playbook核心元素

##### hosts 
一个或多个组或主机的 patterns,以逗号为分隔符 。 
```
- hosts: webservices
  remote_user: root
```
##### Tasks  
任务集 
```
 tasks:
    - name: install httpd
      yum: name=httpd

    - name: start httpd
      service: name=httpd state=started
```
##### Handlers 和 notity 
由特定条件触发的操作，满足条件方才执行，否则不执行。
Handlers也是task列表，这些task与前述的task并没有本质上的不同,用于当关注的资源发生变化时，才会采取一定的操作。

```
- hosts: webs
  remote_user: root

  tasks:
    - name: install httpd
      yum: name=httpd

    - name: change httpd.conf
      copy: src=/app/httpd.conf dest=/etc/httpd/conf/ backup=yes
      notify: restart httpd             > 在 notify 中定义内容一定要和handlers中定义的 - name 内容一样，这样才能达到触发的效果，否则会不生效。
    - name: start httpd
      service: name=httpd state=started

    - name: wall http status
      shell: /usr/bin/wall `ss -nltp|grep httpd`

  handlers:
    - name: restart httpd           > 只有接收到通知才会执行这里的任务
      service: name=httpd state=restarted
```

##### Tags 
给指定的任务定义一个调用标识 
由于ansible具有幂等性，因此会自动跳过没有变化的部分，即便如此，有些代码为测试其确实没有发生变化的时间依然会非常地长。此时，如果确信其没有变化，就可以通过
tags跳过此些代码片断。

```
- hosts: webs
  remote_user: root

  tasks:
    - name: install httpd
      yum: name=httpd
      tags: install

ansible-playbook -t install web.yaml
```

##### Variables 变量

- 通过命令行指定变量，优先级最高。
```
ansible-playbook – variable_name=value
```

- facts setup模块就是用来获取远程主机的相关信息的。一般以ansible_ 开头的就是变量可以调用。

- /etc/ansible/hosts  inventory

```
   每台主机单独设置
   IP/HOSTNAME variable_name=value
    
   组内统一设置
   [groupname:vars]
     variable_name=value

   还可以使用参数, 用于定义ansible远程连接目标主机时使用的属性，而非传递给playbook的变量。
   ansible_ssh_host
   ansible_ssh_port
   ansible_ssh_user
   ansible_ssh_pass
   ansible_sudo_pass

```
- 在playbook中定义 

```
   vars:
    - var_name: value
    - var_name: value

```
- register 在有些时候，我们希望把某一条任务执行的结果保存下来，可以在接下的任务中调用或者做些判断，可以通过register关键字来实现。



-  角色调用

- vars_files指定变量文件

###### 优先级 命令行 -e > vars_files指定变量文件 > 主机清单普通变量 > 主机清单公共(组)变量  
<br/>
##### 运行

- 语法检测

```
ansible-playbook  --syntax-check  /path/to/playbook.yaml
```

- 测试运行

  - --list-hosts
  - -list-tasks
  - --list-tags

```
 ansible-playbook -C /path/to/playbook.yaml 
```

- 执行运行

  - -t TAGS, --tags=TAGS
  - --skip-tags=SKIP_TAGS
  - --start-at-task=START_AT

```
ansible-playbook  /path/to/playbook.yaml
```

##### 变量示例

```
cat hosts 
[webservers]
10.1.88.72 name=iam72
10.1.88.73 name=iam73

[webservers:vars]
place="host_vars.txt"

cat vars.yaml 
- hosts: all 
  vars:
     filename: "abcd.txt"
  vars_files:
    - vars/test_vars.yml
  tasks:
   - name: test playbook vars
     file: path="/tmp/{{ filename }}" state=touch
     tags: playbook_vars
   
   - name: test setup vars 
     copy: dest=/tmp/a.txt content="{{ ansible_all_ipv4_addresses }}" 
     tags: setup_vars 

   - name: test hosts vars
     copy: dest="/tmp/{{ place }}" content="{{ name }}"
     tags: hosts_vars

   - name: test var files
     file: path="/tmp/{{ var_file }}" state=touch
     tags: file_var 

   - name: test register var
     shell: /bin/cat /etc/centos-release
     ignore_errors: true
     register: release
     tags: register_var

   - name: show release 
     debug: var=release
```

```
ansible-playbook vars.yaml --list-tags

playbook: vars.yaml

  play #1 (all): all	TAGS: []
      TASK TAGS: [file_var, hosts_vars, playbook_vars, register_var, setup_vars]

```

```
ansible-playbook vars.yaml --list-tasks

playbook: vars.yaml

  play #1 (all): all	TAGS: []
    tasks:
      test playbook vars	TAGS: [playbook_vars]
      test setup vars	TAGS: [setup_vars]
      test hosts vars	TAGS: [hosts_vars]
      test var files	TAGS: [file_var]
      test register var	TAGS: [register_var]
      show release	TAGS: []
```

```
ansible-playbook vars.yaml --list-hosts

playbook: vars.yaml

  play #1 (all): all	TAGS: []
    pattern: [u'all']
    hosts (2):
      10.1.88.73
      10.1.88.72
```

```
ansible-playbook vars.yaml 

PLAY [all] ********************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************
ok: [10.1.88.72]
ok: [10.1.88.73]

TASK [test playbook vars] ****************************************************************************************************************
changed: [10.1.88.73]
changed: [10.1.88.72]

TASK [test setup vars] ******************************************************************************************************************
changed: [10.1.88.73]
changed: [10.1.88.72]

TASK [test hosts vars] *********************************************************************************************************************
changed: [10.1.88.73]
changed: [10.1.88.72]

TASK [test var files] **********************************************************************************************************************
changed: [10.1.88.72]
changed: [10.1.88.73]

TASK [test register var] ********************************************************************************************************************
changed: [10.1.88.73]
changed: [10.1.88.72]

TASK [show release] **************************************************************************************************************************
ok: [10.1.88.72] => {
    "release": {
        "changed": true, 
        "cmd": "/bin/cat /etc/centos-release", 
        "delta": "0:00:00.027839", 
        "end": "2018-10-26 13:15:35.752900", 
        "failed": false, 
        "rc": 0, 
        "start": "2018-10-26 13:15:35.725061", 
        "stderr": "", 
        "stderr_lines": [], 
        "stdout": "CentOS Linux release 7.5.1804 (Core) ", 
        "stdout_lines": [
            "CentOS Linux release 7.5.1804 (Core) "
        ]
    }
}
ok: [10.1.88.73] => {
    "release": {
        "changed": true, 
        "cmd": "/bin/cat /etc/centos-release", 
        "delta": "0:00:00.035317", 
        "end": "2018-10-26 13:15:35.746466", 
        "failed": false, 
        "rc": 0, 
        "start": "2018-10-26 13:15:35.711149", 
        "stderr": "", 
        "stderr_lines": [], 
        "stdout": "CentOS Linux release 7.5.1804 (Core) ", 
        "stdout_lines": [
            "CentOS Linux release 7.5.1804 (Core) "
        ]
    }
}

PLAY RECAP **********************************************************************************************************************************
10.1.88.72                 : ok=7    changed=5    unreachable=0    failed=0   
10.1.88.73                 : ok=7    changed=5    unreachable=0    failed=0

```

##### when 条件判断

举例判断当前主机是Centos 6 Or Centos 7

1.利用setup 模块获取系统信息

ansible all -m setup | less

```
"ansible_distribution": "CentOS", 
"ansible_distribution_major_version": "7", 
```

2.利用上面的信息作为判断条件

```
- hosts: all
  tasks:
  - name: centos 6 task
    shell: echo "i am centeos 6"
    when: ansible_distribution == "CentOS" and ansible_distribution_major_version == "6"
  - name: centos 7 task
    shell: echo "i am centeos 7"
    when: ansible_distribution == "CentOS" and ansible_distribution_major_version == "7"

```

##### with_items 重复执行

```
- hosts: all
  tasks:
  - name: install base packages # 一次安装多个安装包
    yum: name={{ item }}  state=installed
    with_items:
      - vim
      - git
      - wget
      - psmisc 
      - net-tools
      - bash-completion 
  - name: create groups # 字典
    group: name={{ item }} state=present
    with_items:
      - group1
      - group2 
  - name: create users
    user: name={{ item.user }} group={{ item.group }} state=present
    with_items:
      - {user: 'user1' , group: 'group1'}
      - {user: 'user2' , group: 'group2'}

```

##### templates 模板，文本文件，内部嵌套有模板语言脚本（使用Jinja2模板语言编写）

- 算数运算

.j2
```
server {
   worker_connectios {{ ansible_processor_vcpus *2 }};
}
```

.yaml
```
- hosts: nginx
  tasks:
    - name: generate nginx conf
      template: src=templates/nginx.conf.j2 dest=/etc/nginx/nginx.conf
```

- for 循环


.j2
```
server { 
{% for port in port_list %}
   listen port;
{% endfor %}
}

```

.yaml
```
- hosts: nginx 
  vars:
    - port_list:
      - 443
      - 80
      - 8080
  tasks:
  - name:
    template: src=templates/nginx.conf.j2 dest=/etc/nginx/nginx.conf

```
.j2

```
{% for vhost in vhost_list %}
server { 
   listen vhost.port;
   servername vhost.host;
}
{% endfor %}
```
.yaml
```
- hosts: nginx
  vars: 
    vhost_list:
     - web:
       port: 8080
       host: web1
     - web:
       port: 9090
       host: web2
```

- if 判断

.j2

```
{% for vhost in vhost_list %}
server { 
   listen vhost.port;
{% if vhost.host is defined%}
   servername vhost.host;
{% endif %}
}
{% endfor %}
```

.yaml 
  
```
- hosts: nginx
  vars: 
    vhost_list:
     - web:
       port: 8080
       host: web1
     - web:
       port: 9090
```
