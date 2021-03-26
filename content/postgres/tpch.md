---
title: "tpch AP测试"
date: 2019-06-05T09:36:21+08:00
draft: false
---

#### 背景介绍

24sql

#### TPC-H 基准测试

##### 下载安装
[tpch-tools安装包](./tools/tpch-tools.tgz)

修改makefile.suite 模版

```
CC=gcc 
DATABASE-TDAT
MACHINE=LINUX
WORKLOAD=TPCH
```
执行 make 进行编译

##### 生成测试数据

生成20G测试数据

```
./dbgen -s 20
ls -lrth *.tbl
```

自动生成的测试数据每行的结尾多余一个 '|' 需要处理

```
for i in `ls *.tbl`; do sed 's/|$//' $i > ${i/tbl/csv}; echo $i; done;
```

##### 创建表及索引

在下面的文件中分别是创建表和对应索引的sql

dss.ddl      
dss.ri

##### 导入数据

```
copy customer from '/opt/tpch-tools/dbgen/customer.csv' with DELIMITER '|';
copy lineitem from '/opt/tpch-tools/dbgen/lineitem.csv' with DELIMITER '|';
copy nation from '/opt/tpch-tools/dbgen/nation.csv' with DELIMITER '|';
copy orders from '/opt/tpch-tools/dbgen/orders.csv' with DELIMITER '|';
copy partsupp from '/opt/tpch-tools/dbgen/partsupp.csv' with DELIMITER '|';
copy region from '/opt/tpch-tools/dbgen/region.csv' with DELIMITER '|';
copy supplier from '/opt/tpch-tools/dbgen/supplier.csv' with DELIMITER '|';
```

##### 基准测试

在queries 目录下存放的是24条sql
