---
title: "Bloom 索引"
date: 2020-04-23T15:37:33+08:00
draft: false
---

#### Bloom 索引 

Bloom 过滤器代表的是一组值。它的作用是检测一个元素是否可能属于集合，它可以允许有一些false positive，但是不允许存在false negative。也就是说，尽管某个元素不在集合中，测试也可能返回true。然而，如果元素在集合中，就不可能返回false。 
创建在一组列中的Bloom索引可以被用来加速在这些列的子集上用AND相连的等式的查询。 

当表具有很多属性并且查询可能会测试其中任意组合时，这种类型的索引最有用。传统的 btree 索引比布鲁姆索引更快，但是需要很多 btree 索引来支持所有可能的查询，而对于布鲁姆索引来说只需要一个即可。

###### 注意: bloom 索引只支持等值查询，而 btree 索引还能执行不等和范围搜索。


#### 创建一个索引

```
CREATE INDEX bloomidx ON tbloom USING bloom (i1,i2,i3)
       WITH (length=80, col1=2, col2=2, col3=4);
```
with 部分可省略

length 每个签名（索引项）的长度位数。默认是80位，最长是4096位。

col1 — col32 从每一个索引列产生的位数。每个参数的名字表示它所控制的索引列的编号。默认是2位，最大是4095位。没有实际使用的索引列的参数会被忽略。

#### 使用例子

http://postgres.cn/docs/10/bloom.html
