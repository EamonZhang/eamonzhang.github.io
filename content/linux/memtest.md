---
title: "memtest 检测内存"
date: 2019-01-14T15:40:01+08:00
draft: false
---

```

NAME
       memtest-setup - Install Memtest86+ into your GRUB boot loader menu

SYNOPSIS
       memtest-setup [OPTIONS]

DESCRIPTION
       memtest-setup installs Memtest86+ into your GRUB boot loader menu. It supports both GRUB 2 and GRUB Legacy (i.e. GRUB 0.9x). In case of GRUB 2 it installs GRUB 2 template into /etc/grub.d and GRUB 2 config needs to be regenerated manually by running
       grub2-mkconfig -o /boot/grub2/grub.cfg under root.  This is not done automatically because it could overwrite any custom changes in /boot/grub2/grub.cfg.

OPTIONS
       -h, --help
              Shows help.

AUTHOR
       Jaroslav Škarvada <jskarvad@redhat.com>
           Manpage author.

COPYRIGHT
        Copyright © 2014 Jaroslav Škarvada

       Permission is granted to copy, distribute and/or modify this document under the terms of the GNU General Public License, Version 2 or (at your option) any later version published by the Free Software Foundation.

memtest-setup                                                                                                              Aug 26, 2014                                                                                                           MEMTEST-SETUP(8)
 Manual page memtest-setup(8) line 1/30 (END) (press h for help or q to quit)

```

#### 安装

```
yum install memtest+

memtest-setup 

grub2-mkconfig -o /boot/grub2/grub.cfg 
```

重新启动，在开机的时候选择 memtest+



