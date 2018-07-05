#!/bin/bash
#
# Top level script which will clean the project and then
# call all generation scripts

set -e
ME="top.sh"

if [ -z ${PROJWS} ]
then
    echo "Environment variable PROJWS is not set and script cannot continue"
    echo "Please set this variable to the path to where we can work"
    echo "an example is: export PROJWS=/home/${USER}/myproj"
    echo "Exiting..."
    exit 1
fi

P_PRINT "\n${ME}" "Running"

# Clean the workspace
clean.sh

# Generate the base hardware
gen_hardware_project.sh

# Generate the petalinux project
gen_petalinux_project.sh

# Generate the sdx platform project
gen_sdx_platform_project.sh

# Generate the sdx application project
# Still in Beta
#gen_sdx_application_project.sh

P_PRINT ${ME} "Exiting\n"
