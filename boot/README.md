# u-boot script for microSD card

The KR260 starter kit is hardwired to only boot from QSPI so in order to customize the boot process, the OOB factory u-boot searches the microSD card for a boot script (boot.scr.uimg). 

Edit the contents of boot.cmd, or create your own script and then create the boot script image like this:

```
mkimage -c none -A arm -T script -d boot.cmd boot.scr.uimg
```

> Note: you need to install the Debian package `u-boot-tools` in order to get mkimage

Copy the `boot.scr.uimg` file to a FAT32 formatted microSD card and the QSPI u-boot will run whatever u-boot commands you place in there after running its own internal script. 

> Note: this assumes the u-boot in QSPI hasn't been changed from the factory delivered image.
