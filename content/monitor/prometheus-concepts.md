---
title: "Promethues 基本概念"
date: 2018-11-21T14:08:54+08:00
draft: false
---

#### 数据模型(Data Model)

由指标名称(metric)和一个或一组标签(lable)集合以及float64类型的值组成。

例如

```
up{instance="10.1.88.71:9115",job="blackbox_exporter_10.1.88.74_icmp"}	1

```
#### metric类型

client libraries提供了四种metric类型，包括Counter、Gauge、Histogram、Summary。

##### Counter
计数器，只允许增加或重置为0，不允许减少，比如服务的请求数。Counter支持用rate()函数计算平均值，比如QPS。建议使用 _total 作为后缀命名。

##### Gauge
非固定的值，比如CPU负载 、内存使用量。

其变化取决于server是否采集了数据，衡量的是一个事物的状态变化，比如内存使用量，内存始终是那个内存，只是其使用量会发生变化。

##### Histogram

采样观测值，可进行分位计算和数据聚合，计算在<b>server</b>端完成。

一个名为<basename>的metric，其histogram有3个固定的时间序列

```
<basename>_bucket 不同bucket下的观测值的累加数量
<basename>_sum 观测值的总和
<basename>_count 观测值的数量
```

##### Summary

采样观测值，与histogram不同的是，数量/总和/分位的计算在<b>client</b>端完成，计算结果存在server。因为没有最初的metric数据，所以summary不支持数据聚合。

一个名为<basename>的metric，其summary有3个固定的时间序列

```
<basename>{quantile="<φ>"}
<basename>_sum 观测值的总和
<basename>_count 观测值的数量
```

#### Job 和 Instance

instance是指收集数据的目标端点，一般对应于一个进程；而job表示实现同一功能或目标的一组instance。

Prometheus采集到数据后自动为其附加job和instance标签，其中job由Prometheus配置文件定义，instance是目标数据源的地址<host>:<port>。

#### 特点
- 多维数据模型，时间序列由metric名字和K/V标签标识 
- 灵活的查询语言(PromQL)  
- 单机模式，不依赖分布式存储 
- 基于HTTP采用pull方式收集数据 
- 支持push数据到中间件(pushgateway) 
- 通过服务发现或静态配置发现目标 
- 多种图表和仪表盘 

####  组件

Prometheus生态系统由多个组件构成，其中多是可选的，根据具体情况选择

- Prometheus server - 收集和存储时间序列数据
- client library - 用于client访问server/pushgateway
- pushgateway - 对于短暂运行的任务，负责接收和缓存时间序列数据，同时也是一个数据源
- exporter - 各种专用exporter，面向硬件、存储、数据库、HTTP服务等
- alertmanager - 处理报警
- 其他各种支持的工具

###### 各组件之间的通信

1, prometheus与客户端主要采取pull方式获取数据

exporter　通过http暴露自己的数据，prometheus服务主要采用pull的方式到exporter中拉取数据。

同样prometheus也提供http来暴露自己的数据提供其他prometheus来pull。

还有一种是node端将数据push到pushgateway中 ,prometheus 到pushgateway中来pull数据。

2, prometheus与alertmanger

在prometheus的配置中指定报警服务altermanager,同时在prometheus中制定rules触发报警的规则。
altertmanger中定义配置各种报警机制,如email, stack等

#### 架构

![](images/prometheus_architecture.png)




#### 配置

- 抓取时间设置 https://www.robustperception.io/keep-it-simple-scrape_interval-id
