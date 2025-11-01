# VxWorks demo scripts AMD Kria KR260 Starter Kit
Rich Moore (rmoorewrs at gmail.com)

This is a set of scripts that will build VxWorks projects that can be loaded on an AMD Kria KR260 starter kit. 

## Prerequisites: 
- Valid VxWorks 25.09 installation and active license
- KR260 with u-boot in QSPI (assuming factory default version)
- FAT32 microSD card for automatic boot (withouth modifying QSPI)
- tftp server
- this git repo

## Use Cases
There are 3 use cases covered here, each of which has different DTS file settings and boot commands. Use case 1 below is the default created by the A53 and R5 scripts (i.e. the scripts patch the DTS files).  

Case 2 requires DTS modification to activate UART1 on the A53. Case 3 has its own script and creates its own VIP project. 

### Case 1 - A53 and R5 cores together (default)
In this case, GEM1 (Eternet) is assigned to the A53 cores and UART1 (serial) is assigned to the R5 core. You can access the A53 target shell via telnet. A `generic FDT device` is created in the DTS to allow shared memory between the cores. Search for `vxbFdtMap` in the VxWorks docs for more details. 

### Case 2 - A53 cores only 
The A53 DTS file should have UART1 and GEM1 (Ethernet) in an "okay" state for the DTS file in the A53 VIP project. The R5 image won't be loaded, so its configuration doesn't matter here. 

### Case 3 - R5 core only
In this case, both UART1 and GEM1 are "okay" in R5's DTS file. The A53 image won't be loaded so its configuration doesn't matter. 

> Note: the DTS files (e.g. `amd-zcu102-rev-1.1.dts`) are located in the VxWorks Image Project (VIP) under the BSP directory, e.g. `amd_zynqmp_3_0_1_2`

---

## Instructions:

### 1) Clone this project and enter the project directory

```
git clone https://github.com/rmoorewrs/kr260_demo.git
cd kr260_demo
./00_runme_first.sh
```
>Note: 
- edit the `project_params.sh` script to match your VxWorks installation path, IP addresses, etc

### 2) Set up the environment variables for VxWorks

After editing `project_parameters` run the environment variable setup script
```
./01_set_wrenv.sh
```

 Alternately, run 
 ```
 <path-to-vxworks-install>/wrenv.sh -p vxworks/25.09     # use your path, your version
 ```

### 3) Run the A53 creation script (Case 1)
```
./02_create_a53.sh
```
This script patches the A53 DTS file to add the generic memory device, enable Ethernet on the A53 and disable UART on the A53. If you want to run the A53 cores alone (i.e. no R5) then you need to **edit the DTS file to enable the UART for the A53 cores.**  

### 4) Run the R5 creation script (Case 1)
```
./03_create_r5.sh
```
This script will patch the R5 DTS file to add the generic memory device, enable UART and disable Ethernet. 

### 5) Case 2, A53 cores by themselves
Remember to edit the A53 DTS file in the VIP project. Change the status of `UART1` from "disabled" to "okay" then build the VIP again. 
```
    status = "disabled";
```
to
```
    status = "okay";
```

### 6) Case 3, R5 core by itself
```
./99_create_r5_only_eth_vip.sh
```
This script patches the R5 DTS file to enable Ethernet and UART

>Note: this script only uses one of the two R5 cores. Enabling the second R5 core will require an extension of the R5 Board Support Package 

### 7) Optional: import the VSB and VIP projects into Workbench. 
Open Workbench and select the `build` directory as the workspace. It will be empty initially, so you must import these projects:
- kr260_r5-vsb
- kr260_r5-vip
- kr260_a53-vsb
- kr260_a53-vip
- kr260_r5_eth-vip (optional)

To import in workbench, do the following (best practice to import the VSBs first):
```
File->Import->VxWorks->VxWorks VSB
Browse to the VSB project
Select the VSB project

File->Import->VxWorks->VxWorks VIP
Browse to the VIP
Select the VIP project
```

### 8) Case 1: Booting both cores from u-boot (both kernels have built-in DTB)
```
tftpboot 0x100000 vxWorks_a53.bin
tftpboot 0x78100000 vxWorks_r5.bin
zynqmp tcminit split; cpu 4 release 78100000 split; go 100000
```

### 9) Case 2: Booting only on A53 Core from u-boot
Again, you must edit the A53 DTS file in the VIP project and change the status of `UART1` from "disabled" to "okay" then build the VIP again. 

To boot just the A53 cores with built-in DTB (default created by the scripts)
```
tftpboot 0x100000 vxWorks_a53.bin
go 0x100000
```

### 10) Case 3: Booting only on R5 Core with Ethernet NIC from u-boot
This is useful for debugging on the R5 core via Ethernet.
```
tftpboot 0x78100000 vxWorks_r5_eth.bin
zynqmp tcminit split;cpu 4 release 78100000 split; cpu 0 disable
```

---

## Making edit->build->test easier
If you've imported the projects into Workbench, you can add a command to the `.wrmakefile` in the VIP that will automatically copy the `vxWorks.bin` file to your tftp server. 

First, open `.wrmakefile` in the VxWorks Image Project directory.

Search for `deploy_output` in `.wrmakefile` and add your OS copy commands. Note that the extra copy commands will persist only as long as you do `Build Project` in Workbench. If you do a `Rebuild Project` they'll be wiped out, since `.wrmakefile` gets refreshed.

```
# entry point for deploying output after the build
deploy_output ::
	@echo "deploy_output"
	cp default/vxWorks.bin /tftpboot/vxWorks_a53.bin
```

## Making the KR260 boot automatically without altering the QSPI contents.
The KR260 is hardwired to boot from QSPI (as far as I can tell) so to change the boot behavior, you either have to rebuild/reprogram the QSPI u-boot program or environment. The alternative is to leave the factory QSPI u-boot as is, and provide a `boot.scr.uimg` file on a FAT32 formatted microSD card. 

See the instructions in the `boot` directory README.md file



