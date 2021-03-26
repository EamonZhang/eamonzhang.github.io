---
title: "Pipelinedb文档概览"
date: 2018-12-12T09:46:16+08:00
draft: false
---

[官方文档](http://docs.pipelinedb.com/index.html)


#### 介绍

What PipelineDB is    
What PipelineDB is not    

#### QuitStart

一个统计wiki浏览的例子

#### 安装

各种环境安装

#### Continuous Views

定义流视图，其实就是定义 统计分析的QUERY， 例如select id, count(*), avg(x), ... from table group by ...;
定义好之后，数据插入table，这个流视图就会不断增量的进行统计，你只要查询这个流视图，就可以查看到实时的统计结果。
数据库中存储的是实时统计的结果（实际上是在内存中进行增量合并的，增量的方式持久化）。

CREATE CONTINUOUS VIEW    
DROP CONTINUOUS VIEW    
TRUNCATE CONTINUOUS VIEW    
Viewing Continuous Views    
Data Retrieval    
Time-to-Live (TTL) Expiration    
Activation and Deactivation    
Examples    

#### Continuous Transforms

与流视图不同的是，transform是用来转换数据流的，所以它可以不保留数据，但是可以设定条件，当记录满足条件时，就触发事件。

用途，将输入的数据流进行转换处理，过滤，加工等，用于复杂的业务逻辑，比如多个来源的数据流的合并加工。与现有的表进行joins操作,可以将结果传入其他流中，实现持续转换。

例如监视传感器的值，当值的范围超出时，触发报警（如通过REST接口发给指定的server），或者将报警记录下来（通过触发器函数）。

CREATE CONTINUOUS TRANSFORM    
DROP CONTINUOUS TRANSFORM    
Viewing Continuous Transforms    
Built-in Transform Triggers    
Creating Your Own Trigger    

#### Streams

流视图和transform都是基于流的，所以流是基础。

我们首先需要定义流，往流里面写数据，然后在流动的数据中使用流视图或者transform对数据进行实时处理。

Writing To Streams    
Output Streams    
stream_targets    
Arrival Ordering    
Event Expiration 

#### Built-in Functionality

内置的函数

General    
Aggregates    
PipelineDB-specific Types    
PipelineDB-specific Functions    
Miscellaneous Functions 

#### Continuous Aggregates

聚合的介绍，通常流处理分两类，即前面讲的

流视图（通常是实时聚合的结果），比如按分钟实时的对红绿灯的车流统计数据绘图，或者按分钟对股票的实时数据进行绘图。

transform（事件处理机制），比如监控水质，传感器的值超出某个范围时，记录日志，并同时触发告警（发送给server）。

PipelineDB-specific Aggregates    
Combine    
CREATE AGGREGATE    
General Aggregates    
Statistical Aggregates    
Ordered-set Aggregates    
Hypothetical-set Aggregates    
Unsupported Aggregates   

#### Clients

几种常见的客户端用法，实际上支持PostgreSQL的都支持pipelinedb，他们的连接协议是一致的。

Python    
Ruby    
Java   

#### Probabilistic Data Structures & Algorithms

概率统计相关的功能，例如HLL等。用起来也非常的爽，例如统计网站的UV，或者红绿灯通过的汽车编号唯一值车流，通过手机信号统计基站辐射方圆多少公里的按时UV等。

Bloom Filter    
Count-Min Sketch    
Filtered-Space Saving Top-K    
HyperLogLog    
T-Digest    

#### Sliding Windows

因为很多场景的数据有时效，或者有时间窗口的概念，所以pipelinedb提供了窗口分片的接口，允许用户对数据的时效进行定义。

例如仅仅统计最近一分钟的时间窗口内的统计数据。

比如热力图，展示最近一分钟的热度，对于旧的数据不关心，就可以适应SW进行定义，从而保留的数据少，对机器的要求低，效率还高。

Examples    
Sliding Aggregates    
Temporal Invalidation    
Multiple Windows    
step_factor    

#### Continuous JOINs

流视图 支持JOIN，支持JOIN，支持JOIN，重要的事情说三遍。

流 JOIN 流(未来版本支持,目前可以通过transform间接实现)

流 JOIN TABLE(已支持)

Stream-table JOINs    
Supported Join Types    
Examples    
Stream-stream JOINs 

#### Backup

与pg数据相同，如果单独备份出一个视图需要与对应的物化表一同备份。

#### Replication

依赖于pg数据库流复制， HA 可以使用Patroni

#### Integrations

- Apache Kafka  

- Amazon Kinesis

#### Statistics

统计信息，对于DBA有很大的帮助

pipelinedb.proc_stats    
pipelinedb.query_stats    
pipelinedb.stream_stats    
pipelinedb.db_stats 

#### Configuration

##### pipelinedb.stream_insert_level  
性能最佳，可以设置为async，数据写入内存即响应写入客户端。  
性能适中，设置为sync_receive，数据被worker process接收后响应写入客户端。 (默认值)
测试环境, sync_commit

##### pipelinedb.num_combiners   
有多少个combiner进程。由于combiner进程负责将计算好的结果数据合并落盘，所以当设置的COMBINER进程个数足够达到IO瓶颈时为宜。设置取决于IO能力。    

##### pipelinedb.commit_interval    
每个combiner进程，会先将合并的结果数据HOLD在combiner_work_mem，以提高性能。commit_interval表示间隔多长时间刷提交结果。    

##### pipelinedb.num_workers  
worker进程负责计算STREAM上定义的continue view, continue transform。   
设置取决于有多少STREAM，有多少continue view, continue transform，有多少CPU能力。   

###### pipelinedb.num_queues   
当数据从STREAM取出（worker和combiner批量消费、计算stream内的数据，并将结果持久化到磁盘，然后从stream中清掉对应的流数据。整个过程需要queue process，确保做这一系列动作的时候，不影响用户持续将数据写入stream。）    
设置取决于num_workers，num_combiners。   

##### pipelinedb.num_reapers   
reaper进程，用于清除设置了TTL的continue view的过期数据。   
类似于后台定时任务进程。不需要太多，设置取决于有多少设置了TTL的continue view。

##### pipelinedb.ttl_expiration_batch_size     
清除设置了TTL的continue view的过期数据。
一个事务中，最多清理多少条数据，主要防止长事务。

##### pipelinedb.ttl_expiration_threshold    
当超出设置阈值多少后，开始清理过期数据。  
例如设置TTL为2天，设置ttl_expiration_threshold为5%。  
那么当数据过期达到 (2 + 5%*2) 天后，才开始触发清理。   
也可以理解为TTL continue view的膨胀率。  

#####  pipelinedb.batch_size    
当查询continuous view时，会触发PIPELINEDB对continuous view的结果进行持久化。    
batch_size设置，表示执行continuous view查询前，最多允许多少个events堆积(例如insert stream的条数)。    
设置越大，可能增加查询continuous view的响应延迟，或者当数据库CRASH时丢掉更多数据。   

##### pipelinedb.combiner_work_mem  
每个combiner的工作内存大小。combiner process在合并WORKER计算结果时用于排序，HASH TABLE等。   
如果combiner使用内存超出这个设置，则使用磁盘。  

##### pipelinedb.anonymous_update_checks    

Toggles whether PipelineDB should anonymous check if a new version is available. Default: true.

##### pipelinedb.matrels_writable   
是否允许continue view被直接修改。（直接通过SQL修改，而不是仅被combiner进程修改）
Toggles whether changes can be directly made to materialization tables. Default: false.

##### pipelinedb.ipc_hwm

Sets the high watermark for IPC messages between worker and combiner processes. Default: 10.

##### pipelinedb.max_wait   
与pipelinedb.batch_size含义类似，只是时间度量。   
执行continuous view查询前，最多允许等多长时间。  

##### pipelinedb.fillfactor    
continue view的fillfactor，由于流计算的结果continue view需要经常被combiner更新，所以多数为更新操作，那么设置合理的fillfactor可以使得更容易HOT（避免索引膨胀）。   
Default: 50.

##### pipelinedb.sliding_window_step_factor    
滑窗continue view的小窗颗粒度。
例如定义滑窗为1小时，那么这个视图就是最近一小时的统计，为了得到这个统计值，必须实时老化一小时前的数据，保持统计是最近一小时的。怎么做到的呢？   
实际上pipelinedb内部通过定义比滑窗更小粒度窗口的实时统计，把窗口切成更小的窗口，查询时对小粒度窗口进行汇聚产生大窗口的数据。   
例如定义的窗口为1小时，那么可以按分钟的粒度进行统计，查询时，汇聚最近的60个窗口的数据，得到小时的窗口数据。   
颗粒度为5，表示5%的颗粒。例如定义窗口为1小时，那么颗粒就是5%*60min = 3min，也就是说会3分钟统计一个值，最后查询时汇聚为1小时的窗口值   


