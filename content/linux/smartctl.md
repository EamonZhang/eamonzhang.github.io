---
title: "smartctl 硬盘检测"
date: 2018-12-03T14:21:00+08:00
draft: false
---
##### SMART 简介

S.M.A.R.T.，全称为“Self-Monitoring Analysis and Reporting Technology”，即“自我监测、分析及报告技术”。是一种自动的硬盘状态检测与预警系统和规范。通过在硬盘硬件内的检测指令对硬盘的硬件如磁头、盘片、马达、电路的运行情况进行监控、记录并与厂商所设定的预设安全值进行比较，若监控情况将或已超出预设安全值的安全范围，就可以通过主机的监控硬件或软件自动向用户作出警告并进行轻微的自动修复，以提前保障硬盘数据的安全。除一些出厂时间极早的硬盘外，现在大部分硬盘均配备该项技术。

SMART是一种磁盘自我分析检测技术，早在90年代末就基本得到了普及每一块硬盘(包括IDE、SCSI)在运行的时候，都会将自身的若干参数记录下来这些参数包括型号、容量、温度、密度、扇区、寻道时间、传输、误码率等，当硬盘运行了几千小时后，很多内在的物理参数都会发生变化某一参数超过报警阈值，则说明硬盘接近损坏，此时硬盘依然在工作，如果用户不理睬这个报警继续使用那么硬盘将变得非常不可靠，随时可能故障导致数据丢失。


#### SMART 安装

```
yum install smartmontools.x86_64 -y
```

#### 基本用法

```
smartctl --scan 扫描当前系统中所有支持SMART的设备

smartctl -i /dev/sda 查看设备SMART是否开启

smartctl -s on /dev/sda 将设备SMART开启

smartctl -a /dev/sda 仅显示设备的所有 SMART 属性信息

smartctl -x /dev/sda 显示设备的所有属性信息

smartctl -H /dev/sda 查看设备的自检评估结果

smartctl -a  <device>  检查该设备是否已经打开SMART技术。

smartctl -s on <device>   如果没有打开SMART技术，使用该命令打开SMART技术。

smartctl -t short <device> 后台检测硬盘，消耗时间短。

smartctl -t long <device>  后台检测硬盘，消耗时间长。

smartctl -C -t short <device> 前台检测硬盘，消耗时间短。

smartctl -C -t long <device>  前台检测硬盘，消耗时间长。其实就是利用硬盘SMART的自检程序。

smartctl -X <device>  中断后台检测硬盘。

smartctl -l selftest <device>  显示硬盘检测日志。

smartctl -l error <device> 显示硬盘错误汇总。
```

硬盘信息
```
$smartctl -i /dev/sda
smartctl 6.5 2016-05-07 r4318 [x86_64-linux-3.10.0-862.14.4.el7.x86_64] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     INTEL SSDSC2KW512G8
Serial Number:    BTLA814005E0512DGN
LU WWN Device Id: 5 5cd2e4 14f53228a
Firmware Version: LHF002C
User Capacity:    512,110,190,592 bytes [512 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-3 (minor revision not indicated)
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Mon Dec  3 14:25:44 2018 CST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
```
如果看到SMART support is: Disabled，则表示SMART未启用
```
smartctl --smart=on --offlineauto=on --saveauto=on /dev/hd
```

健康状况
```
$smartctl --health /dev/sda
smartctl 6.5 2016-05-07 r4318 [x86_64-linux-3.10.0-862.14.4.el7.x86_64] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED
```
PASSED，这表示硬盘健康状态良好，如果这里显示Failure，那么最好立刻给服务器更换硬盘。


所有信息
```
$smartctl --all /dev/sda
smartctl 6.5 2016-05-07 r4318 [x86_64-linux-3.10.0-862.14.4.el7.x86_64] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     INTEL SSDSC2KW256G8
Serial Number:    PHLA821605MC256CGN
LU WWN Device Id: 5 5cd2e4 14f882e66
Firmware Version: LHF002C
User Capacity:    256,060,514,304 bytes [256 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-3 (minor revision not indicated)
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Mon Dec  3 14:27:18 2018 CST
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00)	Offline data collection activity
					was never started.
					Auto Offline Data Collection: Disabled.
Self-test execution status:      (   0)	The previous self-test routine completed
					without error or no self-test has ever 
					been run.
Total time to complete Offline 
data collection: 		(    0) seconds.
Offline data collection
capabilities: 			 (0x53) SMART execute Offline immediate.
					Auto Offline data collection on/off support.
					Suspend Offline collection upon new
					command.
					No Offline surface scan supported.
					Self-test supported.
					No Conveyance Self-test supported.
					Selective Self-test supported.
SMART capabilities:            (0x0003)	Saves SMART data before entering
					power-saving mode.
					Supports SMART auto save timer.
Error logging capability:        (0x01)	Error logging supported.
					General Purpose Logging supported.
Short self-test routine 
recommended polling time: 	 (   2) minutes.
Extended self-test routine
recommended polling time: 	 (  15) minutes.
SCT capabilities: 	       (0x003d)	SCT Status supported.
					SCT Error Recovery Control supported.
					SCT Feature Control supported.
					SCT Data Table supported.

SMART Attributes Data Structure revision number: 1
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  5 Reallocated_Sector_Ct   0x0032   100   100   000    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   100   100   000    Old_age   Always       -       4
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       4
170 Unknown_Attribute       0x0033   100   100   010    Pre-fail  Always       -       0
171 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
172 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
173 Unknown_Attribute       0x0033   100   100   005    Pre-fail  Always       -       65536
174 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       2
183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
184 End-to-End_Error        0x0033   100   100   090    Pre-fail  Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0032   020   026   000    Old_age   Always       -       20 (Min/Max 19/26)
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       2
199 UDMA_CRC_Error_Count    0x0032   100   100   000    Old_age   Always       -       0
225 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       95
226 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       0
227 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       0
228 Power-off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       0
232 Available_Reservd_Space 0x0033   100   100   010    Pre-fail  Always       -       0
233 Media_Wearout_Indicator 0x0032   100   100   000    Old_age   Always       -       0
236 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
241 Total_LBAs_Written      0x0032   100   100   000    Old_age   Always       -       95
242 Total_LBAs_Read         0x0032   100   100   000    Old_age   Always       -       22
249 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       2
252 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
No self-tests have been logged.  [To run self-tests, use: smartctl -t]

SMART Selective self-test log data structure revision number 1
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.

```
各项 SMART 属性

ID 属性编号， 从1到255

ATTRIBUTE_NAME 属性名称

FLAGS 标识，K 自动保持 ,C 事件统计, R 错误率, S速度/性能 , O 在线更新, P 故障预警

VALUE 当前Normalized value, 取值范围1到253. 越低表示越差. 越高表示越好

WORST 历史最差值，表示SMART开启以来的, 所有Normalized values的最低值

THRESH 阈值/极限值，当Normalized value小于等于THRESH值时, 表示这项指标已经failed了.

FAIL 已经失效.

RAW_VALUE 物理值(通常对应于计数或物理单位，如扇区个数，摄氏度或秒)

TYPE (简要模式不可见)存在两种类型, Pre-failed(故障预警)和Old_age(正常损耗).

UPDATED (简要模式不可见)存在两种更新模式 Always(持续更新)和 Offline(离线更新)

#### 已使用寿命参考

Percentage Used Endurance Indicator
``
smartctl -l devstat /dev/sdb
smartctl 7.0 2018-12-30 r4883 [x86_64-linux-3.10.0-957.10.1.el7.x86_64] (local build)
Copyright (C) 2002-18, Bruce Allen, Christian Franke, www.smartmontools.org

Device Statistics (GP Log 0x04)
Page  Offset Size        Value Flags Description
0x01  =====  =               =  ===  == General Statistics (rev 1) ==
0x01  0x008  4              26  ---  Lifetime Power-On Resets
0x01  0x010  4           15617  ---  Power-on Hours
0x01  0x018  6      3482676599  ---  Logical Sectors Written
0x01  0x020  6        71733219  ---  Number of Write Commands
0x01  0x028  6      2754401909  ---  Logical Sectors Read
0x01  0x030  6        16315927  ---  Number of Read Commands
0x07  =====  =               =  ===  == Solid State Device Statistics (rev 1) ==
0x07  0x008  1               8  ---  Percentage Used Endurance Indicator
                                |||_ C monitored condition met
                                ||__ D supports DSN
                                |___ N normalized value
```

#### TODO Smartd 服务

```
systemctl status smartd
```

配置　

vi /etc/smartmontools/smartd.conf


集成监控 [smartctl_exporter](https://github.com/Sheridan/smartctl_exporter)
