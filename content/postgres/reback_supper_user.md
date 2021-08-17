---
title: "找回supper user 权限"
date: 2020-12-22T17:12:53+08:00
draft: false
---

##### 背景

意外删除postgres supper user 权限 

##### 找回方法

关闭数据库 用单用户模式重新启动
```
/usr/lib/postgresql/xxxx/bin/postgres --single -D $PGDATA

```

重新设置supper user 权限
```
alter user postgres with superuser;
```
