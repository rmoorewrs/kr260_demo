# Generate boot.scr:
# mkimage -c none -A arm -T script -d boot.cmd boot.scr.uimg
#
################
#fitimage_name=image.ub
#kernel_name=uVxWorks

echo "This is the bootscript on microSD that boots VxWorks"

# set your IP address and address of TFTP server
setenv ipaddr 192.168.12.33
setenv netmask 255.255.255.0
setenv serverip 192.168.12.51

# load the VxWorks image and DTB file from the TFTP server
tftpboot 0x100000 uVxWorks
tftpboot 0x0f000000 default.dtb
bootm 0x100000 - 0x0f000000
