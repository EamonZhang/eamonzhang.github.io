---
title: "使用setup打包"
date: 2021-04-16T17:17:12+08:00
draft: false
toc: false
categories: ["python"]
tags: []
---

## 使用setup 对python进行打包

 将python打包后可在其他项目中直接引用

```
pip install ***
```

## 具体步骤

1 将代码复制到一个新的文件夹下

2 创建README.rst

3 创建 LICENSE

4 编写 setup.py setup.cfg

setup.cfg
```
[metadata]
name = django-polls
version = 0.1
description = A Django app to conduct Web-based polls.
long_description = file: README.rst
url = https://www.example.com/
author = Your Name
author_email = yourname@example.com
license = BSD-3-Clause  # Example license
classifiers =
    Environment :: Web Environment
    Framework :: Django
    Framework :: Django :: X.Y  # Replace "X.Y" as appropriate
    Intended Audience :: Developers
    License :: OSI Approved :: BSD License
    Operating System :: OS Independent
    Programming Language :: Python
    Programming Language :: Python :: 3
    Programming Language :: Python :: 3 :: Only
    Programming Language :: Python :: 3.6
    Programming Language :: Python :: 3.7
    Programming Language :: Python :: 3.8
    Topic :: Internet :: WWW/HTTP
    Topic :: Internet :: WWW/HTTP :: Dynamic Content

[options]
include_package_data = true
packages = find:
python_requires = >=3.6
install_requires =
    Django >= X.Y  # Replace "X.Y" as appropriate
```

setup.py
```
from setuptools import setup

setup()

```

5 默认只打包 .python 内容。 将其他类型文件打包

 编写 MANIFEST.in
```
include LICENSE
include README.rst
recursive-include polls/static *
recursive-include polls/templates *
```

6 打包命令

```
python setup.py sdist
```

7 使用

本地
```
python -m pip install --user django-polls/dist/django-polls-0.1.tar.gz

python -m pip uninstall django-polls
```

全程仓库 如推送

pypi
