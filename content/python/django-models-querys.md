---
title: "Django Models Querys"
date: 2021-04-14T15:12:03+08:00
draft: false
toc: false
categories: ["python"]
tags: []
---
SELECT id FROM users WHERE username='test'
User.objects.only('id').get(username=xxx)

https://mp.weixin.qq.com/s?__biz=MzU5MDY1MzcyOQ==&mid=2247483770&idx=1&sn=ea1e4f5c4abac3a61687971cd413bf3e&chksm=fe3bb134c94c3822d669400fb0f481e058bd2f65eb3e11904dce5435a1bb73d1f9e7b9598b0a&cur_album_id=1365834140322578434&scene=189#rd
