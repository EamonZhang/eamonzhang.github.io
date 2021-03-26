---
title: "Git 免输入密码"
date: 2020-03-19T15:10:15+08:00
draft: false
---

一、配置Git的

```
git config --global user.name [userName]

git config --global user.email [userEmail]
```

二、配置存储模式

```
git config --global credential.helper store
```

执行之后会在linux用户主目录下的.gitconfig文件中多加 helper = store

```
[user]
        name = eamonzhang
        email = xxxx@xxxx.com
[credential]
        helper = store
```

之后cd到项目目录，执行git pull命令，会提示输入账号密码。输完这一次以后就不再需要，并且会在根目录生成一个.git-credentials文件

三、注意事项

```
git config --global 全局设置生效

```
