---
title: "依赖管理工具go module"
date: 2020-04-30T13:25:38+08:00
draft: false
---

#### 背景

大多数语言都会有包管理工具，像Node有npm，PHP有composer，Java有Maven和Gradle。

在go1.11 版本中，新增了module管理模块功能，用来管理依赖包

#### 开启module特性

要开始使用 go module 的特性， 需要先设置 GO111MODULE 环境变量。

开启 GO111MODULE

要使用go module,首先要设置GO111MODULE=on

这是因为，默认设置的GO111MODULE=auto, 导致 modules 默认在 GOPATH/src 路径下是不启用的。

如果需要在 GOPATH/src 也能使用modules, 需要把 GO111MODULE 环境变量设置为 on.

```
export GO111MODULE=on
```

###### Goland 中可独立配置，GOPATH GOMOD

#### 使用module

```
Usage:

	go mod <command> [arguments]

The commands are:

	download    download modules to local cache
	edit        edit go.mod from tools or scripts
	graph       print module requirement graph
	init        initialize new module in current directory
	tidy        add missing and remove unused modules
	vendor      make vendored copy of dependencies
	verify      verify dependencies have expected content
	why         explain why packages or modules are needed

Use "go help mod <command>" for more information about a command.
```

经常使用 

```
go mod init 
```
生成 go.mod 文件 例如

```
require (
	github.com/Tang-RoseChild/mahonia v0.0.0-20131226213531-0eef680515cc
	github.com/Unknwon/com v0.0.0-20190321035513-0fed4efef755 // indirect
	github.com/cihub/seelog v0.0.0-20170130134532-f561c5e57575
)
```

```
go tidy 
```
添加需要的删除无用的


