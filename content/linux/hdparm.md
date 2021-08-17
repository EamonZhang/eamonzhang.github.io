---
title: "hdparm 查看硬盘型号"
date: 2018-12-19T08:53:10+08:00
draft: false
---

#### 安装工具

```
yum install hdparm
```


#### 查看

-i参数是在引导驱动器时获得的识别信息，这个信息有时候不完整也不一
定准确

```
hdparm -i /dev/sdb

/dev/sdb:

 Model=INTEL SSDSC2KW512G8, FwRev=LHF002C, SerialNo=PHLA75210153512DGN
 Config={ Fixed }
 RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=0
 BuffType=unknown, BuffSize=unknown, MaxMultSect=16, MultSect=off
 CurCHS=16383/16/63, CurSects=16514064, LBA=yes, LBAsects=1000215216
 IORDY=on/off, tPIO={min:120,w/IORDY:120}, tDMA={min:120,rec:120}
 PIO modes:  pio0 pio3 pio4 
 DMA modes:  mdma0 mdma1 mdma2 
 UDMA modes: udma0 udma1 udma2 udma3 udma4 udma5 *udma6 
 AdvancedPM=yes: unknown setting WriteCache=enabled
 Drive conforms to: unknown:  ATA/ATAPI-2,3,4,5,6,7

 * signifies the current active mode

```

-I参数是直接从驱动器获取识别信息, 并以原始的,未经过修改和更正的形式显示

```

hdparm -I /dev/sdb

/dev/sdb:

ATA device, with non-removable media
	Model Number:       INTEL SSDSC2KW512G8                     
	Serial Number:      PHLA75210153512DGN  
	Firmware Revision:  LHF002C
	Transport:          Serial, ATA8-AST, SATA 1.0a, SATA II Extensions, SATA Rev 2.5, SATA Rev 2.6, SATA Rev 3.0
Standards:
	Used: unknown (minor revision code 0xffff) 
	Supported: 10 9 8 7 6 5 
	Likely used: 10
Configuration:
	Logical		max	current
	cylinders	16383	16383
	heads		16	16
	sectors/track	63	63
	--
	CHS current addressable sectors:   16514064
	LBA    user addressable sectors:  268435455
	LBA48  user addressable sectors: 1000215216
	Logical  Sector size:                   512 bytes
	Physical Sector size:                   512 bytes
	Logical Sector-0 offset:                  0 bytes
	device size with M = 1024*1024:      488386 MBytes
	device size with M = 1000*1000:      512110 MBytes (512 GB)
	cache/buffer size  = unknown
	Form Factor: 2.5 inch
	Nominal Media Rotation Rate: Solid State Device
Capabilities:
	LBA, IORDY(can be disabled)
	Queue depth: 32
	Standby timer values: spec'd by Standard, no device specific minimum
	R/W multiple sector transfer: Max = 16	Current = 16
	Advanced power management level: 254
	DMA: mdma0 mdma1 mdma2 udma0 udma1 udma2 udma3 udma4 udma5 *udma6 
	     Cycle time: min=120ns recommended=120ns
	PIO: pio0 pio1 pio2 pio3 pio4 
	     Cycle time: no flow control=120ns  IORDY flow control=120ns
Commands/features:
	Enabled	Supported:
	   *	SMART feature set
	    	Security Mode feature set
	   *	Power Management feature set
	   *	Write cache
	   *	Look-ahead
	   *	Host Protected Area feature set
	   *	WRITE_BUFFER command
	   *	READ_BUFFER command
	   *	NOP cmd
	   *	DOWNLOAD_MICROCODE
	   *	Advanced Power Management feature set
	   *	48-bit Address feature set
	   *	Mandatory FLUSH_CACHE
	   *	FLUSH_CACHE_EXT
	   *	SMART error logging
	   *	SMART self-test
	   *	General Purpose Logging feature set
	   *	WRITE_{DMA|MULTIPLE}_FUA_EXT
	   *	64-bit World wide name
	   *	IDLE_IMMEDIATE with UNLOAD
	   *	WRITE_UNCORRECTABLE_EXT command
	   *	{READ,WRITE}_DMA_EXT_GPL commands
	   *	Segmented DOWNLOAD_MICROCODE
	   *	Gen1 signaling speed (1.5Gb/s)
	   *	Gen2 signaling speed (3.0Gb/s)
	   *	Gen3 signaling speed (6.0Gb/s)
	   *	Native Command Queueing (NCQ)
	   *	Host-initiated interface power management
	   *	Phy event counters
	   *	unknown 76[15]
	   *	DMA Setup Auto-Activate optimization
	    	Device-initiated interface power management
	   *	Software settings preservation
	    	unknown 78[8]
	   *	SMART Command Transport (SCT) feature set
	   *	SCT Write Same (AC2)
	   *	SCT Error Recovery Control (AC3)
	   *	SCT Features Control (AC4)
	   *	SCT Data Tables (AC5)
	   *	reserved 69[4]
	   *	DOWNLOAD MICROCODE DMA command
	   *	WRITE BUFFER DMA command
	   *	READ BUFFER DMA command
	   *	Data Set Management TRIM supported (limit 8 blocks)
	   *	Deterministic read ZEROs after TRIM
Security: 
	Master password revision code = 65534
		supported
	not	enabled
	not	locked
		frozen
	not	expired: security count
		supported: enhanced erase
	2min for SECURITY ERASE UNIT. 2min for ENHANCED SECURITY ERASE UNIT. 
Logical Unit WWN Device Identifier: 55cd2e414f0a032e
	NAA		: 5
	IEEE OUI	: 5cd2e4
	Unique ID	: 14f0a032e
Checksum: correct

```

#### 其他方法 [smartctl](linux/smartctl/)

```
smartctl -a /dev/sdb 
smartctl 6.5 2016-05-07 r4318 [x86_64-linux-3.10.0-862.9.1.el7.x86_64] (local build)
Copyright (C) 2002-16, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Device Model:     INTEL SSDSC2KW512G8
Serial Number:    PHLA75210153512DGN
LU WWN Device Id: 5 5cd2e4 14f0a032e
Firmware Version: LHF002C
User Capacity:    512,110,190,592 bytes [512 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
Device is:        Not in smartctl database [for details use: -P showall]
ATA Version is:   ACS-3 (minor revision not indicated)
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Wed Dec 19 09:17:01 2018 CST
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
recommended polling time: 	 (  30) minutes.
SCT capabilities: 	       (0x003d)	SCT Status supported.
					SCT Error Recovery Control supported.
					SCT Feature Control supported.
					SCT Data Table supported.

SMART Attributes Data Structure revision number: 1
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  5 Reallocated_Sector_Ct   0x0032   100   100   000    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   100   100   000    Old_age   Always       -       3730
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       6
170 Unknown_Attribute       0x0033   100   100   010    Pre-fail  Always       -       0
171 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
172 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
173 Unknown_Attribute       0x0033   100   100   005    Pre-fail  Always       -       0
174 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       4
183 Runtime_Bad_Block       0x0032   100   100   000    Old_age   Always       -       0
184 End-to-End_Error        0x0033   100   100   090    Pre-fail  Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
190 Airflow_Temperature_Cel 0x0032   020   029   000    Old_age   Always       -       20 (Min/Max 19/29)
192 Power-Off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       4
199 UDMA_CRC_Error_Count    0x0032   100   100   000    Old_age   Always       -       0
225 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       15
226 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       0
227 Unknown_SSD_Attribute   0x0032   100   100   000    Old_age   Always       -       0
228 Power-off_Retract_Count 0x0032   100   100   000    Old_age   Always       -       0
232 Available_Reservd_Space 0x0033   100   100   010    Pre-fail  Always       -       0
233 Media_Wearout_Indicator 0x0032   100   100   000    Old_age   Always       -       0
236 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
241 Total_LBAs_Written      0x0032   100   100   000    Old_age   Always       -       15
242 Total_LBAs_Read         0x0032   100   100   000    Old_age   Always       -       366193
249 Unknown_Attribute       0x0032   100   100   000    Old_age   Always       -       0
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
