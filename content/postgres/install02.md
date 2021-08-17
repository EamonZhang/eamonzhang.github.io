---
title: "数据库安装 Postgres12 Ubuntu18"
date: 2020-03-19T15:22:09+08:00
draft: false
---

软件源

```
echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" >> /etc/apt/sources.list.d/pgdg.list
```

```
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```

```
sudo apt-get update -y

```

安装 

```
apt-get install postgresql-12 postgresql-client-12 postgresql-12-postgis-2.5 postgresql-contrib -y

```

初始化

```
/usr/pgsql-12/bin/postgresql-12-setup initdb
```

启动

```
systemctl start postgresql
systemctl stop postgresql
systemctl status postgresql
systemctl enable postgresql
```

配置

```
cd /etc/postgresql/12/main/

vi postgres.conf

vi pg_hba.conf

```


