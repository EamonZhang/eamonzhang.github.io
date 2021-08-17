---
title: "使用prepare预编译SQL"
date: 2021-07-21T16:37:53+08:00
draft: false
toc: false
categories: []
tags: []
---

## 使用预编译优势介绍 

在执行一个SQL时，首先生成执行计划（进行语义分析、词法解析、逻辑优化、物理优化）、执行、结果传输等操作。
如果一个SQL在应用中反复使用，我们可以将此SQL参数化，只做一次prepare，后面执行时就不需要进行前面执行计划的生成操作，直接使用prepare好的执行计划。

对于比较长的SQL、参数较固定的SQL，可以使用prepare，

特点：
1) Prepared语句只在session的整个生命周期中存在，一旦session结束，Prepared语句也不存在了。如果下次再使用需重新创建。
2) Prepared语句不能在多个并发的client中共有。
3) prepared语句可以通过DEALLOCATE命令清除。
4) 当前session的prepared语句：pg_prepared_statements


```
-- 创建
PREPARE test_pre(id, name) AS select id,name t where id = $1;

-- 使用
explain analyze EXECUTE test_pre(1);
 Index Scan using t_pkey on t  (cost=0.29..2.51 rows=1 width=16) (actual time=0.019..0.021 rows=1 loops=1)
   Index Cond: (id = $1)
 Planning Time: 0.015 ms
 Execution Time: 0.049 ms
```

看见 $1  说明符合预期
