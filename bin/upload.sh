#!/bin/bash
#
# Uploads files specified in local variable to the board. To be used
# after SDx build
#
set -e
ME="upload.sh"

if [ -z ${PROJWS} ]
then
    echo "Environment variable PROJWS is not set and script cannot continue"
    echo "Please set this variable to the path to where we can work"
    echo "an example is: export PROJWS=/home/${USER}/myproj"
    echo "Exiting..."
    exit 1
fi

# Source the setup file
. ${PROJWS}/bin/setup.sh
. ${PROJWS}/bin/setup_ssh.sh

P_PRINT ${ME} "Running\n"

FILES_TO_UPLOAD="${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/Debug/sd_card/BOOT.BIN"
FILES_TO_UPLOAD+=" ${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/Debug/sd_card/image.ub"
FILES_TO_UPLOAD+=" ${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/Debug/sd_card/mz_stream_petalinux.elf"

scp ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa ${FILES_TO_UPLOAD} root@${MZ_IP}:/mnt/emmc

P_PRINT ${ME} "Exiting\n"
