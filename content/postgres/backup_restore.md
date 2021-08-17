---
title: "数据库备份和恢复"
date: 2018-10-30T10:18:57+08:00
categories: ["postgres"]
toc : true
draft: false
---
## 备份恢复命令

```
备份：pg_dump -U postgres -v -F c -Z 4 -f ***.backup dbname  9压缩率最狠
恢复：pg_restore -U postgres -v -j 8 -d dbname ***.backup   8是采用8个线程

备份表：pg_dump -U postgres -t tablename dbname > 33.sql
恢复表：psql -U postgres -d dbname < 33.sql

只备份表结构 pg_dump -U postgres -s -t tablename dbname > 33.sql
只备份数据 pg_dump -U postgres -a -t tablename dbname > 33.sql
```

## copy 拷贝数据
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


## pg_bulkload 与copy 区别

 
copy将构造出的元组插入共享内存，同时写日志，pg_bulkload绕过了共享内存，不写日志，这样会减少磁盘I/O，但是也很危险。

###### 使用pg_bulkload方式导入数据时一定要注意，注意，注意！！！　由于不写wal日志从库无法同步，从库直接宕掉，直接宕掉！！！ 测试用就好,生产环境需谨慎

## 实时备份恢复

https://github.com/ossc-db/pg_rman

https://github.com/wal-e/wal-e

https://github.com/wal-g/wal-g

## 备份恢复管理

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

