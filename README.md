# kr260-demo
vxworks demo script for AMD Kria KR260 Starter Kit


## Prerequisites: 
- Valid VxWorks 25.09 installation
- KR260 with u-boot in QSPI
- FAT32 microSD card for automatic boot (withouth modifying QSPI)
- tftp server
- this git repo




Note: to customize the IP addresses for your target and tftp server, edit the bootarg lines in the `generate_patch_file()` functions inside of the two create scripts

## Instructions:

### 1) Clone this project and enter worksapce

```
git clone https://github.com/rmoorewrs/kr260_demo.git
cd kr260_demo
```
Note: 
- edit the `set_wrenv_2509.sh` script to match your VxWorks installation path
- edit the `create_kr260_a53.sh` file to match your target and tftp IDs


### 2) Set up the environment variables for VxWorks

After editing `set_wrenv_25.09.sh` run it
```
. ../set_wrenv_2509.sh
```

 Alternately, run 
 ```
 <path-to-vxworks-install>/wrenv.sh -p vxworks/25.09     # use your path, your version
 ```

### 3) Run the A53 creation script
```
../create_zynqmp_a53.sh
```

### 4) Run the R5 creation script
```
../create_zynqmp_r5.sh
```

### 5) Optional: import the VSB and VIP projects into Workbench. Import the VSBs first. 

Import 4 projects: 
- zynqmp_r5-vsb
- zynqmp_r5-vip
- zynqmp_a53-vsb
- zynqmp_a53-vip

In order to import in workbench do the following:
```
File->Import->VxWorks->VxWorks VSB
```

### 6) Booting both cores from u-boot (both kernels have built-in DTB)

```
tftpboot 0x100000 vxWorks_a53.bin
tftpboot 0x78100000 vxWorks_r5.bin
zynqmp tcminit split; cpu 4 release 78100000 split; go 100000
```

### 7) Booting only on A53 Core from u-boot
with separate kernel and DTB
```
tftpboot 0x100000 vxWorks_a53.bin
tftpboot 0x0f000000 xlnx-zcu102-rev-1.1.dtb
bootm 0x100000 - 0x0f000000
```
with built-in DTB
```
tftpboot 0x100000 vxWorks_a53.bin
bootm 0x100000 - 0x0f000000
```

### 8) Booting only on R5 Core with Ethernet NIC from u-boot
```
tftpboot 0x78100000 vxWorks_r5_eth.bin
zynqmp tcminit split;cpu 4 release 78100000 split; cpu 0 disable
```
