!/bin/sh

# make sure and run 01_set_wrenv.sh before running this script

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi

export SUB_PROJECT_NAME=${PROJECT_NAME}_r5
export BSP_NAME=${BSP_NAME_R5}

# set 'build' as project workspace
mkdir -p build
export DTS_DIR=$(pwd)/dts
export MY_WS_DIR=$(pwd)/build



# set project names
export VSB_NAME=${SUB_PROJECT_NAME}-vsb
export VIP_NAME=${SUB_PROJECT_NAME}_eth-vip

# use existing VSB
#vxprj vsb create -force -ilp32 -bsp $BSP_NAME -force -S $VSB_NAME
#cd $VSB_NAME
#vxprj vsb build -j

# cd into the workspace directory
cd ${MY_WS_DIR}
echo $pwd

# create, configure and build VIP
cd $MY_WS_DIR
vxprj vip create -vsb $VSB_NAME $BSP_NAME -profile PROFILE_DEVELOPMENT $VIP_NAME
cd $MY_WS_DIR/$VIP_NAME
vxprj bundle add BUNDLE_STANDALONE_SHELL
vxprj vip component add $VIP_NAME INCLUDE_GETOPT 
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_DTB
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT_START
vxprj vip component add $VIP_NAME INCLUDE_IPWRAP_IFCONFIG
vxprj vip component add $VIP_NAME INCLUDE_IFCONFIG
vxprj vip parameter set $VIP_NAME IFCONFIG_1 '"ifname gem0","devname gem","inet '"${TARGET_IP}"'/'"${NETMASKCIDR}"'","gateway '"${GATEWAY_IP}"'"'
vxprj vip component add $VIP_NAME INCLUDE_PING
vxprj vip component add $VIP_NAME INCLUDE_IPPING_CMD
vxprj vip component add $VIP_NAME INCLUDE_IPTELNETS
vxprj vip component add $VIP_NAME INCLUDE_ROUTECMD
vxprj vip component add $VIP_NAME INCLUDE_IPROUTE_CMD

vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME DRV_TEMPLATE_FDT_MAP
vxprj vip component add $VIP_NAME INCLUDE_FDT_SHOW

# Debug
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_AGENT
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_DEBUG_SUPPORT
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT INCLUDE_DEBUG_AGENT_START 
vxprj vip component add $VIP_NAME INCLUDE_WINDVIEW INCLUDE_WVUPLOAD_FILE
vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME INCLUDE_VXEVENTS

# copy and specify the project DTS and DTSI files
echo "copying DTS files from ${DTS_DIR}/${DTS_FILE_R5} ${BSP_NAME}/"
vxprj vip parameter set $VIP_NAME DTS_FILE "${DTS_FILE_R5_ETH}"
cp ${DTS_DIR}/${DTS_FILE_R5_ETH} ${BSP_NAME}/${DTS_FILE_R5_ETH}
cp ${DTS_DIR}/${DTSI_FILE_R5_ETH} ${BSP_NAME}/${DTSI_FILE_R5_ETH} 

vxprj vip build

cd $MY_WS_DIR

echo "Done. Remember to copy this to your tftpboot directory (if you're using tftp)"
echo 
echo "Tip: add this to line 64 of (deploy section)'.wrmakefile' to copy it automatically every time the VIP is built"
echo "cp default/vxWorks.bin /tftpboot/vxWorks_r5_eth.bin"

