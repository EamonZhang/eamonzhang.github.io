---
title: "virtualenv 管理 python 环境"
date: 2021-04-14T09:11:30+08:00
draft: false
toc: false
categories: ["python"]
tags: []
---

##  virtualenv 管理python 环境

virualenv
virtualenv用于创建独立的Python环境，多个Python相互独立，互不影响，它能够：
1. 在没有权限的情况下安装新套件
2. 不同应用可以使用不同的套件版本
3. 套件升级不影响其他应用

## 安装
```
# ubuntu
sudo apt-get install python-virtualenv

# centos
sudo yum install python-virtualenv
```

## 使用方法
virtualenv [虚拟环境名称]
如，创建**ENV**的虚拟环境
```
virtualenv ENV
```
默认情况下，虚拟环境会依赖系统环境中的site packages，就是说系统中已经安装好的第三方package也会安装在虚拟环境中，如果不想依赖这些package，那么可以加上参数 --no-site-packages建立虚拟环境

virtualenv --no-site-packages [虚拟环境名称]


## 启动虚拟环境
```
cd ENV
source ./bin/activate
```
注意此时命令行会多一个(ENV)，ENV为虚拟环境名称，接下来所有模块都只会安装到该目录中去。

## 退出虚拟环境
```
deactivate
```


## 在虚拟环境安装Python套件

Virtualenv 附带有pip安装工具，因此需要安装的套件可以直接运行：
```
pip install [套件名称]
```

如果没有启动虚拟环境，系统也安装了pip工具，那么套件将被安装在系统环境中，为了避免发生此事，可以在~/.bashrc文件中加上：
```
export PIP_REQUIRE_VIRTUALENV=true
```
或者让在执行pip的时候让系统自动开启虚拟环境：
```
export PIP_RESPECT_VIRTUALENV=true
```

##  Virtualenvwrapper

Virtaulenvwrapper是virtualenv的扩展包，用于更方便管理虚拟环境，它可以做：

1. 将所有虚拟环境整合在一个目录下
2. 管理（新增，删除，复制）虚拟环境
3. 切换虚拟环境
4. ...


