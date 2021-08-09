---
title: "Redis 应用场景"
date: 2021-03-09T17:23:59+08:00
draft: false
toc: false
categories: ["redis"]
---

## 应用场景

作为一名匠人，当熟悉手里各样工具的特点。用起来才能得心应手。什么时候使用锯子，什么时候当用斧子。

同理熟知产品的技术特性，方可灵活运用。

在面对不同的业务需求时才能提供具有针对性的解决方案。

不求十八般兵器样样精通，但求不置斧锯于一旁只顾轮打锤。

## Redis 都能干点啥

- 缓存
- 消息队列
- 循环列表
- 排行榜
- 计数器
- SET 集合操作
- 分布式锁
- 跳表

## 基于 bitmap 统计

- 用户在线状态  key 'online_users' ,value uidoffset
- 日活          key date , value uidoffset
- 签到          key userid, value dateoffset
- 访问量 UV       key topicid ,value uidoffset 
- 布隆过滤器    
- 用户标签      key userid ,value  

BITOP 命令支持 AND 、 OR 、 NOT 、 XOR  对多个bitmap数据进行逻辑操作

## 基于 HyperLogLog 统计

集合基数估计 

- 访问量 UV 

常用指令： pfadd , pfcount , pfmerge

## 布隆过滤

确定一个元素是否在集合中。 存在一定误差，判断存在集合中可能存在。判断不存在集合中则一定不存在。

- 缓存穿透。 如果数据不在则直接返回。不再查询数据库。
- 推荐过滤。 避免重复推荐
- 爬虫重复连接过滤

在NOSQL 中应用非常广泛，hbase，leveldb，rocksdb 内部都有布隆过滤器结构。

常用指令： bf.add bf.exits 

初始化： bf.reserve 显示创建 三个参数 key、 error_rate (错误率) 越低需要空间越大 默认0.01、initial_size 预计放入的元素数量 默认100。

在线空间计算器 http://krisives.github.io/bloom-calculator/

## 限流

用户的某个行为在规定的时间内发生的次数进行限制

如：五分钟内回复帖子的数量不能大于10条

- ZSET 实现简单限流

key ,userid+action ,value ts, score ts

- redis-cell 漏洞限流模块


## 基于 GEO 地理位置

GeoHash 算法，经纬度使用52位的整数进行编码，放进zset里面。zset的value是元素的key. score 是geohash 的52位整数值。

- 附近的xxx
- 两点之间的距离
 
常用指令： 

增加 geoadd、计算两点距离 deodis、 获取元素位置geopos 、 获取元素hash 值 geohash、 附近的元素 georadiusbymember 、根据坐标后去附近的元素 georadius 

底层为zset存储结构。删除可使用zrem

注意事项，当个key过的的情况。 对key值进行划分。比如可按城市，区划分等。

 
