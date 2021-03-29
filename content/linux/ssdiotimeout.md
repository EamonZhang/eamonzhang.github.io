---
title: "SSD IO request Time Out"
date: 2021-03-29T09:30:42+08:00
draft: false
toc: false
categories: ["linux"]
---

![images](/images/pcie_error_timeout.jpg)

Intel 论坛相似问题讨论

https://community.intel.com/t5/Solid-State-Drives/I-O-request-timeouts-on-Linux-with-Intel-P3520-P4600-NVMe-PCIe/td-p/577474

临时解决
```
 mkfs.xfs -K /dev/nvme01

 -K     Do not attempt to discard blocks at mkfs time.
```
