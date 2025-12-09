rem edit these parameters to match your setup 
rem Note: Please set VXWORKS_INSTALL_PATH to the Unix-style path equivalent of WIND_BASE
set WIND_BASE=C:\vx\vx2509
set VXWORKS_INSTALL_PATH=/c/vx/vx2509
set VXWORKS_VERSION=25.09

rem Project settings
set PROJECT_NAME=kr260
set BSP_NAME_A53=amd_zynqmp_3_0_1_2
set BSP_NAME_R5=amd_zynqmp_r5_2_0_5_1
set DTS_FILE_A53=kr260-a53.dts
set DTS_FILE_R5=kr260-r5.dts
set DTSI_FILE_R5=kr260-r5.dtsi
set DTS_FILE_R5_ETH=kr260-r5-eth.dts
set DTSI_FILE_R5_ETH=kr260-r5-eth.dtsi


# set this section for your target network
set TARGET_IP=192.168.12.35
set SERVER_IP=192.168.12.51
set GATEWAY_IP=192.168.12.1
set NETMASK=255.255.255.0
set NETMASKHEX=ffffff00
set NETMASKCIDR=24


echo setting VxWorks environment and starting bash on Windows
echo next run "./02_create_a53.sh" to build your project
%WIND_BASE%\wrenv.exe -p vxworks/%VXWORKS_VERSION% bash