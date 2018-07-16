#!/bin/bash
#
# Generate the application project for SDx
#
# Using a tarball here because the eclipse plugin dir has about 450
# files that are pretty much irrelevent.
#
# Still in experimental state...

set -e
ME="gen_sdx_application_project.sh"

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

if [ -e "${PROJ_SDX_APP_PROJECT_PATH}" ]
then
    P_PRINT ${ME} "Removing existing SDx app project\n"
    rm -rf "${PROJ_SDX_APP_PROJECT_PATH}"
fi
mkdir -p "${PROJ_SDX_APP_PROJECT_PATH}"

tar -xzf ${PROJ_SDX_SUPPORT_PATH}/minized/sdx_application_project_template.tar.gz -C ${PROJ_SDX_APP_PROJECT_PATH}

# Now fixup the pathing in the project files to work on the local
# machine
grep -rl "\<PROJ_SDX_PFM_PROJECT_PATH\>" ${PROJ_SDX_APP_PROJECT_PATH} | xargs sed -i "s:<PROJ_SDX_PFM_PROJECT_PATH>:${PROJ_SDX_PFM_PROJECT_PATH}:g"
grep -rl "\<PROJ_SDX_APP_PROJECT_PATH\>" ${PROJ_SDX_APP_PROJECT_PATH} | xargs sed -i "s:<PROJ_SDX_APP_PROJECT_PATH>:${PROJ_SDX_APP_PROJECT_PATH}:g"

# Copy over the files that are not linked in SDx project so that the
# user does not get stale versions
cp ${PROJ_SDX_SUPPORT_PATH}/src/mz_header.h     ${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/src/
cp ${PROJ_SDX_SUPPORT_PATH}/src/read_stream.cpp ${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/src/

# The following commands will open the SDx GUI
#$SSDX
#sdx -workspace "${PROJ_SDX_APP_PROJECT_PATH}"

# The following commands will automaticall build the SDx project
cd "${PROJ_SDX_APP_PROJECT_PATH}/mz_stream_petalinux/Debug"
$SSDX
make -j4 pre-build main-build

P_PRINT ${ME} "Exiting\n"
