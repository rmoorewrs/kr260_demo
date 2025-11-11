# VxWorks on the AMD Kria KR260
These scripts build a kernel for the A53 and R5 processors on the Zynq Ultrascale+ MPSoC. See the main `README.md` file for full details. 

The scripts will work on both Windows and supported Linux development hosts.

## Step 1: Clone the Project
Open the right shell for your Host OS
- `bash` for Linux
- `cmd` for Windows (powershell may or may not work)
```
git clone https://github.com/rmoorewrs/kr260_demo.git
cd kr260_demo
```
 
## Step 2: Edit the Setup Script
Edit the `01_setup_wrenv` script for your Host OS (Windows or Linux) to match your VxWorks installation and Desired IP settings

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

## Step 3
- run `./01_setup_wrenv.sh` to set up the VxWorks build environment
 
## Step 4
- run `./02_create_a53.sh` to create the VxWorks kernel for the main A53 application processors

## Step 5
- run `./03_create_r5.sh` to create the VxWorks kernel for the R5 realtime processor


## Optional: 
In some cases you may want to attach the Ethernet NIC to the R5 processor and not run the A53 cores. 
- run `./99_create_r5_only_eth_vip.sh`

>Note: this works on the ZCU102 board, but requires more work on the KR260. 

 
After building, you can import the project into Workbench, see `README.md` for instructions

