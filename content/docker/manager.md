---
title: "docker 磁盘空间管理"
date: 2019-03-18T08:58:07+08:00
draft: false
---

##### 查看docker占用的空间情况

```
# docker system df 
TYPE                TOTAL               ACTIVE              SIZE                RECLAIMABLE
Images              58                  36                  6.091GB             2.119GB (34%)
Containers          90                  89                  232.3MB             0B (0%)
Local Volumes       137                 16                  232.7MB             194.2MB (83%)
Build Cache         0                   0                   0B                  0B

```
四大资源尽收眼底，可回收多少资源也了然于胸

##### 清除不在需要的资源

```
This will remove:
        - all stopped containers
        - all networks not used by at least one container
        - all dangling images
        - all build cach

# docker system prune  -f
```
清除一切非活跃状态，将资源还给系统

##### 清除volume

```
查看
# docker volume ls

清除
# docker volume prune -f
```
