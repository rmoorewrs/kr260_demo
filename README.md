# VxWorks demo scripts AMD Kria KR260 Starter Kit
Rich Moore (rmoorewrs at gmail.com)

This is a set of scripts that will build VxWorks projects that can be loaded on an AMD Kria KR260 starter kit. Both the A53 application cores and one of the R5 realtime cores is supported. 

## Prerequisites: 
- Valid VxWorks 25.09 installation and active license
- KR260 with u-boot in QSPI (assuming factory default version)
- FAT32 microSD card for automatic boot (withouth modifying QSPI)
- tftp server
- this git repo (via git tools for your Host OS or the zip file from GitHub)

---

## Connections
#### UART
- The serial terminal is connected via the USB Micro connector labeled `JTAG/UART` next to the SFP connector on the KR260
- 4 serial ports will show show up on your host OS (e.g. /dev/ttyUSB0-USB3)
- select the second port (e.g. /dev/ttyUSB1) and configure your terminal for `115200,n,8,1` no flow control 

#### Ethernet
- Connect to the lower right port as you face the side of the SBC
    - the two left ports are for the FPGA fabric
    - the upper right port uses an SGMII PHY that the ZCU102 BSP doesn't support OOB
![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/kr260-ethernet.jpg)

---

## Use Cases
There are 3 use cases covered here, each of which has different DTS file settings and boot commands. 
- Case 1, both cores running VxWorks, is the default created by the 02 (A53) and 03 (R5) scripts. 
- Case 2, only the A53 core, requires DTS modification to activate UART1 on the A53.
- Case 3, only the R5 core with etherne, uses the previous R5 VSB but its own VIP project. 

### Case 1 - A53 and R5 cores together (default)
In this case, GEM1 (lower right RJ45 Ethernet port) is assigned to the A53 cores and UART1 (serial) is assigned to the R5 core. You can access the A53 target shell via telnet. A `generic FDT device` is created in the DTS to allow shared memory between the cores. See Appendix 4 below for more details and search for `vxbFdtMap` in the VxWorks docs. 

### Case 2 - A53 cores only 
The A53 DTS file should have UART1 and GEM1 (Ethernet) in an "okay" state for the DTS file in the A53 VIP project. The R5 image won't be loaded, so its configuration doesn't matter here. 

### Case 3 - R5 core only with Ethernet
In this case, both UART1 and GEM1 are "okay" in R5's DTS file. The A53 image won't be loaded so its configuration doesn't matter. 

> Note: the DTS files (e.g. `amd-zcu102-rev-1.1.dts`) are located in the VxWorks Image Project (VIP) under the BSP directory, e.g. `amd_zynqmp_3_0_1_2`

---

## Instructions:

## Step 1) Clone the Project
Open the right shell for your Host OS
- `bash` for Linux
- `cmd` for Windows (powershell may or may not work)
```
git clone https://github.com/rmoorewrs/kr260_demo.git
cd kr260_demo
```

## Step 2) Edit the Setup Script for your Host OS
Edit the `01_setup_wrenv` script for your Host OS (Windows or Linux) to match your VxWorks installation and Desired IP settings. After setting up this environment script and running it, all subsequent scripts must run in this shell. If you open a new shell, run the script first before doing other operations. 

### Linux Users: 
- edit the file `01_setup_wrenv.sh`
- run the script
```
./01_setup_wrenv.sh
```
### Windows Users: 
- edit the file `01_setup_script.bat`
- run the script
```
01_setup_wrenv.bat
```
 Note: after running either script, you will be in a bash shell. Run all scripts from the top-level directory (`kr260-demo`) and not the build directory. 

## Step 3) Run the A53 creation script (Case 1)
```
./02_create_a53.sh
```
This script patches the A53 DTS file to add the generic memory device, enable Ethernet on the A53 and disable UART on the A53. If you want to run the A53 cores alone (i.e. Case 2, no R5) then you need to **edit the DTS file to enable the UART for the A53 cores.**  
 
 ## Step 4) Run the R5 creation script (Case 1)
```
./03_create_r5.sh
```
This script will patch the R5 DTS file to add the generic memory device, enable UART and disable Ethernet. 


## Step 5) Optional: Case 2, A53 cores by themselves
Remember to edit the A53 DTS file in the VIP project. Change the status of `UART1` from "disabled" to "okay" then build the VIP again. 
```
    status = "disabled";
```
to
```
    status = "okay";
```


## Step 6) Optional: Case 3, Run the R5 standalone with Ethernet script
In some cases you may want to attach the Ethernet NIC to the R5 processor and not run the A53 cores. 
```
./99_create_r5_only_eth_vip.sh`
```
This script patches the R5 DTS file to enable Ethernet and UART

>Note: this works on the ZCU102 board, but requires more work on the KR260. 

>Note: these script only use one of the two R5 cores. Enabling the second R5 core will require an extension of the R5 Board Support Package 


## Step 7) Optional: import the VSB and VIP projects into Workbench. 
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
---

## Appendix 1: Booting the KR260 in the different use cases
---

If you interrupt the automatic u-boot script, remember to set the ip parameters. For example
```
setenv serverip 192.168.12.51
setenv ipaddr 192.168.12.33
setenv ipgateway 192.168.12.1
setenv netmask 255.255.255.0
```

### Case 1: Booting both cores from u-boot (both kernels have built-in DTB)
```
tftpboot 0x100000 vxWorks_a53.bin
tftpboot 0x78100000 vxWorks_r5.bin
zynqmp tcminit split; cpu 4 release 78100000 split; go 100000
```

### Case 2: Booting only on A53 Core from u-boot
Again, you must edit the A53 DTS file in the VIP project and change the status of `UART1` from "disabled" to "okay" then build the VIP again. 

To boot just the A53 cores with built-in DTB (default created by the scripts)
```
tftpboot 0x100000 vxWorks_a53.bin
go 0x100000
```

### Case 3: Booting only on R5 Core with Ethernet NIC from u-boot
This is useful for debugging on the R5 core via Ethernet.
```
tftpboot 0x78100000 vxWorks_r5_eth.bin
zynqmp tcminit split;cpu 4 release 78100000 split; cpu 0 disable
```

---

## Appendix 2: Set up automatic copy of VxWorks images (makes edit->build->test cycle easier)
If you've imported the projects into Workbench, you can add a command to the `.wrmakefile` in the VIP that will automatically copy the `vxWorks.bin` file to your tftp server. 

First, open `.wrmakefile` in the VxWorks Image Project directory.
- On Linux hosts, hit `ctrl-H` in file browser to reveal hidden files

Search for `deploy_output` in `.wrmakefile` and add your OS copy commands. Note that the extra copy commands will persist only as long as you do `Build Project` in Workbench. If you do a `Rebuild Project` they'll be wiped out, since `.wrmakefile` gets refreshed.

```
# entry point for deploying output after the build
deploy_output ::
	@echo "deploy_output"
	cp default/vxWorks.bin /tftpboot/vxWorks_a53.bin
```
---

## Appendix 3: Making the KR260 boot automatically without altering the QSPI contents.
The KR260 is hardwired to boot from QSPI (as far as I can tell) so to change the boot behavior, you either have to rebuild/reprogram the QSPI u-boot program or environment. The alternative is to leave the factory QSPI u-boot as is, and provide a `boot.scr.uimg` file on a FAT32 formatted microSD card. 

See the instructions in the `boot` directory README.md file

---

## Appendix 4: Working with the FDT Generic Driver

The FDT Generic Driver is a simplistic driver template that's useful for memory mapping. In this case we're using it to provide shared memory between the A53 and R5 cores. 

In order to add the FDT Template driver you have to do it with vxprj like this (the script does this for you):
```
vxprj vip component add DRV_TEMPLATE_FDT_MAP
```

Commands to work with the FDT Generic Driver
```
vxbDevShow() // shows info for all vxBus Devices
fdtGenericDevShow()  // shows info about the memory location etc
vmContextShow()
```

on R5 dump memory with physical address
```
fdtGenericDevShow
d 0x76000000
```

on A53 dump memory with virtual address (your actual address may vary)
```
fdtGenericDevShow
d 0xffff800002940000
```
NOTE: You must run `fdtGenericDevShow` in order to get the correct virtual address

write some data into shared memory on the R5 and dump on the A53 side
```
on R5: sprintf( 0x76000000, "This is a test.", 15)
on R5: sprintf( 0x76000000, "foo bar baz xxx", 15)
on A53: d 0xffff800002930000

on A53: sprintf(0xffff800002930000, "xxxxxxxxxxxxxxx",15)
on R5: d 0x76000000
```

## Appendix 5: Running the RTOS Benchmark

VxWorks includes a benchmark that's part of the Zephyr Project: https://github.com/zephyrproject-rtos/rtos-benchmark/tree/main

The Benchmark instructions say to run the benchmark without the network in order to get meaningful results. Therefore an extra script has been added to build the properly configured image for the benchmark. In order to build the benchmark, cd into the top-level `kr260_demo` folder, and run script 4:

```
cd path/to/kr260_demo
./01_set_wrenv.sh
./04_create_a53_bench.sh
```

Note that there are two possible benchmarks: a non-POSIX version (using native VxWorks APIs) and the POSIX version (using POSIX APIs). You can select which one by uncommenting only one of these lines:
```
vxprj vip component add $VIP_NAME INCLUDE_RTOS_BENCHMARK_NONPOSIX
#vxprj vip component add $VIP_NAME INCLUDE_RTOS_BENCHMARK_POSIX
```

Check that the 
```
[path/to/kr260_demo]/build/kr260_a53-vsb/usr/root/llvm/bin
```

and verify that a file called `rtos_benchmark_non_posix.vxe` or `rtos_benchmark_posix.vxe` is there. 

Next, open the workspace in Workbench and import the Benchmark versions of the A53 VSB and VIP projects. 

#### Create a ROMFS project and add the RTOS Benchmark VXE file(s)
With Workbench open and the benchmark projects imported, do the following:
- right-click on VIP project line in the project explorer window
- select `New->Wind River Workbench Project` in the context menu
- select `ROMFS File System` from the project list
- type a name like `romfs` or similar for the project (name doesn't matter)
> Note: if the ROMFS project isn't included in the `kr260_a53_bench` VIP project, then drag and drop the ROMFS project into the VIP project and build. 

![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/01-new-project.png)
![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/02-romfs-project.png)
![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/03-romfs-proj-name.png)


Next a ROMFS configuration tool will open in the center window. 
- click on `Add External` and navigate to the location of the file(s) 
- after that you should see the VxWorks executable or `VXE` file in the right pane. 

![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/04_add_external.png)
![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/05-vxe-added.png)

The VIP project should look like this:

![](https://github.com/rmoorewrs/kr260_demo/blob/main/pics/06-romfs-in-proj-explorer.png)


Now when you build your VIP project, it will include the `rtos_benchmark_non_posix.vxe` which will be located in `/romfs/rtos_benchmark_non_posix.vxe` on the target. 

### How to run the benchmark
Depending on the VIP configuration, the benchmark may run automatically on bootup. Otherwise, to run it manually:
```
-> lkup "rtos"
-> rtosBenchmarkRun
```

The results will look something like this:

```
Rtos-benchmark Testing for non-POSIX APIs:
Platform information:
-> AMD KR260-A53
VxWorks (for AMD KR260-A53) version SMP 64-bit
Kernel: Core Kernel version: 3.2.4.0
Made on Dec 11 2025 16:18:40

System Configurations:
    - System tick clock frequency: 1000 Hz
    - Task CPU affinity on core: 1
    - Main task priority: 50
    - POSIX high-res clock timer resolution: 11 ns
        - Timer frequency from clock_gettime(): 1000000000 Hz

 *** Starting! ***

** Thread stats [avg, min, max] in nanoseconds **
 Spawn (no context switch)               :  39100,  35773,  83009
 Create (no context switch)              :  36348,  35103,  77808
 Start  (no context switch)              :   1700,   1600,   3230
 Suspend (no context switch)             :   1774,   1690,   3530
 Resume (no context switch)              :   1453,   1410,   1581
 Spawn (context switch)                  :  39686,  36284, 126963
 Start  (context switch)                 :   2578,   2351,   4260
 Suspend (context switch)                :   2498,   2340,   4291
 Resume (context switch)                 :   1909,   1800,   2410
 Terminate (context switch)              :  52766,  51855,  57475
** Mutex Stats [avg, min, max] in nanoseconds **
 Lock (no owner)                         :    810,    810,   1150
 Unlock (no waiters)                     :    820,    820,    970
 Recursive lock                          :    820,    820,    840
 Recursive unlock                        :    790,    790,    830
 Unlock with unpend (no context switch)  :   2282,   2170,   4660
 Unlock with unpend (context switch)     :   3017,   2831,   5351
 Pend (no priority inheritance)          :   3462,   3230,   5721
 Pend (priority inheritance)             :   3838,   3590,   5501
** Semaphore stats [avg, min, max] in nanoseconds **
 Take (context switch)                   :   2595,   2440,   4761
 Give (context switch)                   :   2057,   1960,   2661
** Semaphore stats [avg, min, max] in nanoseconds **
 Give (no context switch)                :    790,    790,    961
 Take (no context switch)                :    780,    780,   1071
** Yield stats [avg, min, max] in nanoseconds **
 Yield (no context switch)               :   1343,   1270,   3080
 Yield (context switch)                  :   1561,   1491,   3450
** Allocation stats [avg, min, max] in nanoseconds **
 Malloc                                  :    902,    880,   8161
 Free                                    :   1571,   1560,   2620
** Message queue stats [avg, min, max] in nanoseconds **
 Create                                  :   2516,   2390,   9961
 Send (no context switch)                :   2099,   2050,   5670
 Receive (no context switch)             :   2020,   1960,   3631
 Send (context switch)                   :   3596,   3450,   6071
 Receive (context switch)                :   3567,   3380,   6350

 *** Done! ***
```
