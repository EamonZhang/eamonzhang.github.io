---
title: "LSM Overview"
date: 2018-11-26T13:40:19+08:00
draft: false
---

#### 介绍

LSM-Tree，全称为 log-structured merge-tree，是为了满足日益增长的数据量所带来的高效写性能的需求而提出的设计。考虑到磁盘随机写和顺序写上千倍的性能差距，传统的Btree 结构设计采取的分散的 update-in-place 策略在数据量庞大、写缓存作用有限的情况下，存在大批量的随机写操作，使得写性能完全满足不了新数据的业务需求。为了提高写速率，LSM-Tree 采取的简单高效的日志结构的设计，将所有写操作的结果先缓存在内存并按次序分批写入硬盘，在底层管理多个版本的数据内容。理所当然地，不管是在点查还是范围查询的场景下，简单的日志结构会使得读的性能不高。因此为了提高读的性能，适当地保持系统内一定的有序性，引入排序开销是有必要的，即采取 LSM 里的 Merge 操作。此外在日志的基础上也可以添加额外的索引结构，例如 Bloomfilter 或者块索引设计。缓存友好的索引结构能够有效降低 IO 次数，快速定位到查询的数据具体的位置。

在 LSM 结构设计当中，数据按写入顺序拆分成多个批次的数据集合，包括了内存中的Memtable 和硬盘上的 SSTable。具体地，数据插入到 Memtable 当中，在 MemTable 大小超过一定阈值后进行 Flush 操作，变成不可修改的、内部有序的 SSTable。SSTable 在后台根据一定的层次结构进行组织。如下图是一个典型的多个 Level 的层次设计，Level-0 对应多个 Memtable，Level-1 对应 Flush 到硬盘上的多个相互之间无序的 SSTable，Level-2 对应一个有序的大 SSTable。

![](images/lsm01.png)

在适当的条件下后台会触发 Merge 操作，合并多个旧 SSTable 成新的 SSTable。合并的目的是为了减少文件数量，提高读的性能，此外也能够进行垃圾回收，减少多版本数据占用的空间大小。值得注意的是，后台 Merge 可能是一个特别影响前台读、写性能的操作。若系统对读要求越高，即对有序性要求越严格，往往需要更加积极的 Merge 操作，也往往会导致更剧烈的写放大，对系统整体而言累积下来的负担是更大的。


在LSM结构设计中所有的写操作都将是顺序写，换来的代价：

读放大：查询一个 Key 值所对应的 Value 值，可能需要遍历多个 SSTable 文件，对应了复数次随机 IO。

空间放大：多版本数据在合并之前会占用更多的存储空间。

写放大：在系统稳定后硬盘写数据的累积值 / 数据第一次写入硬盘的大小，该比值在LevelDB 或 RocksDB 中可达两位数。

总结来说，LSM结构设计能够提供非常好的写性能，在读方面需要结合业务特性，通过合理的层次结构设计以及索引结构控制负面影响，能够使得读性能达到业务能够接受的范畴。

目前随着固态硬盘的普及，不同于传统Btree结构在大量随机写情况下可能导致FTL层繁重的垃圾回收负载，LSM 的日志结构设计对于固态硬盘天然的友好性以及较为简单的设计模式，使其受到了很多存储引擎开发者的青睐。然而后台排序导致的写放大对于寿命有限的固态盘来说，是 LSM 中备受关注的痛点，近年来也有不少关于 LSM 在 SSD 上深度优化的相关研究。

#### LSM in RocksDB

RocksDB 是 Facebook 公司基于 LevelDB 开发的一款使用日志结构的开源嵌入式数据库引擎。在 LevelDB 基础上，RocksDB 在硬件上针对多核 CPU 和 SSD 设备在底层做了优化，在软件上在 Single-Writer 的锁处理、LSM 组织结构、DB锁的处理等方面进行了一系列改进，同时提供了更加丰富的功能特性，例如数据压缩、多线程 Compaction、前缀BloomFilter、列簇等。

RocksDB 默认使用了 kCompactionStyleLevel 类型的 Compaction 形式，有利于提高 Compaction 的并行度。文件组织形式如下图，在硬盘上管理 L0 到 Ln 层的 SSTable 文件。除开 L0 层，其他层的每一层，层内所有 SSTable 文件相互之间 Key 值范围是不重叠的，整体在逻辑上可以形成一个有序的 KV序列。在这种层次结构设计中，Memtable 会首先 Flush 到 L0 层成为不可修改的 SSTable 文件，当 L0 层文件数量超过了某个阈值将会触发 L0 到 L1 层的 Compaction，同理 Ln 层（n>0）的文件内容足够多的时候也将 Compaction 到 Ln+1 层，数据不断下沉直到最后一层。

![](images/lsm02.png)

#### LSM构成元素

具体到 RocksDB 中的 LSM，有3个比较重要的构成元素：

版本管理
 
---   

- Version：对应了 RocksDB 在某个时刻点下组成层次结构的一组 SSTable 文件的所有元信息。Version 之间组成链表，通过 VersionEdit 记录相邻节点之间文件变动的情况。

- VersionSet：维护所有列簇的 Version 链表，持久化到.mainfest 文件。此外还提供了 LevelIterator 创建、Compaction 触发相关的接口。

- SuperVersion：由当前 Memtable、immutable Memtable 列表和 Version 构成，描述一个列簇在某个时刻点下的所有版本信息。

Memtable 

---  

RocksDB 存在一个 Active 状态的 Memtable 和多个 Immutable 状态 Memtable，默认的数据结构类型为 Skiplist 类型。Skiplist 能够提供对数级的插入/删除/查询性能，在并发上使用 CAS 实现了无锁操作，适合高并发的混合负载，性能表现优异。


SSTable  
 
--- 

全称为 Sorted-String-Table，RocksDB 默认使用 BlockBasedTable 类型的 SSTable，对应由一系列存储块构成的物理文件。如下图，存储块根据数据内容可以分为数据块、BloomFilter 数据块、Table 属性块、范围删除块、索引块、元索引块等，额外的 Footer 结构是固定模式的、能够帮助解析文件结构的元信息。


https://mp.weixin.qq.com/s?__biz=MzI2MjQ5NTc1OQ==&mid=2247484186&idx=1&sn=1f74da3d52965d40da4e23c0b7494cfc&chksm=ea4b087add3c816c9a4db093abb1937bc10e1ac315eac04cd35c86f289dc347236ea570fa5a4&scene=0&pass_ticket=MqqsDfWQLOdOLkVQV1nxXZXj%2BnIp1FZZN7MTTFUGDf5s7nhDnBNPQ4NxjXb%2FFbM0#rd
