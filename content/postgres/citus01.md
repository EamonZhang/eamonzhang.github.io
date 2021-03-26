---
title: "citus 简单应用"
date: 2019-06-05T10:40:09+08:00
draft: false
---

#### 常用方法

集群管理
```
加入节点
SELECT * from master_add_node('worker-101', 5432);
查看节点状态
SELECT * FROM master_get_active_worker_nodes();

select * from pg_dist_node;
```

数据库管理

- 分片表(distributed table ， hash | append )
- 参考表(reference table 数据量小)
- 本地表(原生表，没有任何处理.兼容性高)


```
对表进行分片

SELECT create_distributed_table('companies', 'id');

分片查看
SELECT * from pg_dist_shard;
```

元数据表

```
pg_dist_shard
pg_dist_placement
pg_dist_node
```


[参数](https://www.modb.pro/db/13049)

[更多参考](https://chenhuajun.github.io)

sql 限制

1 非亲和性表之间的outer join 

方案： CTE 广播 、临时表、fdw


2 本地表参与的join 不支持

3 postgis 支持的限制，复杂计算

注意事项

1 max_adptive_executor_pool_size 防止但库负载过大

2 参考表默认查询每次都是访问一个数据库的分布。 设置 task_assigment_policy TO 'rond ' 轮询使用

3 ddl 语言需要在每个节点中执行。

https://blog.csdn.net/icreasy3/article/details/90720192
