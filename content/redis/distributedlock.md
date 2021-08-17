---
title: "基于Redis 的分布式锁实现"
date: 2021-08-10T15:05:28+08:00
draft: false
toc: false
categories: ['redis','python']
tags: []
---

## 分布式锁场景

- 秒杀抢购茅台，车票
- 提前预约抢订车位，共享单车

特点，多个用户同一时间对同一个资源进行申请，并且只能允许一个用户申请成功。

## 分布式锁必要条件

- 布式系统环境下，一个方法在同一时间只能被一个机器的一个线程执行；
- 高可用的获取锁与释放锁；
- 高性能的获取锁与释放锁；
- 具备可重入特性；
- 具备锁失效机制，防止死锁；
- 具备非阻塞锁特性，即没有获取到锁将直接返回获取锁失败。


## 单redis实例版实现

局限： 单实例redis，在sentinel主从结构中当主节点failover从节点尚未同步时存在风险。

```
#!/usr/bin/env python
#--*-- coding:utf-8 --*--
"""
  分布式锁demo。类似抢购秒杀等场景。
"""

import redis
import uuid
import time
import threading

redis_pool = redis.ConnectionPool(host="192.168.6.14", port=6379, db=0)
redis_client = redis.Redis(connection_pool=redis_pool)

#获取一个锁
#lock_name：锁定名称
#acquire_time: 客户端等待获取锁的时间
#time_out: 锁的超时时间
def acquire_lock(lock_name,acquire_time=10,time_out=5):

    identifier = str(uuid.uuid4())
    end_time = time.time() + acquire_time
    lock = "string:lock:" + lock_name
    # print(threading.current_thread().name, "开始申请锁...", time.asctime(time.localtime(time.time())))
    while time.time() < end_time:
        # 注意事项：
        # 正确方式， 使用set 方法 nx 具有原子性
        # 错误方式， setnx + expire 组合方法不具备原子性
        if redis_client.set(lock,identifier,ex=time_out,nx=True): # 获取锁成功
            print(threading.current_thread().name, "获得了锁...", time.asctime(time.localtime(time.time())))
            return identifier
        time.sleep(0.1)

    # 在指定时间周期内未获取到锁
    print(threading.current_thread().name, "放弃申请锁.####", time.asctime(time.localtime(time.time())))
    return False

#释放一个锁
def release_lock(lock_name,identifier):
    lock = "string:lock:" + lock_name
    lock_value = redis_client.get(lock)
    if not lock_value : # 锁已经被超时释放
        print(threading.current_thread().name, "超时释放了锁...", time.asctime(time.localtime(time.time())))
        return True
    try:
        pipe = redis_client.pipeline(True)
        pipe.watch(lock)
        if lock_value.decode() == identifier: # 匹配成功 ，将锁释放
            pipe.multi()
            pipe.delete(lock)
            pipe.execute()
            print(threading.current_thread().name, "主动释放了锁...", time.asctime(time.localtime(time.time())))
            return True
    except redis.exceptions.WatchError:
        pass
    finally:
        try:
            pipe.unwatch()
        except redis.exceptions.WatchError:
            pass
    return False

# 秒杀
def seckill():
    identifier = acquire_lock('resource')
    print(threading.current_thread().name , "正在执行任务")
    time.sleep(3)
    release_lock('resource',identifier)

if __name__ == '__main__':
    print("程序开始执行 ： ",time.asctime(time.localtime(time.time())))
    # 模拟30个用户同时抢购
    for i in range(30):
        t = threading.Thread(target=seckill)
        t.start()
        # t.join()
```

## 多实例Redis 实现

 多实例高可用redis版 请参考redlock. 原理，多个独立的redis通过选举机制

 加锁时，发送`set(key,value,nx=True,ex=xxx)` 指令。只要过半节点set成功，就认为加锁成功。释放时向所有节点发送del指令。

 缺点： 运维成本增加，性能下降

示例代码
```
#!/usr/bin/env python
#--*-- coding:utf-8 --*--

import  redlock

addrs = [{
    "host":"host1",
    "port":6379,
    "db":0
    },{
   "host":"host2",
    "port":6379,
    "db":0
    },{
    "host":"host3",
    "port":6379,
    "db":0
}]

dlm = redlock.Redlock(addrs)
# 申请锁
success = dlm.lock("acquire-lock",50)

if success:
    print("申请成功")
    #do something
    dlm.unlock("acquire-lock")
else:
    print("申请锁失败")
```
## Redis 事务补充说明

指令： multi exec discard watch

基本用法

```
watch userkey
multi 
  do something1
  do something2
exec
```
Redis 事务不能保证原子性，即do something1 ,do something2 可以部分执行成功。仅保持了指令的串行化。

WATCH 机制，就是一种乐观锁。在事务开始之前盯住一个或多个关键变量。当事务执行提交前如果关键变量被修改则事务执行失败。
