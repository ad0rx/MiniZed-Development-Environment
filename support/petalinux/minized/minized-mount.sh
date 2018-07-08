#!/bin/sh
# Add any custom code to be run at startup in this file
#

P_PRINT()
{
    echo -e "\nminized-mount.sh: $1\n"
}

P_PRINT "Running Minized Startup Script ..."

P_PRINT "echo Mounting /dev/mmcblk1p1 on /mnt/emmc"
mkdir /mnt/emmc
mount /dev/mmcblk1p1 /mnt/emmc

P_PRINT "Mounting /dev/sda1 on /mnt/usb"
mkdir /mnt/usb
mount /dev/sda1 /mnt/usb

# Run a User's init/startup script if exists
if [ -e /mnt/emmc/de/user_init.sh ]
then
    /mnt/emmc/de/user_init.sh
fi

P_PRINT "MiniZed Startup Script DONE!"
