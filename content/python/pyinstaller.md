---
title: "Python PyInstaller 生成可执行文件"
date: 2021-04-14T09:55:57+08:00
draft: false
toc: false
categories: ["python"]
tags: []
---

## Python PyInstaller

Python 默认并不包含 PyInstaller 模块，因此需要自行安装 PyInstaller 模块。

```
pip3 install pyinstaller
```

## PyInstaller生成可执行程序

```
pyinstaller 选项 Python源文件
```

app.py
```
print('hello everyone')
```

生成独立的可执行文件，包含可依赖
```
pyinstaller -F app.py
```

生成如下目录结构
```
.
├── app.py
├── app.spec
├── build
│   └── app
│       ├── Analysis-00.toc
│       ├── base_library.zip
│       ├── EXE-00.toc
│       ├── PKG-00.pkg
│       ├── PKG-00.toc
│       ├── PYZ-00.pyz
│       ├── PYZ-00.toc
│       ├── warn-app.txt
│       └── xref-app.html
├── dist
│   └── app
└── __pycache__
    └── app.cpython-36.pyc

```

## 执行文件
```
# dist/app 
hello everyone
```
