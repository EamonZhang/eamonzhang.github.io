---
title: "python 与 C 交互编程"
date: 2021-05-28T15:44:19+08:00
draft: false
toc: false
categories: ['python']
tags: []
---

## python 访问C 动态库

很多核心的算法库都是C/C++写的,成果物通常以动态库的方式对外提供。

如何利用python访问动态代码库



## python访问C/C++的方式

- ctypes
- pybind11
- cffi
- swig

## ctypes的优势
 
- 不要修改动态库的源码
- 只需要动态库和头文件
- 使用比较简单,而且目前大部分库都是兼容C/C++

 参考

https://www.cnblogs.com/gaowengang/p/7919219.html
