---
title: "postgres 12"
date: 2019-11-19T08:43:36+08:00
draft: false
---

##### 安装&启动

```
#下载源
yum install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm
#安装服务
yum install postgresql12 postgresql12-server postgresql12-contrib
#初始化
/usr/pgsql-12/bin/postgresql-12-setup initdb
#启动服务
systemctl enable postgresql-12
systemctl start postgresql-12
```

##### 流复制

```
#从机 建立从库
pg_basebackup -h 10.1.30.13 -U postgres -F p -P -R -D /var/lib/pgsql/12/data/ --checkpoint=fast -l postgresback
#从库升级为主库
sudo su postgres -c  "/usr/pgsql-12/bin/pg_ctl promote -D /var/lib/pgsql/12/data/"
```

- recovery.conf 配置文件不再支持，此文件中的参数合并到 postgresql.conf(postgresql.auto.conf) Recovery Target, 若 recovery.conf 存在，数据库无法启动
- 新增 recovery.signal 标识文件，表示数据库处于 recovery 模式
- 新增加 standby.signal 标识文件，表示数据库处于 standby 模式
- trigger_file 参数更名为 promote_trigger_file
- standby_mode 参数不再支持

在postgres 12 版本中新增一个激活从库为主库的方式。pg_promote 函数，相比原有的两种方式，这种方法的优点在于不需要登陆到实体机上，可远程通过sql进行操作。
pg_promote() 函数有两个参数:

- wait: 表示是否等待备库的 promotion 完成或者 wait_seconds 秒之后返回成功，默认值为 true。
- wait_seconds: 等待时间，单位秒，默认 60

流复制主备切换主要步骤如下:

步骤1 关闭主库  

步骤2 激活备库: 三种方式任选一种: 1) pg_ctl promote 命令方式; 2) 创建触发器文件方式; 3) pg_promote()函数方式。

步骤3 老主库角色转换成备库: 在老主库主机 pghost1 的 $PGDATA 目录下创建 standby.signal 标识文件,postgresql.auto.conf 类似于以前版本的recovery.conf。

步骤4 启动老主库并验证

[具体操作](https://postgres.fun/20190719084100.html)

##### 分区表

支持类型 

- Range  
- List  
- Hash  

创建表
```
CREATE TABLE measurement (
    city_id         int not null,
    logdate         date not null,
    peaktemp        int,
    unitsales       int
) PARTITION BY RANGE (logdate);
```

创建分区
```
CREATE TABLE measurement_y2006m02 PARTITION OF measurement
    FOR VALUES FROM ('2006-02-01') TO ('2006-03-01');

CREATE TABLE measurement_y2006m03 PARTITION OF measurement
    FOR VALUES FROM ('2006-03-01') TO ('2006-04-01');

--- 默认分区
CREATE TABLE measurement_y2006m02 PARTITION OF measurement
    default;
```

插入数据
```
select  cast(random()*10 as integer), date'2006-02-01'  + (id||' hour')::interval,cast(random()*30 as integer),cast(random()*10000 as integer) 
    from generate_series(1,2000) t(id);
```

创建索引,与以前版本的区别可以在父表上统一创建索引。也可以在每个子表上根据需求分别创建索引。更灵活。  
建议在分区列上创建索引，利用分区裁剪（enable_partition_pruning）提高效率。
```
CREATE INDEX ON measurement (logdate);
```

维护分区表
```
--- 删除分区表,会锁主表
DROP TABLE measurement_y2006m02;
--- 通常方式，将分区表脱离出主表，然后在对分区表进行操作
ALTER TABLE measurement DETACH PARTITION measurement_y2006m02;

--- 将已有表作为分区表加入到主表中, 直接加入会锁主表
ALTER TABLE measurement ATTACH PARTITION measurement_y2008m02
    FOR VALUES FROM ('2008-02-01') TO ('2008-03-01' );

--- 通常做法，对需要对加入的分区表加检查约束，然后在将分区表加入到主表中

ALTER TABLE measurement_y2008m02 ADD CONSTRAINT y2008m02
   CHECK ( logdate >= DATE '2008-02-01' AND logdate < DATE '2008-03-01' );

ALTER TABLE measurement ATTACH PARTITION measurement_y2008m02
    FOR VALUES FROM ('2008-02-01') TO ('2008-03-01' );
```

分区表可以存在于不同的表空间中，这样的特性方便数据的冷热区分处理。

对索引的管理

通常情况下如果对一张表加入索引会堵塞该表的dml操作，特别是对一张大表的操作。

默认情况下，如果在主表中加入一个索引，该索引也会加入到索引的子表中，无论是现有的子表还是将来新加入的字表。这样极大的方便了对分区表的维护。目前在分区表上建立索引时不支持CONCURRENTLY

但是考虑的对在线业务的影响，在分区表中建议的操作流程。 

首先在主表上使用 create index on only 语句创建索引，然后分别在子表上创建索引。当所有子表上的索引都建立完毕后主表上的索引被激活。

该方式也适用于其他（约束）等

```
CREATE INDEX measurement_usls_idx ON ONLY measurement (unitsales);

CREATE INDEX measurement_usls_200602_idx
    ON measurement_y2006m02 (unitsales);
ALTER INDEX measurement_usls_idx
    ATTACH PARTITION measurement_usls_200602_idx;

```



##### 其他

https://yq.aliyun.com/articles/720247?spm=a2c4e.11153940.0.0.48cf2f79tPuOrL

https://github.com/digoal/blog/blob/0ef02248fe7419c55a98a425feefd2421ad25537/201906/20190624_02.md
 
