#!/bin/bash
#
# Cleanup script
# Remove all generated collateral under the work directory
#

set -e
ME="clean.sh"

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

P_PRINT "" "*** WARNING: You are about to delete everything"
P_PRINT "" "*** WARNING: under ${PROJ_WORK}. Please make sure"
P_PRINT "" "*** WARNING: you have saved all edited files elsewhere"
P_PRINT "" "*** WARNING: PRESS 'Y' to continue"
read -n1 YN
echo
if [ ${YN} != 'Y' ]
then
    exit 0
fi

if [ -e "${PROJ_WORK}" ]
then
    P_PRINT "${ME}" "Cleaning ${PROJ_WORK}/*"
    rm -rf "${PROJ_WORK}"
fi

P_PRINT "\n${ME}" "Creating Dir ${PROJ_WORK}"
mkdir "${PROJ_WORK}"

P_PRINT ${ME} "Exiting\n"
