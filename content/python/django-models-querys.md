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
