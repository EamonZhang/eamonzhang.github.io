---
title: "ln -s 建立软连接"
date: 2018-12-19T09:19:19+08:00
draft: false
---

#### 创建软连接

类似于windows中的创建快捷方式

ln -s source target

具体方法举例

需求

数据库的数据实际存放位置为 /data/pgsql/10/data/     
数据库的应用访问地址为 /var/lib/pgsql/10/data/   

创建软连接

1  切换目录到需要创建快捷方式的文件目录
```
cd /var/lib/pgsql/10/
```
2.1  创建软连接
```
ln -s /data/pgsql/10/data/ data
```

2.2 删除软连接

```
rm data
``` 

删除软连接和数据

```
rm data/
```

3  权限和所有者  

```
chmod  

chown 
```

修改软连接的所用者 使用 -h 参数 

```
chown -h postgres:postgres data/
```
