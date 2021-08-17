---
title: "集群部署安装"
date: 2018-12-07T10:48:00+08:00
draft: false
---

#### kubeadm

---
kubeadm 可当做体验版，证书可用时间一年

#### Kubespray
---  
Kubespray 是 Kubernetes incubator 中的项目，目标是提供 Production Ready Kubernetes 部署方案，该项目基础是通过 Ansible Playbook 来定义系统与 Kubernetes 集群部署的任务，具有以下几个特点：

- 可以部署在 AWS, GCE, Azure, OpenStack 以及裸机上.   
- 部署 High Available Kubernetes 集群.  
- 可组合性 (Composable)，可自行选择 Network Plugin (flannel, calico, canal, weave) 来部署.   
- 多种 Linux distributions(CoreOS, Debian Jessie, Ubuntu 16.04, CentOS/RHEL7).   

#### kops

---   
kops 是一个生产级 Kubernetes 集群部署工具，可以在 AWS、GCE、VMWare vSphere 等平台上自动部署高可用的 Kubernetes 集群。主要功能包括

- 自动部署高可用的 kubernetes 集群 
- 支持从 kube-up 创建的集群升级到 kops 版本  
- dry-run 和自动幂等升级等基于状态同步模型 
- 支持自动生成 AWS CloudFormation 和 Terraform 配置  
- 支持自定义扩展 add-ons  
- 命令行自动补全  

#### kubeasz 

---
[kubeasz](https://github.com/gjmzj/kubeasz)使用Ansible脚本安装K8S集群, 可以离线安装　

- 裸机部署在Centos及Ubuntu系统 
- 支持高可用  
- 支持滚动在线升级 
- 网络可选flannel,　calico　等 
- add-ons  
- 本人参与和实践  
