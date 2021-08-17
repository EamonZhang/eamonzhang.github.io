---
title: "C 语言环境"
date: 2021-06-16T13:42:14+08:00
draft: false 
toc: false
categories: []
tags: []
---


## Centos7 cmake 版本升级（由 v2.8.12.2 升级至 v3.14.5）
```
#cmake -version
cmake version 2.8.12.2
```

安装基础工具
```
yum install -y gcc gcc-c++

mkdir /opt/cmake

cd /opt/cmake/

wget https://cmake.org/files/v3.14/cmake-3.14.5.tar.gz

tar zxvf cmake-3.14.5.tar.gz
```

安装
```
yum remove cmake -y

./configure --prefix=/usr/local/cmake

make && make install
```

查看版本
```
#/usr/local/cmake/bin/cmake --version
cmake version 3.14.5

CMake suite maintained and supported by Kitware (kitware.com/cmake).
```

设置环境
```
ln -s /usr/local/cmake/bin/cmake /usr/bin/cmake
```


## Clion 中使用MakeFile

默认在Clion中使用CMakeList.txt,但是有些项目提供的是Makefile


```
cmake_minimum_required(VERSION 3.12)
project(test)

set(CMAKE_CXX_STANDARD 11)
set(BUILD_DIR ${PROJECT_SOURCE_DIR})  #设置编译目录,也就是Makefile文件所在目录
message(${BUILD_DIR}) #打印目录路径
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
add_custom_target(test COMMAND make -C ${BUILD_DIR})
add_executable(start main.cpp)
```

## Clion 远程调试

https://haolaoshi.blog.csdn.net/article/details/107460448

## 编写 CMakeList.txt

CMakeLists.txt主要包含以上的7个步骤：
```
#1.cmake verson，指定cmake版本

cmake_minimum_required(VERSION 3.13)

#2.project name，指定项目的名称，一般和项目的文件夹名称FirstProject对应

PROJECT(FirstProject)

#3.head file path，头文件目录

INCLUDE_DIRECTORIES()

#4.source directory，源文件目录

AUX_SOURCE_DIRECTORY(src DIR_SRCS)

#5.set environment variable，设置环境变量，编译用到的源文件全部都要放到这里，否则编译能够通过，但是执行的时候会出现各种问题，比如"symbol lookup error xxxxx , undefined symbol"

SET(TEST_MATH)

#6.add executable file，添加要编译的可执行文件

ADD_EXECUTABLE(${PROJECT_NAME} ${TEST_MATH})

#7.add link library，添加可执行文件所需要的库（命名规则：lib+name+.so）,就添加该库的名称

TARGET_LINK_LIBRARIES(${PROJECT_NAME} m)
```
## 一个例子

```
#指定CMake编译最低要求版本
cmake_minimum_required(VERSION 3.14)
#给项目命名
project(iniTest)

set(CMAKE_CXX_STANDARD 14)
SET(SOURCE ${PROJECT_SOURCE_DIR}/iniTest.cpp)
#指定头文件目录
#INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/public)
#INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR}/utils)
#INCLUDE_DIRECTORIES(${PROJECT_SOURCE_DIR})
#源文件
#AUX_SOURCE_DIRECTORY(${PROJECT_SOURCE_DIR} DIR_SRCS)
#AUX_SOURCE_DIRECTORY(${PROJECT_SOURCE_DIR}/public DIR_PUB)
AUX_SOURCE_DIRECTORY(${PROJECT_SOURCE_DIR}/utils DIR_UTILS)
#指定生成库文件的目录
SET(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)

#将iniTest.cpp生成可执行文件iniTest
ADD_EXECUTABLE(iniTest ${SOURCE} ${DIR_PUB} ${DIR_UTILS})

#指定链接库文件目录
#LINK_DIRECTORIES(/usr/lib)
#指定iniTest 链接库recognizer
TARGET_LINK_LIBRARIES(iniTest recognizer)
TARGET_LINK_LIBRARIES(iniTest pthread)

```

## 编译安装过程

```
./configure
make
make install
```

```
1.配置

configure 脚本负责在你使用的系统上准备好软件的构建环境。确保接下来的构建和安装过程所需要的依赖准备好，并且搞清楚使用这些依赖需要的东西。

Unix 程序一般是用 C 语言写的，所以我们通常需要一个 C 编译器去构建它们。在这个例子中 configure 要做的就是确保系统中有 C 编译器，并确定它的名字和路径。

2. 构建

当 configure 配置完毕后，可以使用 make 命令执行构建。这个过程会执行在 Makefile 文件中定义的一系列任务将软件源代码编译成可执行文件。

你下载的源码包一般没有一个最终的 Makefile 文件，一般是一个模版文件 Makefile.in 文件，然后 configure 根据系统的参数生成一个定制化的 Makefile 文件。

3. 安装

现在软件已经被构建好并且可以执行，接下来要做的就是将可执行文件复制到最终的路径。make install 命令就是将可执行文件、第三方依赖包和文档复制到正确的路径。

这通常意味着，可执行文件被复制到某个 PATH 包含的路径，程序的调用文档被复制到某个 MANPATH 包含的路径，还有程序依赖的文件也会被存放在合适的路径。

因为安装这一步也是被定义在 Makefile 中，所以程序安装的路径可以通过 configure 命令的参数指定，或者 configure 通过系统参数决定。

如果要将可执行文件安装在系统路径，执行这步需要赋予相应的权限，一般是通过 sudo。

```
