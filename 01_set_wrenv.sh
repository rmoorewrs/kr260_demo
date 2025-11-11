# edit these parameters to match your setup 

# Set VxWorks version and install path
export VXWORKS_INSTALL_PATH=/opt/wr/vx/vx2509
export VXWORKS_VERSION=25.09

# Project Settings 
export PROJECT_NAME=kr260
export BSP_NAME_A53=amd_zynqmp_3_0_1_2
export BSP_NAME_R5=amd_zynqmp_r5_2_0_5_1
export DTS_FILE_A53=amd-zcu102-rev-1.1.dts
export DTS_FILE_R5=amd-zcu102-r5-rev-1.1.dts
export DTSI_FILE_R5=zynq-r5.dtsi


# set this section for your target network
export TARGET_IP=192.168.12.32
export SERVER_IP=192.168.12.51
export GATEWAY_IP=192.168.12.1
export NETMASK=255.255.255.0
export NETMASKHEX=ffffff00
export NETMASKCIDR=24


echo "Setting VxWorks developer's shell environment variables. type 'env | grep WIND' to see them"
${VXWORKS_INSTALL_PATH}/wrenv.sh -p vxworks/${VXWORKS_VERSION}
