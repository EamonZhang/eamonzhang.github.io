---
title: "Ansible Roles"
date: 2018-10-29T14:09:08+08:00
draft: false
---

以特定的层级目录结构进行组织的tasks、variables、handlers、templates、files等

mkdir -pv ./{os_hard,nginx,memcached}/{files,templates,vars,handlers,meta,default,tasks}/main.yaml

```
tree memcached/
memcached/
├── default 设定默认变量
│   └── main.yaml
├── files 存储由copy或script等模块调用的文件 
│   └── main.yaml
├── handlers 
│   └── main.yaml
├── meta 定义当前角色的特殊设定及其依赖关系
│   └── main.yaml
├── tasks
│   └── main.yaml
├── templates 存储由template模块调用的模板文本
│   └── main.yaml
└── vars
    └── main.yaml
```

#### ansible-galaxy

https://galaxy.ansible.com 网站为他人分享的 roles， 可以下载学习并使用

ansible-galaxy 语法：

ansible-galaxy [delete|import|info|init|install|list|login|remove|search|setup] [--help] [options] 

- 列出已安装的galaxy

```
ansible-galaxy list geerlingguy.redis

```

- 安装galaxy  位置 /root/.ansible/roles/

```
 ansible-galaxy install geerlingguy.redis
- downloading role 'redis', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-redis/archive/1.6.0.tar.gz
- extracting geerlingguy.redis to /root/.ansible/roles/geerlingguy.redis
- geerlingguy.redis (1.6.0) was installed successfully
```

- 删除galaxy

```
ansible-galaxy remove geerlingguy.redis
```

#### Ansible-vault 

管理加密解密yml文件

```
Usage: ansible-vault [create|decrypt|edit|encrypt|encrypt_string|rekey|view] [options] [vaultfile.yml]
```

#### Ansible-console

交互执行命令

```

```
### [官方文档](https://docs.ansible.com/ansible/latest/index.html)

### 实际应用
---

[k8s](https://github.com/gjmzj/kubeasz)  
[TiDB](https://github.com/pingcap/tidb-ansible)   
[小试牛刀](https://github.com/bodani/ansible-moses)
