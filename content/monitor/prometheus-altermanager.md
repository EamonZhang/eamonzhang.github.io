---
title:  "Promethues Altermanager 报警"
date: 2018-11-21T17:29:01+08:00
draft: false
---

#### Prometheus Alertmanager

##### 概述

Alertmanager与Prometheus是相互分离的两个组件。Prometheus服务器根据报警规则将警报发送给Alertmanager，然后Alertmanager将silencing、inhibition、aggregation等消息通过电子邮件、PaperDuty和HipChat发送通知。

设置警报和通知的主要步骤：

- 安装配置Alertmanager

- 配置Prometheus 指定altermanager服务

- 在Prometheus中创建告警规则

#### Alertmanager简介及机制

Alertmanager处理由Prometheus服务器等客户端发来的警报。它负责删除重复数据、分组，并将警报通过路由发送到正确的接收器，比如电子邮件、Slack等。Alertmanager还支持groups,silencing和警报抑制的机制。

##### 分组

分组是指将同一类型的警报分类为单个通知。当许多系统同时宕机时，很有可能成百上千的警报会同时生成，这种机制特别有用。
例如，当数十或数百个服务的实例在运行，网络发生故障时，有可能一半的服务实例不能访问数据库。在prometheus告警规则中配置为每一个服务实例都发送警报的话，那么结果是数百警报被发送至Alertmanager。

但是作为用户只想看到单一的报警页面，同时仍然能够清楚的看到哪些实例受到影响，因此，可以通过配置Alertmanager将警报分组打包，并发送一个相对看起来紧凑的通知。

分组警报、警报时间，以及接收警报的receiver是在alertmanager配置文件中通过路由树配置的。

##### 抑制(Inhibition)

抑制是指当警报发出后，停止重复发送由此警报引发其他错误的警报的机制。(比如网络不可达，导致其他服务连接相关警报)

例如，当整个集群网络不可达，此时警报被触发，可以事先配置Alertmanager忽略由该警报触发而产生的所有其他警报，这可以防止通知数百或数千与此问题不相关的其他警报。

抑制机制也是通过Alertmanager的配置文件来配置。

##### 沉默(Silences)

Silences是一种简单的特定时间不告警的机制。silences警告是通过匹配器(matchers)来配置，就像路由树一样。传入的警报会匹配RE，如果匹配，将不会为此警报发送通知。

这个可视化编辑器可以帮助构建路由树。

silences报警机制可以通过Alertmanager的Web页面进行配置。

#### Alermanager的配置

Alertmanager通过命令行flag和一个配置文件进行配置。命令行flag配置不变的系统参数、配置文件定义的抑制(inhibition)规则、通知路由和通知接收器。

要查看所有可用的命令行flag，运行alertmanager -h。
Alertmanager支持在运行时加载配置，如果新配置语法格式不正确，更改将不会被应用，并记录语法错误。通过向该进程发送SIGHUP或向/-/reload端点发送HTTP POST请求来触发配置热加载。

配置文件
要指定加载的配置文件，需要使用-config.file标志。该文件使用YAML来完成，通过下面的描述来定义。带括号的参数表示是可选的，对于非列表的参数的值，将被设置为指定的缺省值。

ref: https://www.jianshu.com/p/239b145e2acc
