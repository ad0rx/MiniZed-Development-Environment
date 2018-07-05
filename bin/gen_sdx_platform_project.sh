#!/bin/bash
#
# Generate the platform project for SDx
#

set -e
ME="gen_sdx_platform_project.sh"

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

P_PRINT ${ME} "Running\n"

# Create app dir if not there already
#if [ ! -e "${PROJ_SDX_APP_PROJECT_PATH}" ]
#then
#    mkdir -p "${PROJ_SDX_APP_PROJECT_PATH}"
#fi

# Make sure to get a clean build
if [ -e "${PROJ_SDX_PFM_PROJECT_PATH}" ]
then
    rm -rf "${PROJ_SDX_PFM_PROJECT_PATH}"
fi
mkdir -p "${PROJ_SDX_PFM_PROJECT_PATH}"
cd "${PROJ_SDX_PFM_PROJECT_PATH}"

# Source SDx Settings
${SSDX}

# Use xsct to run the tcl script
${XSCT} ${PROJWS}/support/sdx/gen_sdx_platform_project.tcl

P_PRINT ${ME} "Exiting\n"
