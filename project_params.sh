#!/bin/sh
# please edit this file to match your VxWorks installation and Network addresses

# set project name. This is prepended to the sub projects
export PROJECT_NAME=kr260

# Set VxWorks version and install path
export VXWORKS_VERSION=25.09

# export BSP_NAME=amd_zynqmp_3_0_1_1
export BSP_NAME_A53=amd_zynqmp_3_0_1_2
export BSP_NAME_R5=amd_zynqmp_r5_2_0_5_1
export DTS_FILE_A53=amd-zcu102-rev-1.1.dts
export DTS_FILE_R5=amd-zcu102-r5-rev-1.1.dts
export DTSI_FILE_R5=zynq-r5.dtsi
export VXWORKS_INSTALL_PATH=/opt/wr/vx/vx2509

# set this for your network
export TARGET_IP=192.168.12.32
export SERVER_IP=192.168.12.51
export GATEWAY_IP=192.168.12.1
export NETMASK=255.255.255.0
export NETMASKHEX=ffffff00
export NETMASKCIDR=24


