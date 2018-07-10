#!/bin/bash
#
# This script is executed by the bin/derun script
# from command line of development host like this
# > derun $PROJWS/bin/remote/program_qspi.sh
#
# The commands below are executed on the dev board
#
BOOT_BIN=/mnt/emmc/BOOT.BIN

echo "Writing BOOT.BIN to flash"
flashcp -v $BOOT_BIN /dev/mtd0

echo "Rebooting..."
reboot

