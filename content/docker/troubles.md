---
title: "Docker 问题集"
date: 2019-01-03T15:06:43+08:00
draft: false
---

- Docker push: Received unexpected HTTP status: 500 Internal Server Error

描述: 使用jenkins 构建docker images时 push images到私有harbor中报错: Received unexpected HTTP status: 500 Internal Server Error,在build机上直接push没有问题。有的项目可以成功，有的失败。即使同一个项目有时执行成功，有时也会失败。

解决方式: 网上很多的关于500的错误，大都是关闭selinux来解决。但是情况与这个不同。现在的问题时在jenkins中执行有问题，直接裸机执行没有问题。

看到这篇[文章](https://www.jfrog.com/jira/browse/RTFACT-9025 )， 怀疑时在push images 过大时需要的系统内存不足导致。 

调整jenkins启动时java的内存参数 

```
JAVA_OPTS="-Djava.util.logging.config.file=/var/jenkins_home/log.properties -Duser.timezone=Asia/Shanghai  -Xms4096m -Xmx4096m 
```

问题过几天后有出现

```
/var/log/message 
kernel crash after "unregister_netdevice: waiting for lo to become free. Usage count = 
```

换台build机 , nginx 配置

问题解决

- Docker rpc error: code = 14 desc = grpc: the connection is unavailable

尝试关闭容器，进入容器操作界面也报相同错误：
```
docker exec -it 7119f8f5feef /bin/bash
rpc error: code = 14 desc = grpc: the connection is unavailable
```
停止容器依旧提示错误
```
docker stop 7119f8f5feef
Error response from daemon: Cannot stop container 7119f8f5feef: Cannot kill container 7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327: rpc error: code = 14 desc = grpc: the connection is unavailable
```
删除容器依旧提示错误（-f强制删除）
```
docker rm -f 7119f8f5feef
Error response from daemon: Could not kill running container 7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327, cannot remove - Cannot kill container 7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327: rpc error: code = 14 desc = grpc: the connection is unavailable
```

解决办法：
使用docker-containerd命令以debug模式调试容器
注意：那个node上的容器不能删除就在那台node上面执行以下命令

```
docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc --debug
WARN[0000] containerd: low RLIMIT_NOFILE changing to max  current=1024 max=4096
DEBU[0000] containerd: read past events                  count=1
 low RLIMIT_NOFILE changing to max  current=1024 max=4096DEBU[0000] containerd: grpc api on /var/run/docker/libcontainerd/docker-containerd.sock 
DEBU[0000] containerd: container restored                id=354af53914e3f76e653a26d9e9da8d4fbef4ef18cc2176371b89871a9126a646
DEBU[0000] containerd: container restored                id=3f0bf43f7ca97c439b64370cee09205b35e58ed35e49f957412f58affbe4ed4b
DEBU[0000] containerd: container restored                id=4b848d33a32a332635929b95eb7291abeb32f177a3c65248568b959dbfbc2712
DEBU[0000] containerd: container restored                id=4ed8d1f971a0ea5035b507511d802a1445af9e771cde670814104102a7cc2d6f
ERRO[0000] containerd: notify OOM events                 error=open /proc/13541/cgroup: no such file or directory
DEBU[0000] containerd: container restored                id=7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327
ERRO[0000] containerd: notify OOM events                 error=open /proc/12860/cgroup: no such file or directory
DEBU[0000] containerd: container restored                id=7bdba0a1ee81997bdbb5958e31123538ac8a6730c6cc7120fe7359439b52b410
DEBU[0000] containerd: container restored                id=8ba79a79836b4350335375f89fc1473a6a86593375fbac6344fb17e4dddff43f
DEBU[0000] containerd: container restored                id=9692f3570460186de681476bd068d008891b24b3906f190443f24e97343c3e57
DEBU[0000] containerd: supervisor running                cpus=1 memory=977 runtime=docker-runc runtimeArgs=[] stateDir=/var/run/docker/libcontainerd/containerd
DEBU[0000] containerd: process exited                    id=7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327 pid=init status=143 systemPid=13541
ERRO[0000] containerd: deleting container                error=exit status 1: "container 7119f8f5feef4c649d9ec04734e6224e2d837fa030de271f269f0b71eea29327 does not exist\none or more of the container deletions failed\n"
DEBU[0000] containerd: process exited                    id=7bdba0a1ee81997bdbb5958e31123538ac8a6730c6cc7120fe7359439b52b410 pid=init status=137 systemPid=12860
ERRO[0000] containerd: deleting contain

```
