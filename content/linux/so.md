---
title: "动态库"
date: 2021-06-01T18:47:22+08:00
draft: false
toc: false
categories: []
tags: []
---

## centos中运行程序出现'GLIBCXX_3.4.21' not found

查看动态库依赖
```
#ldd ./**.so

**.so: /lib64/libstdc++.so.6: version `GLIBCXX_3.4.20' not found
```
```
#strings /usr/lib64/libstdc++.so.6 |grep ^GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_DEBUG_MESSAGE_LENGTH
```

centos7 中的gcc 版本太老，需要升级


## gcc 升级
centos7 中的gcc 版本太老，需要升级

```
yum groupinstall "Development Tools"
yum install glibc-static libstdc++-static
```

下载gcc

http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/

安装
```
tar -xvf gcc-5.4.0.tar.bz2
cd gcc-5.4.0
./contrib/download_prerequisits
mkdir build
cd build
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib
make && make install
```

/usr/lib64/libstdc++.so.6 是软连接。重新指定到最新版本

查看
```
#strings /usr/lib64/libstdc++.so.6 |grep ^GLIBCXX
GLIBCXX_3.4
GLIBCXX_3.4.1
GLIBCXX_3.4.2
GLIBCXX_3.4.3
GLIBCXX_3.4.4
GLIBCXX_3.4.5
GLIBCXX_3.4.6
GLIBCXX_3.4.7
GLIBCXX_3.4.8
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.11
GLIBCXX_3.4.12
GLIBCXX_3.4.13
GLIBCXX_3.4.14
GLIBCXX_3.4.15
GLIBCXX_3.4.16
GLIBCXX_3.4.17
GLIBCXX_3.4.18
GLIBCXX_3.4.19
GLIBCXX_3.4.20
GLIBCXX_3.4.21
GLIBCXX_DEBUG_MESSAGE_LENGTH
GLIBCXX_3.4.21
GLIBCXX_3.4.9
GLIBCXX_3.4.10
GLIBCXX_3.4.16
GLIBCXX_3.4.1
GLIBCXX_3.4.20
GLIBCXX_3.4.12
GLIBCXX_3.4.2
GLIBCXX_3.4.6
GLIBCXX_3.4.15
GLIBCXX_3.4.19
GLIBCXX_3.4.3
GLIBCXX_3.4.7
GLIBCXX_3.4.18
GLIBCXX_3.4.8
GLIBCXX_3.4.13
GLIBCXX_3.4.17
GLIBCXX_3.4.4
```
