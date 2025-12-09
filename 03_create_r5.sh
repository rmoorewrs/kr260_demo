#!/bin/sh

# make sure and run 01_set_wrenv.sh before running this script

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi

# set the DTS file name


export SUB_PROJECT_NAME=${PROJECT_NAME}_r5
export BSP_NAME=${BSP_NAME_R5}


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

# build the VSB
vxprj vsb create -force -ilp32 -bsp $BSP_NAME -force -S $VSB_NAME
cd $VSB_NAME
vxprj vsb build -j

# create, configure and build VIP
cd ${MY_WS_DIR}
vxprj vip create -vsb $VSB_NAME $BSP_NAME -profile PROFILE_DEVELOPMENT $VIP_NAME
cd ${MY_WS_DIR}/${VIP_NAME}
vxprj bundle add BUNDLE_STANDALONE_SHELL
vxprj vip component remove $VIP_NAME INCLUDE_NETWORK
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_DTB
vxprj vip component add $VIP_NAME INCLUDE_FDT_SHOW
vxprj vip component add $VIP_NAME DRV_TEMPLATE_FDT_MAP

# copy and specify the project DTS file
vxprj vip parameter set $VIP_NAME DTS_FILE "${DTS_FILE_R5}"
cp ${DTS_DIR}/${DTS_FILE_R5} ${BSP_NAME}/${DTS_FILE_R5}
cp ${DTS_DIR}/${DTSI_FILE_R5} ${BSP_NAME}/${DTSI_FILE_R5}

vxprj vip build

cd $MY_WS_DIR

echo Done. Remember to copy the output to your tftpboot directory
echo 
echo "Tip: add this to line 64 of (deploy section)'.wrmakefile' to copy it automatically every time the VIP is built"
echo "cp default/vxWorks.bin /tftpboot/vxWorks_r5.bin"

