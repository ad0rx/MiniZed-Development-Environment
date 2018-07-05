#!/bin/bash
#
# Build the PetaLinux project which will become the
# software platform for the SDx platform

set -e
ME="gen_petalinux_project.sh"

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

BSP_ZIP="minized_1.zip"
BSP="minized.bsp"
PETALINUX_PROJECT_NAME=sdx_minized
HDF_PATH=${PROJ_HW_PROJECT_PATH}

P_PRINT "\n${ME}" "Running"

# Make sure to get a clean build
if [ -e "${PROJ_PLNX_PROJECT_PATH}" ]
then
    rm -rf "${PROJ_PLNX_PROJECT_PATH}"
fi

mkdir -p "${PROJ_PLNX_PROJECT_PATH}"

# Extract the BSP, which contains the MiniZed reference hardware
# Vivado project
unzip "${PROJ_AVNET_SUPPORT_PATH}/${BSP_ZIP}" -d "${PROJ_PLNX_PROJECT_PATH}"

# Source the PetaLinux settings
${SP}

# Generate a fresh MiniZed project based on the 2017.4 MiniZed BSP
cd "${PROJ_PLNX_PROJECT_PATH}"
rm -rf ${PETALINUX_PROJECT_NAME}
petalinux-create -t project -s ${PROJ_PLNX_PROJECT_PATH}/${BSP} \
  --name ${PETALINUX_PROJECT_NAME}

# Import the new hardware definition
clear; echo; echo "*** Importing New HDF ***"; echo
echo "When the menuconfig pops up - exit without making changes"; echo
sleep 5
petalinux-config -p ${PETALINUX_PROJECT_NAME} \
  --get-hw-description=${HDF_PATH}

# Add custom dtsi file which enables APF driver for SDx
cp ${PROJWS}/support/petalinux/system-user.dtsi \
   ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-bsp/device-tree/files/system-user.dtsi

# Disable all unnecessry components as they are not needed for basic SDx demo
cp ${PROJWS}/support/petalinux/petalinux-user-image.bbappend \
   ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-core/images/

# Fix build error related to brcmfmac43430-sdio.bin
cp ${PROJWS}/support/petalinux/minized-wireless_2017.4.bb \
   ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-bsp/minized-wireless/minized-wireless_2017.4.bb

# Add custom minized-mount.sh script which calls
# /mnt/emmc/user_minized_init.sh
cp ${PROJWS}/support/petalinux/minized-mount.sh \
   ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-bsp/minized-misc/files

clear; echo; echo "*** Configuring Kernel Per UG1146 ***"; echo
sleep 5
cp ${PROJWS}/support/petalinux/sdx_kernel_configs.cfg \
   ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx/user_sdx.cfg
echo 'SRC_URI += "file://user_sdx.cfg"' >> \
  ${PETALINUX_PROJECT_NAME}/project-spec/meta-user/recipes-kernel/linux/linux-xlnx_%.bbappend
petalinux-config -p ${PETALINUX_PROJECT_NAME} -c kernel --oldconfig

clear; echo; echo "*** Configuring Rootfs Per UG1146 ***"; echo
sleep 5
cp ${PROJWS}/support/petalinux/rootfs_config \
   ${PETALINUX_PROJECT_NAME}/project-spec/configs/rootfs_config
petalinux-config -p ${PETALINUX_PROJECT_NAME} -c rootfs --oldconfig

# Build the petalinux project, this will take a while
clear; echo; echo "*** Preparing to build the PetaLinux Distribution ***";
echo "*** Get comfortable, this will just take a bit... ***"; echo
sleep 5
petalinux-build -p ${PETALINUX_PROJECT_NAME}

# Create boot directory and bif file for SDx Platform
mkdir ${PETALINUX_PROJECT_NAME}/images/linux/boot
mkdir ${PETALINUX_PROJECT_NAME}/images/linux/image
cp    ${PETALINUX_PROJECT_NAME}/images/linux/u-boot.elf \
      ${PETALINUX_PROJECT_NAME}/images/linux/boot/u-boot.elf

cp    ${PETALINUX_PROJECT_NAME}/images/linux/*fsbl.elf  \
      ${PETALINUX_PROJECT_NAME}/images/linux/boot/fsbl.elf

cp    ${PETALINUX_PROJECT_NAME}/images/linux/image.ub   \
      ${PETALINUX_PROJECT_NAME}/images/linux/image/image.ub

cp    ${PROJWS}/support/petalinux/sdx_pfm.bif           \
      ${PETALINUX_PROJECT_NAME}/images/linux/boot/sdx_pfm.bif

# might need to reset the board using reset button before able to connect
# change IP address to suit
# Put board into JTAG boot mode
#cd {$PROJWS}/${PETALINUX_PROJECT_NAME} && petalinux-boot --jtag --hw_server-url 192.168.1.21:3121 --fpga --kernel

P_PRINT ${ME} "Exiting\n"

