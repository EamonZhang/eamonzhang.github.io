---
title: "数据库备份和恢复"
date: 2018-10-30T10:18:57+08:00
draft: false
---
Postgres 数据库备份恢复命令

```
备份：pg_dump -U postgres -v -F c -Z 4 -f ***.backup dbname  9压缩率最狠
恢复：pg_restore -U postgres -v -j 8 -d dbname ***.backup   8是采用8个线程

备份表：pg_dump -U postgres -t tablename dbname > 33.sql
恢复表：psql -U postgres -d dbname < 33.sql

只备份表结构 pg_dump -U postgres -s -t tablename dbname > 33.sql
只备份数据 pg_dump -U postgres -a -t tablename dbname > 33.sql
```

copy 拷贝数据
```
数据拷贝到本地： psql -U postgres -d databasename  -p 5432 -h 10.1.1.1 -c "\copy (select * from $tablename where xxx) to '/tmp/db/$tablename.csv'";

数据恢复到数据库: psql -U postgres -d databasename -p 5432 -h 127.0.0.1 -c "\copy $tablename from '/tmp/db/$tablename.csv'"; 
```
说明： copy 与 \copy 区别， \copy cvs数据在client端、copy svs数据在server端。

注意事项: 需要在新数据库中对序列进行更新

```
psql -U postgres -d databasename -p 5432 -h 127.0.0.1 -c "select setval('xxxx_id_seq', max(id)) from xxx_table";

```

copy from 数据量大时效率太低替代方法

```
/usr/pgsql-10/bin/pg_bulkload -U postgres -d dataname -i /xxx/xxx.csv -O tablename -l /tmp/xxx.log -P /tmp/xxx.bad -o "TYPE=CSV" -o $'DELIMITER=\t'
```

说明： pg_bulkload 为拓展形式。 需要在数据库中'create extends pg_bulkload' 。 


##### pg_bulkload 与copy 区别

 
copy将构造出的元组插入共享内存，同时写日志，pg_bulkload绕过了共享内存，不写日志，这样会减少磁盘I/O，但是也很危险。

###### 使用pg_bulkload方式导入数据时一定要注意，注意，注意！！！　由于不写wal日志从库无法同步，从库直接宕掉，直接宕掉！！！ 测试用就好,生产环境需谨慎

实时备份恢复

https://github.com/ossc-db/pg_rman

https://github.com/wal-e/wal-e

https://github.com/wal-g/wal-g

备份恢复管理

https://github.com/pgbackrest/pgbackrest

由于原始库中存在extension 需要超级管理员权限进行恢复，恢复后将所有者变更为普通用户。
pg中没有方法可以将整个database 中table 的 owner 进行修改，使用如下方法进行批量修改


批量修改表和视图的所有者
```
DO $$DECLARE r record;
BEGIN
FOR r IN SELECT tablename/viewname FROM pg_tables/pg_views WHERE schemaname = 'public'
LOOP
    EXECUTE 'alter table '|| r.tablename/r.viewname ||' owner to new_owner;';
END LOOP;
END$$;
```
---

##### wal-g 应用

###### 存储服务 minio

设置用户名和密码
```
docker run -d -p 9000:9000 -e MINIO_ACCESS_KEY=xxxxx(changeme) -e MINIO_SECRET_KEY=kkkkk(changeme)  -v /data/minio/:/data  minio/minio server /data 
```
创建 bucket

```
mc mb local/buecket003
```

###### wal-g 下载 

```
wget https://github.com/wal-g/wal-g/releases/download/v0.2.9/wal-g.linux-amd64.tar.gz

tar -zxvf wal-g.linux-amd64.tar.gz 
```

[下载地址](../tools/wal-g.linux-amd64.tar.gz)

###### 设置环境变量

minio

cat wal-g.env 
```
export PGDATA=/var/lib/pgsql/10/data/
export WALG_S3_PREFIX=s3://bucket003/
export PGPORT=5432
export PGUSER=postgres
export AWS_SECRET_ACCESS_KEY=xxxxx(changeme)
export AWS_REGION=us-east-1
export AWS_ACCESS_KEY_ID=kkkkk(changeme)
export AWS_ENDPOINT=http://localhost:9000
export AWS_S3_FORCE_PATH_STYLE=true
```

swift

```
export PGDATA=
export WALG_SWIFT_PREFIX=swift://buckt003/
export PGPORT=
export PGUSER=
export OS_USERNAME=
export OS_PASSWORD=
export OS_AUTH_URL=http://ip:port/auth/v1.0
```

###### 全备份

```
source mydir/wal-g.env &&  wal-g  backup-push $PGDATA
```

###### wal 备份

```
wal_level = archive
archive_mode = on ## 从库 always
archive_command = 'source mydir/wal-g.env &&  wal-g wal-push %p'
archive_timeout = 60
```

###### 恢复数据

查看所有全备份

```
wal-g backup-list
name                          last_modified        wal_segment_backup_start
base_000000020000001E000000CB 2019-11-07T01:34:08Z 000000020000001E000000CB
base_000000020000001E000000CD 2019-11-07T01:37:03Z 000000020000001E000000CD
base_000000020000001E000000CF 2019-11-07T02:23:34Z 000000020000001E000000CF
base_000000020000001E000000D1 2019-11-07T02:31:00Z 000000020000001E000000D1
base_000000020000001E000000D3 2019-11-07T02:38:29Z 000000020000001E000000D3
base_000000020000001E000000DA 2019-11-07T06:08:19Z 000000020000001E000000DA
base_000000020000001E000000DD 2019-11-07T06:30:24Z 000000020000001E000000DD
base_000000020000001E000000DF 2019-11-07T08:45:30Z 000000020000001E000000DF
```

下载一个全备份 最近的一个全备份可用 LATEST 表示
```
wal-g backup-fetch /var/lib/pgsql/10/data-restore/ base_000000020000001E000000CB
```

实时恢复

cat recover.conf
```
restore_command = 'source mydir/wal-g.env && wal-g wal-fetch %f %p'
recovery_target_time='2019-09-10 09:51:55.794813+08'
recovery_target_timeline='latest'
```

关闭数据库pause状态
```
select pg_wal_replay_resume();
```

###### 清理存储

保留最近的10个备份及wal
```
wal-g delete  retain  FULL  10 (试删)

wal-g delete  retain  FULL  10  --confirm （真删） 
```

删除某个备份前的备份

```
wal-g delete before backup_name
```

###### 将现有的所有wal上传

cat wal-push-all.sh
```
#!/bin/bash
#print the directory and file
 
for file in $PGDATA/pg_wal/*
do
if [ -f "$file" ]
then 
  wal-g wal-push $file
fi
done
```

###### 注意事项

1 需要先进行wal日志的备份在进行全备份。否则在恢复的时候可能会遗漏期间的wal日志。

2 全备份需要等待当前wal日志发生切换才能完成。如果是写入慢或暂无写入数据库可执行select pg_switch_wal() 进行手动触发。

3 全备份不包括pg_wal目录下的wal日志文件
###### 思考

归档备份wal日志 会比生产系统的数据库滞后一个wal文件 。 是当wal日志写满或切换写新wal日志的时候触发的归档 。

如果需要使用归档文件恢复数据库时需要考虑时候可以找到最近的wal日志文件，比如在从库中。
