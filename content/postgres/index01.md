---
title: "数据库索引类型及使用场景"
date: 2018-11-19T09:00:44+08:00
draft: false
---

#### 用途

优点

- 主键唯一约束
- 加速检索
- 排序 

缺点

- 更新数据时需要同时维护对应索引
- 占用磁盘空间，甚至比表数据本身还要多

使用场景利弊分析

- TP与AP应用
- 读写使用比例
- 点查询批量查询

#### 创建索引

```
\h create index
命令：       CREATE INDEX
描述：       建立新的索引
语法：
CREATE [ UNIQUE ] INDEX [ CONCURRENTLY ] [ [ IF NOT EXISTS ] 名称 ] ON 表名 [ USING 方法 ]
    ( { 列名称 | ( 表达式 ) } [ COLLATE 校对规则 ] [ 操作符类型的名称 ] [ ASC | DESC ] [ NULLS { FIRST | LAST } ] [, ...] )
    [ WITH ( 存储参数 = 值 [, ... ] ) ]
    [ TABLESPACE 表空间的名称 ]
    [ WHERE 述词 ]
```

#### 注意事项

1. 增加maintenance_work_mem,有利于提高创建索引的效率
2. 创建索引时会有一个share锁锁表，确保表不能有任何更改。在生产系统中如果在一个大表中阻塞时间过长会有问题，解决方法， create index CONCURRENTLY 。  
   创建的时间会增加一倍，不保证会创建成功。


#### 数据库索引类型概览(实现算法)

- b-tree适合所有的数据类型，支持排序，支持大于、小于、等于、大于或等于、小于或等于的搜索。LIKE,ILIKE,~ 搜索。  
- hash 只支持等值查询,特别适用于字段VALUE非常长,例如很长的字符串，并且用户只需要等值搜索，建议使用hash index。 注意：hash索引没有产生wal,主从流复制时从库没有创建 
- gin是倒排索引,适合多值类型，例如数组、JSON、全文检索、TOKEN。  
- gist：R-Tree索引，支持包含，相交，距离，点面判断等查询；适合几何类型、范围类型、全文检索、异构类型等。 
- sp-gist：空间分区（平衡）r-tree，支持包含，相交，距离，点面判断等查询；适合几何类型、范围类型、全文检索、异构类型等。 
- brin：块级索引，适合物理存储与列值存在较好相关性的字段。比如时序数据、物联网传感数据、FEED数据等。支持范围查询、等值查询。  
- rum：扩展索引接口，支持全文检索，支持附加标量类型的全文检索，支持带位置关系的全文检索。  
- bloom 布隆过滤器，支持对任意列的组合查询。

详细介绍 https://leopard.in.ua/2015/04/13/postgresql-indexes   

通过[pageinspect](https://www.postgresql.org/docs/10/pageinspect.html) debug 索引

查看数据库有哪些索引类型
```
select * from pg_am;
 amname |  amhandler  | amtype 
--------+-------------+--------
 btree  | bthandler   | i
 hash   | hashhandler | i
 gist   | gisthandler | i
 gin    | ginhandler  | i
 spgist | spghandler  | i
 brin   | brinhandler | i
(6 行记录)

```

#### 数据索引类型（创建方式）

- 部分索引
- 表达式索引
- 唯一索引
- 多列索引

#### 应用举例

#### 检查缺失的索引

尝试查找出经常被扫描的大型表（avg高）,顺序扫描的占比高，那些表将出现在结果的顶部。

```
SELECT schemaname, relname, seq_scan,seq_tup_read,idx_scan,seq_tup_read / seq_scan AS avg FROM pg_stat_user_tables WHERE seq_scan > 0 ORDER BY seq_tup_read DESC LIMIT 20;
```

#### GiST和GIN索引类型

两种类型的索引可以用于加快全文搜索。注意全文检索不一定非要使用索引。 但是在规则基础上搜索列的情况下，索引往往是可取的。
```
create extention pg_trgm;
CREATE INDEX name ON table USING gist(column);
创建以GiST（通用搜索树）为基础的索引，column可以是tsvector or tsquery 类型。
```
```
create extention pg_trgm; 
CREATE INDEX name ON table USING gin(column);
创建以GIN（基因倒排索引）为基础的索引，column必须是tsvector类型。
```
在两个索引类型之间有着巨大的性能差异，因此了解它们的特性是很重要的。

GiST索引是有损耗的，这意味着该索引可能会产生错误的匹配， 并且有必要检查实际的表行消除这种错误匹配（PostgreSQL需要时自动执行）。 GiST索引是有损耗的，因为每个文档在索引中通过一个固定长度的标签进行表示。 它是通过散列每个单词到一个n位的字符串的单一的点产生，所有这些位OR-ed一起产生一个n位的文件标签。 当两个单词散列到相同点的位置，将有一个错误匹配。如果查询中的所有单词匹配（真实的或错误的）， 则必须检索表行查看匹配是否是正确的。

数据丢失导致了性能下降，由于表记录的不必要的获取，产生了错误的匹配。 由于随机访问表记录是缓慢的，这限制了GiST索引的效能。错误匹配的可能性取决于几个因素， 特别是独特词的数量，所以推荐使用词典来降低这些数量。

GIN索引并没有损耗标准查询，但它们的性能取决于对数独特的单词数。 （然而，GIN索引只存储tsvector值的字（词），而不是它们的权重标签。因此， 当使用涉及权重的查询时，需要复查一个表行。）

在选择要使用的索引类型时，GiST或者GIN考虑这些性能上的差异：

- GIN索引查找比GiST快约三倍

- GIN索引建立比GIST需要大约三倍的时间。

- GIN索引更新比GiST索引速度慢，但如果快速更新支持无效，则慢了大约10倍（详情请见节第 58.4.1 节）

- GIN索引比GiST索引大两到三倍

一般来说，GIN索引对静态数据是最好的，因为查找速度很快。对于动态数据， GiST索引更新比较快。具体而言，GiST索引非常适合动态数据，并且如果独特的字（词）在100,000以下， 则比较快，而GIN索引将处理100,000+词汇，但是更新比较慢。

请注意，GIN索引编译时间通常可以通过增加maintenance_work_mem改进， 而GiST索引编译时间对参数不敏感。 


[原文](http://www.postgres.cn/docs/9.4/textsearch-indexes.html)

其他

Django使用postgresql做数据库 db_index创建索引时会创建第二个索引varchar_pattern_ops问题

https://blog.csdn.net/xiaofuge027/article/details/95338398

删除无用索引

```
DO $$DECLARE r record;
BEGIN
FOR r IN select  indexrelname from pg_stat_user_indexes where schemaname = 'public' and indexrelname like '%like'

LOOP
    EXECUTE 'drop index ' || r.indexrelname ||';';
END LOOP;
END$$;
```

#### 索引管理

```
reindex (verbose) table 
```
