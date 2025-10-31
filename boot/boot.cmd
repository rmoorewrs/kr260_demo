# Generate boot.scr:
# mkimage -c none -A arm -T script -d boot.cmd boot.scr.uimg
#
################
echo "This is the bootscript on microSD that boots VxWorks on the KR260"

# set your IP address and address of TFTP server
setenv ipaddr 192.168.12.32
setenv netmask 255.255.255.0
setenv serverip 192.168.12.51

# uncomment for uVxWorks with discrete DTB file on A53 only
#tftpboot 0x100000 uVxWorks
#tftpboot 0x0f000000 default.dtb
#bootm 0x100000 - 0x0f000000

# uncomment for vxWorks_a53.bin with built-in DTB on A53 only
# tftpboot 0x100000 vxWorks_a53.bin; go 0x100000

# uncomment for booting on both A53 and R5 cores
# tftpboot 0x100000 vxWorks_a53.bin
# tftpboot 0x78100000 vxWorks_r5.bin
# zynqmp tcminit split; cpu 4 release 78100000 split; go 100000
exit

