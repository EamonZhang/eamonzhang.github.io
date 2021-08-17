---
title: "Go 语言安装及配置"
date: 2018-10-23T14:10:27+08:00
draft: false
---

1.下载安装包

 https://golang.org/dl/  
 https://golang.google.cn/dl/

 将下载的二进制包解压至 /usr/local目录

2.配置环境变量

cat /etc/profile.d/go.sh 
```
export GOROOT=/usr/local/go
export GOPATH=~/golib:~/goproject
export GOBIN=~/gobin
export PATH=$PATH:$GOROOT/bin:$GOBIN
export GOPROXY=https://goproxy.cn
export GO111MODULE=on
```

说明: 

GOROOT go安装包存放位置  
GOPATH 工作区，多个工作区之间用冒号间隔  
GOBIN  可执行文件目录  
PATH   系统环境变量  
Goproxy 中国完全实现了 Go 的模块代理协议。并且它是一个由中国备受信赖的云服务提供商七牛云支持的非营利性项目。目标是为中国和世界上其他地方的 Gopher 们提供一个免费的、可靠的、持续在线的且经过 CDN 加速的模块代理。

3.目录结构

 src 源码  
 pkg 归档文件 .a 后缀  

4.常用命令及参数

go run  执行 

   -a -n - p -w

go build 

go install 编译并安装指定的代码包及它们的依赖包 　

go get 下载远程代码到GOPATH第一个工作区中，并编译执行

go clean 

go doc 

go list 

go fmt 

go fix 


4.墙内生存技能

```
export GOPROXY=https://goproxy.io
```
基本就都可以下载了

 

第三方库

google 被墙了，很多相关的库都 go get 不下来。可以用下面的方法曲线下载

cloud.google.com/go/pubsub

对应的github仓库在这里   https://github.com/googleapis/google-cloud-go

```
mkdir -p $GOPATH/src/cloud.google.com                                                                               
cd $GOPATH/src/cloud.google.com  
git clone https://github.com/googleapis/google-cloud-go.git                                                         
mv google-cloud-go go
```

google.golang.org/api/iterator

googleapis go 语言版本在这 https://github.com/googleapis/google-api-go-client

```

mkdir -p $GOPATH/src/google.golang.org 
cd $GOPATH/src/google.golang.org
git clone https://github.com/googleapis/google-api-go-client.git                                                  
mv google-api-go-client/ api   
```

golang.org/x/sync/errgroup
golang.org/x/oauth2

golang.org 的基本都在  https://github.com/golang， 到里面找同名的仓库

详细参考如下 

```
cd $GOPATH/src/golang.org/x/
git clone https://github.com/golang/sync.git
git clone https://github.com/golang/oauth2.git
git clone https://github.com/golang/crypto.git
git clone https://github.com/golang/net.git
git clone https://github.com/golang/oauth2.git
git clone https://github.com/golang/sync.git
git clone https://github.com/golang/sys.git
git clone https://github.com/golang/text.git
git clone https://github.com/golang/time.git
git clone https://github.com/golang/xerrors.git
```

grpc安装

```
mkdir -p $GOPATH/src/google.golang.org/
cd $GOPATH/src/google.golang.org/
git clone https://github.com/grpc/grpc-go.git
mv grpc-go grpc
```

genproto安装

```
cd $GOPATH/src/google.golang.org
git clone https://github.com/google/go-genproto.git
mv go-genproto/ genproto
```

##### IDE　goland 安装

##### 包管理器

glide

go mod

##### 自动编译

gin

##### 类库

日志　zap https://github.com/uber-go/zap

命令行　cli https://github.com/urfave/cli

配置文件　https://github.com/jinzhu/configor

##### 框架

###### web

- beego
- [macaron](https://go-macaron.com/)

###### orm

- gorm
- xorm

###### 配置管理

- viper
