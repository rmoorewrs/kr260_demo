#!/bin/sh

# make sure and run 01_set_wrenv.sh before running this script

# check that this is a valid VxWorks dev shell
if [ -z "$WIND_RELEASE_ID" ]; then echo "WR Dev Shell Not detected, run \<install_dir\>/wrenv.sh -p vxworks/${VXWORKS_VERSION} first";return -1; else echo "VxWorks Release $WIND_RELEASE_ID detected"; fi


export SUB_PROJECT_NAME=${PROJECT_NAME}_r5
export DTS_PATCH_FILE=${SUB_PROJECT_NAME}_dts.patch
export DTSI_PATCH_FILE=${SUB_PROJECT_NAME}_dtsi.patch
export BSP_NAME=${BSP_NAME_R5}
export DTS_FILE=${DTS_FILE_R5}
export DTSI_FILE=${DTSI_FILE_R5}

# set 'build' as project workspace
mkdir -p build
export MY_WS_DIR=$(pwd)/build

# set project names
export VSB_NAME=${SUB_PROJECT_NAME}-vsb
export VIP_NAME=${SUB_PROJECT_NAME}_eth-vip

generate_dtsi_patch_file()
{

cat << EOF > $1
--- ${DTS_FILE}
+++ ${DTS_FILE}
@@ -131,13 +131,13 @@
              interrupt-parent = <&intc>;
              };
 
-         gem3: ethernet@ff0e0000
+         gem1: ethernet@ff0c0000
              {
              #size-cells = <0>;
              #address-cells = <1>;
              compatible = "amd,gem";
              status = "disabled";
-             reg = <0xff0e0000 0x1000>;
+             reg = <0xff0c0000 0x1000>;
              bus-width = <64>;
 #ifdef AMD_ZYNQ_END_BD_RX_NUM
             rx-bd-num = <AMD_ZYNQ_END_BD_RX_NUM>;
@@ -146,7 +146,7 @@
             tx-bd-num = <AMD_ZYNQ_END_BD_TX_NUM>;
 #endif /* AMD_ZYNQ_END_BD_TX_NUM */
              local-mac-address = [ 00 0A 35 11 22 33 ];
-             clocks = <&gem3_ref_div_clk>;
+             clocks = <&gem1_ref_div_clk>;
              interrupts = <95 0 0x104>;
              interrupt-parent = <&intc>;
              };
EOF

}

generate_dts_patch_file()
{

cat << EOF > $1
--- ${DTS_FILE}
+++ ${DTS_FILE}
@@ -12,17 +12,18 @@
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  */
 
+/* This version gives the GEM1 and UART1 devices to the R5 core for debug purposes */
 /dts-v1/;
 
 #include "zynqmp-r5.dtsi"
 
 / {
-    model = "AMD ZynqMP ZCU102 Cortex-R5";
+    model = "AMD ZynqMP KR260 Cortex-R5";
 
     aliases
         {
-        serial0 = &uart0;
-        ethernet3 = &gem3;
+        serial0 = &uart1;
+        ethernet0 = &gem1;
         };
 
     memory@78000000
@@ -30,10 +31,18 @@
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
@@ -43,16 +52,16 @@
      clock-frequency = <33330000>;
      };
 
-&gem3
+&gem1
     {
     status = "okay";
-    phy-handle = <&phy3>;
+    phy-handle = <&phy1>;
 
-    phy3: ethernet-phy@c
+    phy1: ethernet-phy@c
         {
         compatible = "tiDpPhy";
 
-        reg = <0x0c>;
+        reg = <0x08>;
         rgmii-delay = <0x3>;
         rx-internal-delay = <0x8>;
         tx-internal-delay = <0xa>;
@@ -60,7 +69,7 @@
         };
     };
 
-&uart0
+&uart1
     {
     status = "okay";
     };

EOF

}


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


# patch the dts and dtsi files
cd ${BSP_NAME}
# Patch the DTS file
cp ${DTS_FILE} ${DTS_FILE}.orig
generate_dts_patch_file ${DTS_PATCH_FILE}
patch -p0 < ${DTS_PATCH_FILE}

# Patch the DTSI file
cp ${DTSI_FILE} ${DTSI_FILE}.orig
generate_dtsi_patch_file ${DTSI_PATCH_FILE}
patch -p0 < ${DTSI_PATCH_FILE}
cd ..

vxprj vip build

cd $MY_WS_DIR

echo "Done. Remember to copy this to your tftpboot directory (if you're using tftp)"
echo "cp ${PROJECT_NAME}-vip/default/uVxWorks /tftpboot/uVxWorks_r5_eth"
echo "- or edit the deploy_output line in '.wrmakefile' to copy it automatically every time the VIP is built"
