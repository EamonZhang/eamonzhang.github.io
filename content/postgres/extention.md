---
title: "数据库拓展"
date: 2018-11-27T15:20:33+08:00
draft: false
---

- 流计算数据库产品 pipelineDB *

- 推荐数据库产品 recDB

- 时序数据库 timescaleDB *

- 分布式数据库插件 citus *

- 列存储插件 IMCS, cstore等

- 面向OLAP的codegen数据库 pg_LLVM

- 向量计算插件 vops

- 数据库性能分析 [pg_stat_statements](postgres/pg_stat_statements) pg_buffercache

- 直接访问数据库文件系统 adminpack

- 加密数据 pgcrypto

- 预热缓存 pg_prewarm

- 检查存储，特别是表膨胀 pgstattuple 

- 模糊搜索 pg_trgm

- 连接到远程服务器 postgres_fdw

- k近邻（KNN）搜索 btree_gist

比如检索10左右的数据，价格在100左右的数据。

```
create index idx_value_001 on t_talbe01 USING gist(value);
select * from t_table01 where value <-> 100 limit 10;
```


