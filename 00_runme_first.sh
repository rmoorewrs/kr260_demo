#!/bin/sh
echo "****************************"
echo "-Step one: edit the project_params.sh file to set your install path, IP addresses, etc"
echo " "
echo "-Step two: run the Wind River environment setup: ./01_setup_wrenv.sh"
echo " "
echo "-Step three: run the 02_create_a53.sh and optionally, the 03_create_r5.sh and 99_create_r5_only_eth_vip.sh scripts"
echo " "
echo "-Note: run all scripts from this top-level directory, not from the build directory"
echo " "
echo "after building, you can import the project into Workbench, see README.md for instructions"
echo "****************************"
mkdir -p build
