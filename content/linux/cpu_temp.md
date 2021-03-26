---
title: "Linux 获取CPU温度"
date: 2020-05-07T14:02:02+08:00
draft: false
---

#### 直接读取系统信息
可以通过读取如下路径中的数据来获取cpu的温度信息，不过读取的数据没有经过处理。

```
cpu0：
cat /sys/class/thermal/thermal_zone0/temp
cpu1：
cat /sys/class/thermal/thermal_zone1/temp
```

#### 通过命令行的方式获取
安装 lm_sensors 软件包：

```
# rpm
yum install lm_sensors
```

```
# deb
apt-get install lm-sensors
```

执行命令sensors-detect，进行简单配置，此命令执行后会出现一系列选项，一直yes即可；

执行命令sensors，查看cpu的温度。

sensors
i350bb-pci-0200
Adapter: PCI adapter
loc1:         +42.0°C  (high = +120.0°C, crit = +110.0°C)

i350bb-pci-0300
Adapter: PCI adapter
loc1:         +38.0°C  (high = +120.0°C, crit = +110.0°C)

power_meter-acpi-0
Adapter: ACPI interface
power1:        4.29 MW (interval =   1.00 s)

coretemp-isa-0000
Adapter: ISA adapter
Physical id 0:  +31.0°C  (high = +85.0°C, crit = +95.0°C)
Core 0:         +26.0°C  (high = +85.0°C, crit = +95.0°C)
Core 1:         +28.0°C  (high = +85.0°C, crit = +95.0°C)
Core 2:         +26.0°C  (high = +85.0°C, crit = +95.0°C)
Core 3:         +24.0°C  (high = +85.0°C, crit = +95.0°C)
Core 4:         +27.0°C  (high = +85.0°C, crit = +95.0°C)
Core 5:         +23.0°C  (high = +85.0°C, crit = +95.0°C)
Core 8:         +26.0°C  (high = +85.0°C, crit = +95.0°C)
Core 9:         +24.0°C  (high = +85.0°C, crit = +95.0°C)
Core 10:        +23.0°C  (high = +85.0°C, crit = +95.0°C)
Core 11:        +22.0°C  (high = +85.0°C, crit = +95.0°C)
Core 12:        +23.0°C  (high = +85.0°C, crit = +95.0°C)
Core 13:        +25.0°C  (high = +85.0°C, crit = +95.0°C)

coretemp-isa-0001
Adapter: ISA adapter
Physical id 1:  +33.0°C  (high = +85.0°C, crit = +95.0°C)
Core 0:         +27.0°C  (high = +85.0°C, crit = +95.0°C)
Core 1:         +26.0°C  (high = +85.0°C, crit = +95.0°C)
Core 2:         +30.0°C  (high = +85.0°C, crit = +95.0°C)
Core 3:         +29.0°C  (high = +85.0°C, crit = +95.0°C)
Core 4:         +26.0°C  (high = +85.0°C, crit = +95.0°C)
Core 5:         +27.0°C  (high = +85.0°C, crit = +95.0°C)
Core 8:         +27.0°C  (high = +85.0°C, crit = +95.0°C)
Core 9:         +25.0°C  (high = +85.0°C, crit = +95.0°C)
Core 10:        +24.0°C  (high = +85.0°C, crit = +95.0°C)
Core 11:        +27.0°C  (high = +85.0°C, crit = +95.0°C)
Core 12:        +29.0°C  (high = +85.0°C, crit = +95.0°C)
Core 13:        +30.0°C  (high = +85.0°C, crit = +95.0°C)
