#!/bin/sh

# edit your site and project specifics in the project_params.sh file
source $(pwd)/project_params.sh

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi


export SUB_PROJECT_NAME=${PROJECT_NAME}_a53
export PATCH_FILE=${SUB_PROJECT_NAME}_dts.patch
export BSP_NAME=${BSP_NAME_A53}

# set current directory as workspace
export MY_WS_DIR=$(pwd)/ws

# set project names
export VSB_NAME=${SUB_PROJECT_NAME}-vsb
export VIP_NAME=${SUB_PROJECT_NAME}-vip

generate_patch_file()
{

cat << EOF > $1
--- ${DTS_FILE}
+++ dont-care.dts.modified
@@ -28,13 +28,20 @@
     memory@0
         {
         device_type = "memory";
-        reg = <0x0 0x00000000 0x0 0x80000000>,
+        reg = <0x0 0x00000000 0x0 0x76000000>,
               <0x8 0x00000000 0x0 0x80000000>;
         };
 
+    generic_dev@0x76000000
+        {
+        compatible = "fdt,generic-dev";
+        reg = <0x0 0x76000000 0x0 0x02000000>;
+        status = "okay";
+        };
+
     chosen
         {
-        bootargs = "gem(0,0)host:vxWorks h=192.168.1.2 e=192.168.1.6:ffffff00 g=192.168.1.1 u=target pw=vxTarget";
+        bootargs = "gem(0,0)host:vxWorks h=${SERVER_IP} e=${TARGET_IP}:${NETMASKHEX} g=${GATEWAY_IP} u=target pw=vxTarget";
         stdout-path = "serial0";
         };
     };
EOF

}


# cd into the workspace directory
cd ${MY_WS_DIR}
echo $pwd

# build the VSB
vxprj vsb create -lp64 -bsp ${BSP_NAME} ${VSB_NAME} -force -S 
cd ${VSB_NAME}
vxprj vsb build -j

# create, configure and build VIP
cd $MY_WS_DIR
vxprj vip create -vsb $VSB_NAME ${BSP_NAME} llvm -profile PROFILE_DEVELOPMENT $VIP_NAME
cd $MY_WS_DIR/$VIP_NAME
vxprj bundle add BUNDLE_STANDALONE_SHELL
vxprj vip component add $VIP_NAME INCLUDE_GETOPT 
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_DTB
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT_START
vxprj vip component add $VIP_NAME INCLUDE_IPWRAP_IFCONFIG
vxprj vip component add $VIP_NAME INCLUDE_IFCONFIG
vxprj vip parameter set $VIP_NAME IFCONFIG_1 '"ifname gem0","devname gem","inet ${TARGET_IP}/${NETMASKCIDR}","gateway ${GATEWAY_IP}"'
vxprj vip component add $VIP_NAME INCLUDE_PING
vxprj vip component add $VIP_NAME INCLUDE_IPPING_CMD
vxprj vip component add $VIP_NAME INCLUDE_IPTELNETS
vxprj vip component add $VIP_NAME INCLUDE_ROUTECMD
vxprj vip component add $VIP_NAME INCLUDE_IPROUTE_CMD

vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME DRV_TEMPLATE_FDT_MAP
vxprj vip component add $VIP_NAME DRV_QSPI_FDT_ZYNQMP

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
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_AGENT
vxprj vip component add $VIP_NAME INCLUDE_ANALYSIS_DEBUG_SUPPORT
vxprj vip component add $VIP_NAME INCLUDE_DEBUG_AGENT INCLUDE_DEBUG_AGENT_START 
vxprj vip component add $VIP_NAME INCLUDE_WINDVIEW INCLUDE_WVUPLOAD_FILE
vxprj vip component add $VIP_NAME INCLUDE_VXBUS_SHOW
vxprj vip component add $VIP_NAME INCLUDE_VXEVENTS

# patch the dts file
cd ${BSP_NAME}
cp ${DTS_FILE} ${DTS_FILE}.orig
generate_patch_file ${PATCH_FILE}
patch -p0 < ${PATCH_FILE}
cd ..

vxprj vip build 
cd $MY_WS_DIR

echo Done. Remember to copy this to your tftpboot directory
echo cp ${SUB_PROJECT_NAME}_a53-vip/default/vxWorks.bin /tftpboot/vxWorks_a53.bin
