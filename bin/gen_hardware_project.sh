#!/bin/bash
#
# Extract IP from zip files and build the dsa and hdf
# using Vivado Tcl script

set -e
ME="gen_hardware_project.sh"

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

STREAM_IO_SUPPORT_PATH="${PROJ_HW_PROJECT_PATH}/support"
AXI_COUNTER_IP_ZIP="axi_counter_ip.zip"

P_PRINT "\n${ME}" "Running"

# Make sure to get a clean build
if [ -e "${PROJ_HW_PROJECT_PATH}" ]
then
    rm -rf "${PROJ_HW_PROJECT_PATH}"
fi

mkdir -p "${PROJ_HW_PROJECT_PATH}"

# Extract the axi_counter_ip from Tom's Lab's zip archive
unzip -q "${PROJ_AVNET_SUPPORT_PATH}/${AXI_COUNTER_IP_ZIP}" -d "${STREAM_IO_SUPPORT_PATH}"

# Source Vivado settings
${SSDX}

# Build the project using Vivado batch tcl mode
cd "${PROJ_HW_PROJECT_PATH}"
vivado -mode batch -source "${PROJWS}/support/vivado/minized/generate_vivado_project.tcl"

P_PRINT ${ME} "Exiting\n"
