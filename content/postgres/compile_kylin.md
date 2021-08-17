---
title: "kylin系统postgresql编译安装"
date: 2020-11-16T15:26:59+08:00
draft: false
---

#### 背景

麒麟系统默认自带postgresql10.5

安装过程与centos基本相同 ,

注意事项 

1 安装postgresql-dev 

2 编译 postgis 时./configure --with-pgconfig=/usr/bin/pg_config 

但是如果想安装其他版本的postgres 需一番周折

首先第一个问题麒麟系统对openssl过进行改造。在编译postgres支持ssl时不能通过。

其次安装postgres其他拓展也需要解决好各个安装包之间的依赖关系。编译的过程也比较漫长。

#### 银河麒麟V10编译安装postgresql12.5

###### 安装openssl

麒麟v10 版操作系统openssl 被指定义安装在内核中。在安装postgresql时支持openssl编译不能通过。

解决思路，独立安装openssl,postgres对ssl 的依赖指向独立安装的openssl


```
查看原有版本
openssl version

下载并安装对应版本的openssl
wget https://www.openssl.org/source/openssl-1.1.1d.tar.gz
tar -zxf openssl-1.1.1d.tar.gz 
cd openssl-1.1.1d/
./config --prefix=/usr/local/openssl no-zlib 
```

###### 依赖包安装
```
yum install openldap-devel
yum install systemd-devel -y

```

###### 安装postgres

```
tar -zxf postgresql-12.5.tar.gz 

指定openssl 路径
./configure --with-openssl --with-includes=/usr/local/openssl/include/openssl --with-libraries=/usr/local/openssl/lib/ --with-systemd

./configure '--enable-rpath' '--prefix=/usr/pgsql-12' '--includedir=/usr/pgsql-12/include' '--libdir=/usr/pgsql-12/lib' '--mandir=/usr/pgsql-12/share/man' '--datadir=/usr/pgsql-12/share' '--with-icu' '--with-llvm' '--with-perl' '--with-python' '--with-tcl' '--with-tclconfig=/usr/lib64' '--with-openssl' '--with-pam' '--with-gssapi' '--with-includes=/usr/include:/usr/local/openssl/include/openssl' '--with-libraries=/usr/lib64:/usr/local/openssl/lib' '--enable-nls' '--enable-dtrace' '--with-uuid=e2fs' '--with-libxml' '--with-libxslt' '--with-ldap' '--with-selinux' '--with-systemd' '--with-system-tzdata=/usr/share/zoneinfo' '--sysconfdir=/etc/sysconfig/pgsql' '--docdir=/usr/pgsql-12/doc' '--htmldir=/usr/pgsql-12/doc/html' 'CFLAGS=-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' 'LDFLAGS=-Wl,--as-needed' 'LLVM_CONFIG=/usr/lib64/llvm5.0/bin/llvm-config' 'CLANG=/opt/rh/llvm-toolset-7/root/usr/bin/clang' 'PKG_CONFIG_PATH=:/usr/lib64/pkgconfig:/usr/share/pkgconfig' 'PYTHON=/usr/bin/python2'

./configure '--enable-rpath' '--prefix=/usr/pgsql-12' '--includedir=/usr/pgsql-12/include' '--libdir=/usr/pgsql-12/lib' '--mandir=/usr/pgsql-12/share/man' '--datadir=/usr/pgsql-12/share'  '--with-perl' '--with-python' '--with-openssl' '--with-pam' '--with-gssapi' '--with-includes=/usr/include:/usr/local/openssl/include/openssl' '--with-libraries=/usr/lib64:/usr/local/openssl/lib' '--enable-nls' '--enable-dtrace' '--with-uuid=e2fs' '--with-ldap' '--with-selinux' '--with-systemd' '--with-system-tzdata=/usr/share/zoneinfo' 
```

##### 安装postgis
```
http://postgis.net/source/  

You will also need to install and/or build GEOS, Proj, GDAL, LibXML2 and JSON-C.
```
yum install libxml2 libxml2-devel.aarch64 
yum install proj-devel
yum install sqlite
yum install sqlite-devel.aarch64  -y
yum install curl-devel

make proj-6

yum erase proj # 将原来系统自带的删除
```

```
gdal-3.1.4
```
wget http://download.osgeo.org/geos/geos-3.8.1.tar.bz2
tar -jxf geos-3.8.1.tar.bz2
cd geos-3.8.1
make
make install
```


wget https://download.osgeo.org/postgis/source/postgis-3.0.2.tar.gz

./configure --with-pgconfig=/usr/pgsql-12/bin/pg_config --with-geosconfig=/usr/local/bin/geos-config


```
-------------- Dependencies -------------- 
  GEOS config:          /usr/local/bin/geos-config
  GEOS version:         3.8.1
  GDAL config:          /usr/local/bin/gdal-config
  GDAL version:         3.1.4
  PostgreSQL config:    /usr/pgsql-12/bin/pg_config
  PostgreSQL version:   PostgreSQL 12.5
  PROJ4 version:        63
  Libxml2 config:       /usr/bin/xml2-config
  Libxml2 version:      2.9.8
  JSON-C support:       no
  protobuf support:     no
  PCRE support:         yes
  Perl:                 /usr/bin/perl
  Wagyu:                no

```

问题

```
ldd /usr/pgsql-12/lib/postgis-3.so
	linux-vdso.so.1 (0x0000fffdf6fa0000)
	libgeos_c.so.1 => not found
	libproj.so.15 => not found
	libxml2.so.2 => /lib64/libxml2.so.2 (0x0000fffdf6cc0000)
	libz.so.1 => /lib64/libz.so.1 (0x0000fffdf6c80000)
	liblzma.so.5 => /lib64/liblzma.so.5 (0x0000fffdf6c30000)
	libm.so.6 => /lib64/libm.so.6 (0x0000fffdf6b60000)
	libdl.so.2 => /lib64/libdl.so.2 (0x0000fffdf6b30000)
	libc.so.6 => /lib64/libc.so.6 (0x0000fffdf69a0000)
	/lib/ld-linux-aarch64.so.1 (0x0000fffdf6fb0000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x0000fffdf6960000)
```

解决

```
#新建文件
vi /etc/ld.so.conf.d/postgis.conf
#添加
/usr/local/lib
生效
ldconfig 
```

查看
```
ldd /usr/pgsql-12/lib/postgis-3.so
	linux-vdso.so.1 (0x0000fffdd96a0000)
	libgeos_c.so.1 => /usr/local/lib/libgeos_c.so.1 (0x0000fffdd94f0000)
	libproj.so.15 => /usr/local/lib/libproj.so.15 (0x0000fffdd9230000)
	libxml2.so.2 => /lib64/libxml2.so.2 (0x0000fffdd90a0000)
	libz.so.1 => /lib64/libz.so.1 (0x0000fffdd9060000)
	liblzma.so.5 => /lib64/liblzma.so.5 (0x0000fffdd9010000)
	libm.so.6 => /lib64/libm.so.6 (0x0000fffdd8f40000)
	libdl.so.2 => /lib64/libdl.so.2 (0x0000fffdd8f10000)
	libc.so.6 => /lib64/libc.so.6 (0x0000fffdd8d80000)
	libgeos-3.8.1.so => /usr/local/lib/libgeos-3.8.1.so (0x0000fffdd8b90000)
	libstdc++.so.6 => /lib64/libstdc++.so.6 (0x0000fffdd89e0000)
	libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x0000fffdd89a0000)
	libsqlite3.so.0 => /lib64/libsqlite3.so.0 (0x0000fffdd8870000)
	libpthread.so.0 => /lib64/libpthread.so.0 (0x0000fffdd8830000)
	/lib/ld-linux-aarch64.so.1 (0x0000fffdd96b0000)
```

##### pipelinedb

编译安装zeromq
```
#!/bin/bash                                                                       
      
  
      # pkg-config may not be necessary to install on all systems  
      sudo apt-get install -y wget libtool autoconf automake pkg-config  
      
  
      wget https://github.com/zeromq/libzmq/releases/download/v4.2.5/zeromq-4.2.5.tar.gz && \  
          tar -xvf zeromq-4.2.5.tar.gz && \  
          cd zeromq-4.2.5/ && \  
          ./autogen.sh && \  
          ./configure CPPFLAGS=-DPIC CFLAGS=-fPIC CXXFLAGS=-fPIC LDFLAGS=-fPIC --prefix=/usr && \  
          make && \  
          make install
```
