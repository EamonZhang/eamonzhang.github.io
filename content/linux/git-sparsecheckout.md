---
title: "Git 只下载指定文件或文件夹下的内容"
date: 2018-10-23T17:21:01+08:00
draft: false
---


#### 需求

　　有些时候我们只想下载项目中的部分文件或文件夹下面的内容，而不是整个项目。这个时候使用git clone难免有些过重。  
　　是时候来寻找一个合适的方式来满足我们的需求了。这就是Sparse Checkout模式


#### 具体方法

比如我只想下载 https://github.com/bodani/bodani.github.io.git 中的k8s 目录的内容  
```
mkdir gitSparse  
cd gitSparse  
git init  
git remote add -f origin https://github.com/bodani/bodani.github.io.git  
git config core.sparsecheckout true 
echo "k8s" >> .git/info/sparse-checkout  
git checkout master  
git pull 

```
　
