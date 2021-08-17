---
title: "Django CONN_MAX_AGE 对数据连接的影响"
date: 2021-04-20T13:27:13+08:00
draft: false
toc: false
categories: ["python","postgres" ]
tags: []
---
## Django的数据库连接

Django对数据库的链接处理是这样的，Django程序接受到请求之后，在第一访问数据库的时候会创建一个数据库连接,直到请求结束，关闭连接。下次请求也是如此。因此，这种情况下，随着访问的并发数越来越高，就会产生大量的数据库连接


## 使用CONN_MAX_AGE减少数据库请求

每次请求都会创建新的数据库连接，这对于高访问量的应用来说完全是不可接受的。因此在Django1.6时，提供了持久的数据库连接，通过DATABASE配置上添加CONN_MAX_AGE来控制每个连接的最大存活时间。

这个参数的原理就是在每次创建完数据库连接之后，把连接放到一个Theard.local的实例中。在request请求开始结束的时候，打算关闭连接时会判断是否超过CONN_MAX_AGE设置这个有效期。这是关闭。每次进行数据库请求的时候其实只是判断local中有没有已存在的连接，有则复用。

基于上述原因，Django中对于CONN_MAX_AGE的使用是有些限制的，使用不当，会事得其反。因为保存的连接是基于`线程局部变量`的，因此如果你部署方式采用多线程，必须要注意保证你的最大线程数不会多余数据库能支持的最大连接数。另外，如果使用开发模式运行程序（直接runserver的方式），建议不要设置CONN_MAX_AGE，因为这种情况下，每次请求都会创建一个Thread。同时如果你设置了CONN_MAX_AGE，将会导致你创建大量的不可复用的持久的连接。


## 生产系统中的实际应用

为什充分发挥应用在生成系统中的性能。采用nginx + gunicorn + django + gevent 的方式 。 利用协程的方式启动。 由于 CONN_MAX_AGE 是在` 线程级别 ` 共享。 协程方式启动没有效果，反而带来副作用。

## 解决 一 重新 DatabaseWrapper

```
DATABASES = { 
   'default': {
     'ENGINE': 'django.db.backends.mydb',

```

```
    def _close(self):
        if self.connection is not None:
            with self.wrap_database_errors:
                return self.connection.close()
```


https://github.com/jneight/django-db-geventpool
