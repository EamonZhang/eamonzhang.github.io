---
title: "配置管理 confd"
date: 2021-04-02T15:26:49+08:00
draft: false
toc: false
categories: ["中间件"]
tags: ["配置管理"]
---

https://github.com/kelseyhightower/confd

配置信息存放在ectd KV存储中

更新 ectd 中的内容， confd 负责将变更同步到本地服务配置文件，并通知本地服务进行重新加载重启等。
