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

带来问题
```
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8188cf9>] schedule_preempt_disabled+0x29/0x70
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8186c67>] __mutex_lock_slowpath+0xc7/0x1d0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa818603f>] mutex_lock+0x1f/0x2f
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7d2d596>] ima_file_check+0xa6/0x1b0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c5dfba>] do_last+0x59a/0x1340
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c28ba6>] ? kmem_cache_alloc_trace+0x1d6/0x200
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c5ee2d>] path_openat+0xcd/0x5a0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c01158>] ? page_add_new_anon_rmap+0xb8/0x170
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c6107d>] do_filp_open+0x4d/0xb0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c6f177>] ? __alloc_fd+0x47/0x170
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c4cbc4>] do_sys_open+0x124/0x220
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c4ccde>] SyS_open+0x1e/0x20
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8194f92>] system_call_fastpath+0x25/0x2a
[Tue Mar 30 12:19:12 2021] INFO: task postmaster:119438 blocked for more than 120 seconds.
[Tue Mar 30 12:19:12 2021] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[Tue Mar 30 12:19:12 2021] postmaster      D ffff9180ced1acc0     0 119438  40020 0x00000084
[Tue Mar 30 12:19:12 2021] Call Trace:
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8188cf9>] schedule_preempt_disabled+0x29/0x70
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8186c67>] __mutex_lock_slowpath+0xc7/0x1d0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa818603f>] mutex_lock+0x1f/0x2f
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7d2d596>] ima_file_check+0xa6/0x1b0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c5dfba>] do_last+0x59a/0x1340
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c28ba6>] ? kmem_cache_alloc_trace+0x1d6/0x200
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c5ee2d>] path_openat+0xcd/0x5a0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7bee659>] ? do_read_fault.isra.63+0x139/0x1b0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c6107d>] do_filp_open+0x4d/0xb0
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c6f177>] ? __alloc_fd+0x47/0x170
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c4cbc4>] do_sys_open+0x124/0x220
[Tue Mar 30 12:19:12 2021]  [<ffffffffa7c4ccde>] SyS_open+0x1e/0x20
[Tue Mar 30 12:19:12 2021]  [<ffffffffa8194f92>] system_call_fastpath+0x25/0x2a
```

由于是硬盘与主板之间的通信问题，操作系统和内核层面的解决不能治根。

最后解决

```
 螺丝刀
```
