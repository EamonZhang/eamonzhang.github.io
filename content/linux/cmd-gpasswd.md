---
title: "gpasswd 命令"
date: 2018-10-18T09:52:03+08:00
draft: false
---

### gpasswd 命令详解 

1. gpasswd命令是Linux下工作组文件/etc/group和/etc/gshadow的管理工具，用于指定要管理的工作组。

2. 选项详解：

      -a : 添加用户到组

      -d : 从组删除用户

      -A：指定管理员

      -M：指定组成员和-A的用途差不多；

      -r：删除密码；

      -R：限制用户登入组，只有组中的成员才可以用newgrp加入该组。

3. 实例：

　　3.1 将userA添加到groupB用户组里面：  

      gpasswd -a userA groupB 

　
    　注意：添加用户到某一个组可以使用  usermod -G groupB userA 这个命令可以添加一个用户到指定的组，但是以前添加的组就会清空掉, 所以想要添加一个用户到一个组，同时保留以前添加的组时，

            请使用gpasswd这个命令来添加操作用户。


　　3.2 将userA设置为groupA的群组管理员：

      gpasswd -A userA groupA
