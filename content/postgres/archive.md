---
title: "Archive wal归档"
date: 2019-01-30T14:20:38+08:00
draft: false
---

##### 介绍

所谓WAL日志归档，其实就是把在线的WAL日志备份出来。

##### 配置

vi postgresql.conf
```
wal_level='replica'

# - Archiving -

archive_mode = on               # enables archiving; off, on, or always
                                # (change requires restart)
archive_command = 'test ! -f /mnt/backup/%f && cp %p /mnt/backup/%f'
                                # command to use to archive a logfile segment
                                # placeholders: %p = path of file to archive
                                #               %f = file name only
                                # e.g. 'test ! -f /mnt/server/archivedir/%f && cp %p /mnt/server/archivedir/%f'
#archive_timeout = 0            # force a logfile segment switch after this
                                # number of seconds; 0 disables

```

##### 参数说明

- wal_level archive 或更高级别
- archive_mode on 开启归档模式，always 主从模式时，从库也开启归档模式。需要重启数据库
- archive_command 归档时触发的命令或脚本， 不需要重新启动数据库。 systemctl reload postgresql-10 即可。
- archive_timeout 可以理解为超过指定时间强制执行  select pg_switch_wal(); 场景， 数据库不是很活跃，数据库wal日志产生的过慢时。

##### 归档触发条件说明：

1 手动执行 select pg_switch_wal();  
2 WAL 日志写满后触发归档 WAL 日志文件默认为 16MB，这个值可以在编译 PostgreSQL 时通过参数 “–with-wal-segsize” 更改，编译后不能修改。      
3 如果设置 archive_timeout， 超时触发。   

##### 归档备份说明：

在数据库data目录的pg_wal文件夹中存放着我们需要备份的wal文件，  
其中 archive_status文件夹里面存放的是状态文件，可以归档的标记为ready，归档后为done

##### 简单尝试

创建备份存储目录

```
mkdir /mnt/backup/
chown postgres:postgres /mnt/backup/
chmod 0700 /mnt/backup/
```

配置数据库

```
wal_level='replica'
archive_mode = on
archive_command = 'test ! -f /mnt/backup/%f && cp %p /mnt/backup/%f'
```

重启或reload 使配置生效

手动触发,查看结果  select pg_switch_wal(); 

如果遇到问题结合查看数据库日志

查看归档状态

```
postgres=# select * from pg_stat_archiver ;  
 archived_count |    last_archived_wal     |      last_archived_time       | failed_count |     last_failed_wal      |       last_failed_time        |         stats_reset          
----------------+--------------------------+-------------------------------+--------------+--------------------------+-------------------------------+------------------------------
             64 | 00000001000000C3000000A6 | 2019-03-15 09:23:46.991612+08 |           27 | 00000001000000C30000006B | 2019-03-14 14:05:04.921754+08 | 2019-03-07 10:08:45.58083+08
```

##### 实际应用

目标：按日期存放wal日志到/mnt/archdir/

归档脚本
```
vi archive.sh     
#!/bin/bash    
    
export LANG=en_US.utf8    
export DATE=`date +"%Y%m%d"`    
    
BASEDIR="/mnt/archdir"    
    
if [ ! -d $BASEDIR/$DATE ]; then    
  mkdir -p $BASEDIR/$DATE    
  if [ ! -d $BASEDIR/$DATE ]; then    
    echo "error mkdir -p $BASEDIR/$DATE"    
    exit 1    
  fi    
fi    
    
cp $1 $BASEDIR/$DATE/$2    
if [ $? -eq 0 ]; then    
  exit 0    
else    
  echo -e "cp $1 $BASEDIR/$DATE/$2 error"    
  exit 1    
fi    
    
echo -e "backup failed"    
exit 1    
```

权限
```
chmod 700 archive.sh  
```

配置调用命令
```
archive_command = 'archive.sh %p %f'  
```

重新加载生效
```
systemctl reload postgresql-10
```

#### 扩展阅读

如何删除wal文件

```
#切换到数据存放目录
cd /var/lib/pgsql/10/data/
#查看数据库当前状态
/usr/pgsql-10/bin/pg_controldata .
#根据当前状态删除无用wal
/usr/pgsql-10/bin/pg_archivecleanup -d pg_wal/ 00000001000000C30000006D
```
