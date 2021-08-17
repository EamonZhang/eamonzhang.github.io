---
title: "KVM"
date: 2018-11-06T16:23:07+08:00
draft: false
---
- 安装
 
#### ubuntu14.04 
---

.安装kvm

apt-get install qemu-kvm libvirt0 virtinst bridge-utils virt-viewer 

.配置实体机网络

 cat /etc/network/interfaces

```
auto lo
iface lo inet loopback
auto br0
iface br0 inet static
address 10.0.*.*
netmask 255.255.0.0
gateway 10.1.0.1
type bridge
bridge_ports eth0
dns-nameservers 114.114.114.114
```

.创建一个虚拟机

```
virt-install --connect qemu:///system -n test01 -r 1024 -f /home/kvm/test01.qcow2 -s 20 -c /home/kvm/ubuntu-12.04.1-server-amd64.iso --vnc --noautoconsole --os-type linux --os-variant ubuntuPrecise --accelerate --network=bridge:br0 
```
#### centos7 
---

yum install qemu-kvm libvirt virt-install bridge-utils

.配置实体机网络

cat ifcfg-enp7s0
```
DEVICE="enp7s0"
ONBOOT=yes
BOOTPROTO=static
UUID=96a09db3-9b06-4a50-8d0c-9868cf531b84
#HWADDR="08:60:6E:06:C7:1A"
TYPE=Ethernet
BRIDGE=br0
IPADDR=0.0.0.0
```
cat ifcfg-br0
```
DEVICE=br0
ONBOOT=yes
BOOTPROTO=static
TYPE=Bridge
IPADDR=10.1.*.*
PREFIX=16
GATEWAY=10.1.0.1
DNS1=223.5.5.5
```

查看 brctl show

.启动 libvirt

systemctl start libvirtd

systemctl enable libvirtd

.创建虚拟机

```
virt-install --virt-type kvm --name test01 --ram 1024 --vcpus 1 --cdrom=/home/kvm/CentOS-7.0-1406-x86_64-DVD.iso --disk path=/home/kvm/test01.qcow2,size=10,format=qcow2 --network bridge=br0 --graphics vnc,listen=0.0.0.0 --noautoconsole --os-type=linux --os-variant=rhel7 
```

.连接道virth

virsh --connect qemu:///system  
.virt-viewer  
    连接本机的虚拟机:virt-viewer -c qemu:///system 虚拟机名   
    连接远程的虚拟机:virt-viewer -c qemu+ssh://ip/system 虚拟机名  

 

设置开机自启动 virsh autostart server01

- 克隆
 
---   
```
virt-clone --connect=qemu:///system -o server-02 -n server-clone -f /var/lib/libvirt/images/server-clone.img
```

参数说明  
-o --original 原始被克隆镜像 
-n --name 新镜像名称 
-f --file 镜像文件存放的物理地址 

注意事项 
被克隆镜像为关闭或停止状态  
virsh destroy server-02 
 
其他说明 

cat /etc/libvirt/qemu/server-02.xml | grep "source" 
cat /etc/libvirt/qemu/server-02.xml | grep "mac" 

在 vi /etc/sysconfig/network-scripts/ifcfg-eth0 中修改相应的mac 

- 修改磁盘大小 

---  
qemu-img resize [-q] filename [+ | -]size 

1.修改前查看 

```
qemu-img info test01.qcow2
image: test01.qcow2
file format: qcow2
virtual size: 10G (10737418240 bytes)
disk size: 9.0G
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
```

2.关闭虚拟机
```
virsh shutdown test01
```

3.修改磁盘文件大小
```
qemu-img resize test01.qcow2 +10G
Image resized.
```

4.查看 结果

```
qemu-img info test01.qcow2
image: test01.qcow2
file format: qcow2
virtual size: 20G (21474836480 bytes)
disk size: 9.0G
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: true
```
5.重新启动虚拟机 进入虚拟机查看
virsh start test01

```
fdisk -l
 
磁盘 /dev/vda：42.9 GB, 42949672960 字节，83886080 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000a4b0b
 
   设备 Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048     1026047      512000   83  Linux
/dev/vda2         1026048     3123199     1048576   82  Linux swap / Solaris
/dev/vda3         3123200    20971519     8924160   83  Linux
```

磁盘空间变大

- 扩容分区 

--- 
1 fdisk 修改分区表　，　删除最后一个分区，新建分区，保持退出
echo d; echo n; echo ; echo ; echo ; echo ; echo w;) | fdisk $rootdevicepath
重启

resize2fs $partedpath　扩磁盘空间


- 修改内存和CUP

---  

1 查看 virsh dominfo test01  
2 改内存 virsh setmem [domain-id or domain-name] [count]  
3 改CUP virsh setvcpus test01 2 

[原文](https://www.cnblogs.com/zhangeamon/p/6734275.html)  
