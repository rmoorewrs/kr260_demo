#!/bin/sh

# make sure and run 01_set_wrenv.sh before running this script

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi


export SUB_PROJECT_NAME=${PROJECT_NAME}_r5
export PATCH_FILE=${SUB_PROJECT_NAME}_dts.patch
export BSP_NAME=${BSP_NAME_R5}
export DTS_FILE=${DTS_FILE_R5}

# set 'build' as project workspace
mkdir -p build
export MY_WS_DIR=$(pwd)/build

# set project names
export VSB_NAME=${SUB_PROJECT_NAME}-vsb
export VIP_NAME=${SUB_PROJECT_NAME}-vip


generate_patch_file()
{

cat << EOF > $1
--- ${DTS_FILE}
+++ ${DTS_FILE}
@@ -21,7 +21,7 @@
 
     aliases
         {
-        serial0 = &uart0;
+        serial0 = &uart1;
         ethernet3 = &gem3;
         };
 
@@ -30,10 +30,18 @@
         device_type = "memory";
         reg = <0x78000000 0x08000000>;
         };
+        
+        
+    generic_dev@0x76000000
+       {
+       compatible = "fdt,generic-dev";
+       reg = <0x76000000 0x02000000>;
+       status = "okay";
+       };
 
     chosen
         {
-        bootargs = "gem(0,0)host:vxWorks h=192.168.1.1 e=192.168.1.6:ffffff00 g=192.168.1.1 u=a pw=a";
+        bootargs = "gem(0,0)host:vxWorks h=${SERVER_IP} e=${TARGET_IP}:${NETMASKHEX} g=${GATEWAY_IP} u=a pw=a";
         stdout-path = "serial0";
         };
     };
@@ -60,7 +68,7 @@
         };
     };
 
-&uart0
+&uart1
     {
     status = "okay";
     };

EOF

}

# cd into the workspace directory
cd ${MY_WS_DIR}
echo $pwd

# build the VSB
vxprj vsb create -force -ilp32 -bsp $BSP_NAME -force -S $VSB_NAME
cd $VSB_NAME
vxprj vsb build -j

# create, configure and build VIP
cd $MY_WS_DIR
vxprj vip create -vsb $VSB_NAME $BSP_NAME -profile PROFILE_DEVELOPMENT $VIP_NAME
cd $MY_WS_DIR/$VIP_NAME
vxprj bundle add BUNDLE_STANDALONE_SHELL
vxprj vip component remove $VIP_NAME INCLUDE_NETWORK
vxprj vip component add $VIP_NAME INCLUDE_STANDALONE_DTB
vxprj vip component add $VIP_NAME INCLUDE_FDT_SHOW
vxprj vip component add $VIP_NAME DRV_TEMPLATE_FDT_MAP

# patch the dts file
cd ${BSP_NAME}
cp ${DTS_FILE} ${DTS_FILE}.orig
generate_patch_file ${PATCH_FILE}
patch -p0 < ${PATCH_FILE}
cd ..

vxprj vip build

cd $MY_WS_DIR

echo Done. Remember to copy the output to your tftpboot directory
echo cp ${PROJECT_NAME}/default/vxWorks.bin /tftpboot/vxWorks_r5.bin
echo - or edit the deploy_output line in '.wrmakefile' to copy it automatically

