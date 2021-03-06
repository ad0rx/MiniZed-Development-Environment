#!/bin/bash
#
# This script is only to be used to generate the project's SDx
# application project template which is kept in revision control
# system. The way to use it is to build a sdx application project from
# scratch, configure the project as needed and then exit SDX and run
# this script. THen commit the resulting sdx project to git repo
#
# create a project under work/sdx_application_project
#
# Things to setup
# build with 4 cores
# sources linked
# mark for hardware
# font
# tcf agent
# window layout
# do a build and debug session
# debug as
# clean
# close sdx
# then run this
#

if [ -z "$1" ]
then
    echo
    echo "USAGE: sdx_app_from_template.sh <TEMPLATE_PROJECT>"
    echo
    exit 1
fi

. ${PROJWS}/bin/setup.sh

#TEMPLATE_PROJECT=${PROJ_SDX_APP_PROJECT_PATH}
TEMPLATE_PROJECT=$1
TEMPORARY_PROJECT=${PROJWS}/work/temporary_sdx_application_project
FINAL_TARBALL=${PROJ_SDX_SUPPORT_PATH}/minized/sdx_application_project_template.tar.gz

rm -rf ${TEMPORARY_PROJECT}
cp -r  ${TEMPLATE_PROJECT} ${TEMPORARY_PROJECT}
rm -rf ${TEMPORARY_PROJECT}/ip_cache

# Remove log files
find ${TEMPORARY_PROJECT} -name "*log" -print0 | xargs -0 rm -f

# Remove project local src files so not to confuse user later on
find ${TEMPORARY_PROJECT} -name "mz_header.h"     -print0 | xargs -0 rm -f
find ${TEMPORARY_PROJECT} -name "read_stream.cpp" -print0 | xargs -0 rm -f

# Replace paths specific to local machine with markers that will be used by gen_sdx_app_project.sh
grep -rl ${PROJ_SDX_PFM_PROJECT_PATH} ${TEMPORARY_PROJECT} | xargs sed -i "s:${PROJ_SDX_PFM_PROJECT_PATH}:\<PROJ_SDX_PFM_PROJECT_PATH\>:g"
grep -rl ${PROJ_SDX_APP_PROJECT_PATH} ${TEMPORARY_PROJECT} | xargs sed -i "s:${PROJ_SDX_APP_PROJECT_PATH}:\<PROJ_SDX_APP_PROJECT_PATH\>:g"
grep -rl ${PROJ_SDX_SUPPORT_PATH}     ${TEMPORARY_PROJECT} | xargs sed -i "s:${PROJ_SDX_SUPPORT_PATH}:\<PROJ_SDX_SUPPORT_PATH\>:g"

echo "creating tarball"
rm -rf ${FINAL_TARBALL}
tar -C ${TEMPORARY_PROJECT} -czf ${FINAL_TARBALL} .
rm -rf ${TEMPORARY_PROJECT}

echo "done"

