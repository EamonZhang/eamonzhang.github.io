---
title: "Git 文件过大清理"
date: 2021-02-08T14:30:03+08:00
draft: false
---

git目录下object文件过大清理

一、删除仓库上的项目，重新提交代码。

二、彻底清除历史记录

```
查询大文件的文件名
git rev-list --objects --all | grep "$(git verify-pack -v .git/objects/pack/*.idx | sort -k 3 -n | tail -5 | awk '{print$1}')"
删除历史记录
git filter-branch --force --index-filter 'git rm -rf --cached --ignore-unmatch 你的大文件名' --prune-empty --tag-name-filter cat -- --all

rm -rf .git/refs/original/

git reflog expire --expire=now --all

git fsck --full --unreachable

git repack -A -d
本地空间变小
git gc --aggressive --prune=now
推送远端 ，本地远端空间都变小
git push --force
```

git 还是尽量不保存大文件，及时删除了遗留历史包袱。

