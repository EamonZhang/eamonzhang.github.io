---
title: "iptables查看、添加、删除规则"
date: 2019-02-25T17:23:44+08:00
draft: false
---

#### 查看
iptables -nvL –line-number

-L 查看当前表的所有规则，默认查看的是filter表，如果要查看NAT表，可以加上-t NAT参数  
-n 不对ip地址进行反查，加上这个参数显示速度会快很多  
-v 输出详细信息，包含通过该规则的数据包数量，总字节数及相应的网络接口  
–line-number 显示规则的序列号，这个参数在删除或修改规则时会用到  

#### 添加
添加规则有两个参数：-A和-I。其中-A是添加到规则的末尾；-I可以插入到指定位置，没有指定位置的话默认插入到规则的首部。

```
当前规则：
[root@test ~]# iptables -nL --line-number
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    DROP       all  --  192.168.1.1          0.0.0.0/0
2    DROP       all  --  192.168.1.2          0.0.0.0/0
3    DROP       all  --  192.168.1.4          0.0.0.0/0
添加一条规则到尾部：
[root@test ~]# iptables -A INPUT -s 192.168.1.5 -j DROP
再插入一条规则到第三行，将行数直接写到规则链的后面：
[root@test ~]# iptables -I INPUT 3 -s 192.168.1.3 -j DROP
查看：
[root@test ~]# iptables -nL --line-number
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    DROP       all  --  192.168.1.1          0.0.0.0/0
2    DROP       all  --  192.168.1.2          0.0.0.0/0
3    DROP       all  --  192.168.1.3          0.0.0.0/0
4    DROP       all  --  192.168.1.4          0.0.0.0/0
5    DROP       all  --  192.168.1.5          0.0.0.0/0
可以看到192.168.1.3插入到第三行，而原来的第三行192.168.1.4变成了第四行。
```

#### 删除

删除用-D参数

```
删除之前添加的规则（iptables -A INPUT -s 192.168.1.5 -j DROP）：
[root@test ~]# iptables -D INPUT -s 192.168.1.5 -j DROP
有时候要删除的规则太长，删除时要写一大串，既浪费时间又容易写错，这时我们可以先使用–line-number找出该条规则的行号，再通过行号删除规则。

[root@test ~]# iptables -nv --line-number
iptables v1.4.7: no command specified
Try `iptables -h' or 'iptables --help' for more information.
[root@test ~]# iptables -nL --line-number
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    DROP       all  --  192.168.1.1          0.0.0.0/0
2    DROP       all  --  192.168.1.2          0.0.0.0/0
3    DROP       all  --  192.168.1.3          0.0.0.0/0
删除第二行规则

[root@test ~]# iptables -D INPUT 2
```
#### 修改

修改使用-R参数
```
先看下当前规则：

[root@test ~]# iptables -nL --line-number
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    DROP       all  --  192.168.1.1          0.0.0.0/0
2    DROP       all  --  192.168.1.2          0.0.0.0/0
3    DROP       all  --  192.168.1.5          0.0.0.0/0
将第三条规则改为ACCEPT：

[root@test ~]# iptables -R INPUT 3 -j ACCEPT
再查看下：

[root@test ~]# iptables -nL --line-number
Chain INPUT (policy ACCEPT)
num  target     prot opt source               destination
1    DROP       all  --  192.168.1.1          0.0.0.0/0
2    DROP       all  --  192.168.1.2          0.0.0.0/0
3    ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0
第三条规则的target已改为ACCEPT。
```
