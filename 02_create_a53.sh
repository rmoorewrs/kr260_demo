#!/bin/sh

# make sure and run 01_set_wrenv.sh before running this script

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi

# set filename for A53 projects
export SUB_PROJECT_NAME=${PROJECT_NAME}_a53
export BSP_NAME=${BSP_NAME_A53}


# set 'build' as project workspace
mkdir -p build
export DTS_DIR=$(pwd)/dts
export MY_WS_DIR=$(pwd)/build

# set project names
export VSB_NAME=${SUB_PROJECT_NAME}-vsb
export VIP_NAME=${SUB_PROJECT_NAME}-vip

# cd into the workspace directory
cd ${MY_WS_DIR}
echo $pwd

###############
# VSB
###############
# build the VSB
vxprj vsb create -lp64 -bsp ${BSP_NAME} ${VSB_NAME} -force -S 
cd ${VSB_NAME}

# comment out these lines if you don't want benchmarks
vxprj vsb config -s -add _WRS_CONFIG_BENCHMARKS=y 
vxprj vsb config -s -add _WRS_CONFIG_BENCHMARK=y
vxprj vsb config -s -add _WRS_CONFIG_BENCHMARKS_RTOS_BENCHMARK=y
vxprj vsb config -s -add _WRS_CONFIG_GOOGLETEST=y
vxprj vsb config -s -add _WRS_CONFIG_IPNET_SSH=y
vxprj vsb config -s -add _WRS_CONFIG_IPERF3=y

# build the VSB
vxprj vsb build -j

###############
# VIP
###############
# create, configure and build VIP
cd $MY_WS_DIR
vxprj vip create -vsb $VSB_NAME ${BSP_NAME} llvm -profile PROFILE_DEVELOPMENT $VIP_NAME
cd $MY_WS_DIR/$VIP_NAME
vxprj bundle add BUNDLE_STANDALONE_SHELL
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_SYM_TBL
vxprj vip component add $VIP_NAME INCLUDE_RTP
vxprj vip component add $VIP_NAME INCLUDE_TIMER_SYS_SHOW
vxprj vip component add $VIP_NAME INCLUDE_GETOPT 
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_DTB
vxprj vip component add $VIP_NAME INCLUDE_IPWRAP_IFCONFIG
vxprj vip component add $VIP_NAME INCLUDE_IFCONFIG
vxprj vip parameter set $VIP_NAME IFCONFIG_1 '"ifname gem0","devname gem","inet '"${TARGET_IP}"'/'"${NETMASKCIDR}"'","gateway '"${GATEWAY_IP}"'"'
vxprj vip component add $VIP_NAME INCLUDE_IPATTACH
vxprj vip component add $VIP_NAME INCLUDE_PING
vxprj vip component add $VIP_NAME INCLUDE_IPPING_CMD
vxprj vip component add $VIP_NAME INCLUDE_IPTELNETS
vxprj vip component add $VIP_NAME INCLUDE_ROUTECMD
vxprj vip component add $VIP_NAME INCLUDE_IPROUTE_CMD

vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME DRV_TEMPLATE_FDT_MAP
vxprj vip component add $VIP_NAME DRV_QSPI_FDT_ZYNQMP

# Benchmark: select only one of POSIX or NONPOSIX (VxWorks native) 
vxprj vip component add $VIP_NAME INCLUDE_RTOS_BENCHMARK_NONPOSIX
# vxprj vip component add $VIP_NAME INCLUDE_RTOS_BENCHMARK_POSIX

# Filesystem
vxprj vip component add $VIP_NAME INCLUDE_SD_BUS
vxprj vip component add $VIP_NAME DRV_MMCSTORAGE_CARD
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_DIR_VFAT
vxprj vip parameter set $VIP_NAME DOSFS_COMPAT_NT 'FALSE'
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_FAT
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_CACHE
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_SHOW
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_PRTMSG_LEVEL
vxprj vip component add $VIP_NAME INCLUDE_DOSFS_MAIN

# Debug
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT_START
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_AGENT
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_DEBUG_SUPPORT
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT INCLUDE_DEBUG_AGENT_START 
vxprj vip component add $VIP_NAME INCLUDE_WINDVIEW INCLUDE_WVUPLOAD_FILE
vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME INCLUDE_VXEVENTS

# copy and specify the project DTS file
vxprj vip parameter set $VIP_NAME DTS_FILE "$DTS_FILE_A53"
cp $DTS_DIR/$DTS_FILE_A53 ${BSP_NAME}/$DTS_FILE_A53

# build the project
vxprj vip build 
cd $MY_WS_DIR

echo Done. Remember to copy this to your tftpboot directory
echo 
echo "Tip: add this to line 64 of (deploy section)'.wrmakefile' to copy it automatically every time the VIP is built"
echo "cp default/vxWorks.bin /tftpboot/vxWorks_a53.bin"
