# source this file like this > . setup.sh
# Setup the working environment by exporting various
# environment variables
#

#ME="setup.sh"

# IP of the MiniZed
export MZ_IP=192.168.1.16

# Can't do this because this file gets sourced from various other
# places. Must set PROJWS before calling this
#export PROJWS=$(pwd)

if [ -z ${PROJWS} ]
then
    echo "Environment variable PROJWS is not set and script cannot continue"
    echo "Please set this variable to the path to where we can work"
    echo "an example is: export PROJWS=/home/${USER}/myproj"
    echo "Exiting..."
fi

export PATH="${PROJWS}/bin:${PATH}"

# Path to the work directory. Under this dir will be all the
# script-generated projects
export PROJ_WORK="${PROJWS}/work"
export PROJ_SUPPORT_PATH="${PROJWS}/support"
export PROJ_AVNET_SUPPORT_PATH="${PROJ_SUPPORT_PATH}/avnet"
export PROJ_SDX_SUPPORT_PATH="${PROJ_SUPPORT_PATH}/sdx"
export PROJ_HW_PROJECT_PATH="${PROJ_WORK}/hardware_project"
export PROJ_PLNX_PROJECT_PATH="${PROJ_WORK}/petalinux_project"
export PROJ_SDX_PFM_PROJECT_PATH="${PROJ_WORK}/sdx_platform_project"
export PROJ_SDX_APP_PROJECT_PATH="${PROJ_WORK}/sdx_application_project"

export PROJ_SSH_PATH="${PROJWS}/.ssh"

P_PRINT(){
    echo -e "$1: $2"
}
export -f P_PRINT

# Machine specific settings, leave bubba alone and just create your
# own section
HOSTNAME=$(hostname)
#echo $HOSTNAME
if [ "$HOSTNAME" = "bubba" ]
then

    P_PRINT "setup.sh" "Applying Environment Settings for Bubba"
    export PROJ_NUM_CPU=4
    PETALINUX_SETTINGS=/projects/xilinx_no_bkup/petalinux/2017.4/settings.sh

    # Includes Vivado and XSDK
    # The install on my machine looks goofy so heads-up, your path
    # may have different form
    SDX_SETTINGS=/projects/xilinx_no_bkup/SDx/SDx/2017.4/settings64.sh
    export XSCT=/projects/xilinx_no_bkup/SDx/SDx/2017.4/bin/xsct
    
else if [ "$HOSTNAME" = "myhostname" ]
     then

         P_PRINT "setup.sh" "Applying Environment Settings for myhostname"
         export PROJ_NUM_CPU=4
         PETALINUX_SETTINGS=<>/2017.4/settings.sh

         # Includes Vivado and XSDK
         # The install on my machine looks goofy so heads-up, your path
         # may have different form
         SDX_SETTINGS=<>/SDx/2017.4/settings64.sh
         export XSCT=<>/SDx/2017.4/bin/xsct

     fi
fi
    
export SSDX=". ${SDX_SETTINGS}"
export SP=". ${PETALINUX_SETTINGS}"

