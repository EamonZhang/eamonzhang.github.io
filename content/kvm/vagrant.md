---
title: "vagrant"
date: 2020-07-13T09:32:49+08:00
draft: false
---

## 介绍

通常用vagrant 来管理VirtualBox ,VMWare，方便测试环境的创建，销毁。不常折腾用virtualbox, 反复折腾用vagrant。

## 安装

[下载virtualbox](https://www.virtualbox.org/wiki/Downloads)

[下载vagrant](https://www.vagrantup.com/downloads.html)

```
-- 安装依赖
#yum --enablerepo=epel -y install fuse-sshfs
#yum install bsdtar
#yum -y install gcc kernel kernel-devel
```

## 常用方法

```
--- 镜像管理
添加镜像
#vagrant box add centos/7

查看镜像
#vagrant box list
centos/7 (virtualbox, 2004.01)

-- 配置管理
初始化默认Vagrantfile
#vagrant init

配置Vagrantfile定义虚拟机 , 启动虚拟机
#vagrant up

查看状态
#vagrant status
Current machine states:

node0                     running (virtualbox)
node1                     running (virtualbox)
node2                     running (virtualbox)
node3                     running (virtualbox)

登录虚拟机
#vagrant ssh node0

关闭
#vagrant halt

停止并销毁
#vagrant destroy 

重新加载,重启
#vagrant reload


```

## 注意事项

```
将当前路径的所有内容同步到虚拟机内
Rsyncing folder: /当前路径 => /vagrant
```

```
基本方法
     box             manages boxes: installation, removal, etc.
     cloud           manages everything related to Vagrant Cloud
     destroy         stops and deletes all traces of the vagrant machine
     halt            stops the vagrant machine
     reload          restarts vagrant machine, loads new Vagrantfile configuration
     resume          resume a suspended vagrant machine
     ssh             connects to machine via SSH
     status          outputs status of the vagrant machine
     up              starts and provisions the vagrant environment 
```

## 配置文件

cat Vagrantfile
```
Vagrant.configure("2") do |config|
    config.vm.box = "centos/7"
    config.vm.box_check_update = false
    config.ssh.insert_key = false
    config.vm.define "node0", primary: true do |s|
        s.vm.hostname = "node0"
        s.vm.network "private_network", ip: "10.10.10.10"
        s.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 2048,
                    "--cpus", "2",
                    "--nictype1", "virtio",
                    "--nictype2", "virtio",
                    "--hwvirtex", "on",
                    "--ioapic", "on",
                    "--rtcuseutc", "on",
                    "--vtxvpid", "on",
                    "--largepages", "on"
                ]
        end
    end

    config.vm.define "node1" do |s|
        s.vm.hostname = "node1"
        s.vm.network "private_network", ip: "10.10.10.11"
        s.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 1024,
                    "--cpus", "1",
                    "--nictype1", "virtio",
                    "--nictype2", "virtio",
                    "--hwvirtex", "on",
                    "--ioapic", "on",
                    "--rtcuseutc", "on",
                    "--vtxvpid", "on",
                    "--largepages", "on"
                ]
        end
    end

    config.vm.define "node2" do |s|
        s.vm.hostname = "node2"
        s.vm.network "private_network", ip: "10.10.10.12"
        s.vm.provider "virtualbox" do |v|
            v.linked_clone = true
            v.customize [
                    "modifyvm", :id,
                    "--memory", 1024,
                    "--cpus", "1",
                    "--nictype1", "virtio",
                    "--nictype2", "virtio",
                    "--hwvirtex", "on",
                    "--ioapic", "on",
                    "--rtcuseutc", "on",
                    "--vtxvpid", "on",
                    "--largepages", "on"
                ]
        end
    end

    config.vm.define "node3" do |s|
       s.vm.hostname = "node3"
       s.vm.network "private_network", ip: "10.10.10.13"
       s.vm.provider "virtualbox" do |v|
           v.linked_clone = true
           v.customize [
                   "modifyvm", :id,
                   "--memory", 1024,
                   "--cpus", "1",
                   "--nictype1", "virtio",
                   "--nictype2", "virtio",
                   "--hwvirtex", "on",
                   "--ioapic", "on",
                   "--rtcuseutc", "on",
                   "--vtxvpid", "on",
                   "--largepages", "on"
                    ]
            end
        end
    config.vm.provision "shell", inline: <<-SHELL
      #yum update -y
    SHELL
end
```
