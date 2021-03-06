---
title: "数据库优化思考-性能优化"
date: 2021-02-26T13:33:23+08:00
draft: false
categories: ["postgres"]
tags: ["优化"]
toc: true
---

## 为什么要优化

首先了解一个概念，什么是·熵增·

物理定义：熵增过程是一个自发的由有序向无序发展的过程(Bortz, 1986; Roth, 1993)

在一个孤立的系统里，如果没有外力做工，其总混乱度（即熵）会不断增大，直至系统彻底变得无序

从系统软件的角度： 从应用系统上线那一刻开始，随着用户量的增加、业务功能的持续迭代，系统会面临各种不同程度的挑战，如果不及时采取优化措施，我们会发现诸多问题

比如：系统怎么越来越慢了，流量一高系统就卡顿、甚至宕机等等。

可以说，性能优化是贯穿在整个软件生命周期之中的

## 通常有哪些优化方法

- [结构优化](/postgres/thinking_in_db_fd/)
- [性能优化](/postgres/thinking_in_db_performance/)
- [模块优化](/postgres/thinking_in_db_tune/)

在算法领域，评价一个算法的效率如何，主要会看它的时间复杂度和空间复杂度情况。

引用在数据库的优化中，

时间复杂度： 着重考量的是时间成本，效率。 通常理解成性能优化，如何让我的访问更快

空间复杂度： 着重考量的是资源成本。可对应结构优化，如果组织数据的存放。
 

那么，在做优化时，本质上也是从“优化时间”、“优化空间”、“时空互换（用时间换空间或用空间换时间）”三个方向去思考，然后在空间、时间上不停地做取舍。

## 优化衡量指标

系统优化的目标提高系统的吞吐量：单位时间内能够处理的请求数量

举个例子。把系统比作一个银行营业网点。 有多个窗口对外提供服务。 如何能够提高整体的处理量呢？

- 空间 增加营业窗口  

- 时间 提高每个窗口的效率

关于空间的优化参见[数据库优化思考 - 结构设计](postgres/thinking_in_db_fd/), 本篇更多思考的是性能（时间）的优化。

## 性能优化的衡量指标

 响应时间(RT), 包括

- 平均响应时间(AVG)

接口的平均处理能力， 但什么东西一平均很多就被平均了，如人均收入！😓。 不能很好反应真实情况。另一种类似中位数的指标。

- 百分位数(Top Percentile) 

一种统计学术语，反映的是超过n%的请求都在m时间内返回，一般用TPn=m来描述，比如：TP99=5，表示超过99%的请求都能在5ms内返回。

## 优化如何具体做

开发端： 

- 实现方法
条条大路通罗马，实现的功能是否只满足业务功能的需求，而没有考虑性能。

- 索引
索引用的好，性能没烦恼。大部分应用端的性能问题都可以通过索引来改善。

索引本身也是一种空间换时间的手段。索引本身也是需要额外的代价。

- 锁等待
最漫长的莫过于等待。

运维端： 

通过性能指标监控验证优化成果，如

- TPS
- 慢sql
- 缓存命中率
- 频繁sql- top10
- 不稳定sql - top10
- 索引利用率
- TPn

DBA： 

通过执行计划对具体sql进行调优
