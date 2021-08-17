---
title: "Postgres 10 监控指标"
date: 2019-09-27T15:13:27+08:00
draft: false
---

#### 实体机

- Cpu
- 内存
- IO
- 网络
- 磁盘大小

#### 数据库基本信息

###### 服务启动时间
```
select pg_postmaster_start_time();
```

###### 版本信息
```
select current_setting('server_version');
```

###### 主从角色
```
select pg_is_in_recovery();
```


