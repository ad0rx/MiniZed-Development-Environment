# Source this file
#
# Setup ssh environment for publickey authentication
# with the MiniZed for easy login and file moving
# operations

#set -e
ME="setup_ssh.sh"

if [ -z ${PROJWS} ]
then
    echo "Environment variable PROJWS is not set and script cannot continue"
    echo "Please set this variable to the path to where we can work"
    echo "an example is: export PROJWS=/home/${USER}/myproj"
    echo "Exiting..."
fi

# Source the setup file
. ${PROJWS}/bin/setup.sh

P_PRINT ${ME} "Running\n"

export MZ_SSH_OPTIONS=" -o UserKnownHostsFile=${PROJ_SSH_PATH}/known_hosts -o PreferredAuthentications=publickey"
export MZ_SSH="ssh ${MZ_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa root@${MZ_IP}"

# Can we log in with publickey?
# The && at the end is a hack to make bash ignore the return value of the command.
# Because of the "set -e" context, if this command fails, the script will terminate.
# set -e is not set in this file, but it is set in files that source this one.
ssh ${MZ_SSH_OPTIONS} -o BatchMode=yes -i ${PROJ_SSH_PATH}/id_rsa  root@${MZ_IP} exit && true
RET=$?
if [ "${RET}" -ne 0 ]
then

    if [ -e "${PROJ_SSH_PATH}" ]
    then
        P_PRINT "${ME}" "Removing ${PROJ_SSH_PATH}"
        rm -rf "${PROJ_SSH_PATH}"
    fi

    P_PRINT "\n${ME}" "Creating ${PROJ_SSH_PATH}"
    mkdir -m=700 "${PROJ_SSH_PATH}"
    touch "${PROJ_SSH_PATH}/known_hosts"

    # Create a keypair if needed
    # Generate a new id, only do this if one does not yet exist
    if [ ! -e "${PROJ_SSH_PATH}/id_rsa" ]
    then
        P_PRINT "\n${ME}" "Creating shared keys"
        ssh-keygen -q -f "${PROJ_SSH_PATH}/id_rsa" -P ""
    fi

    # Copy id to the board so no login password necessary in the future    
    ssh-copy-id -o UserKnownHostsFile="${PROJ_SSH_PATH}/known_hosts" -i "${PROJ_SSH_PATH}/id_rsa" root@${MZ_IP} 
    #ssh-copy-id -o UserKnownHostsFile=${PROJ_SSH_PATH}/known_hosts -i "${PROJ_SSH_PATH}/id_rsa" root@${MZ_IP} 
fi

alias mzssh="${MZ_SSH}"

P_PRINT ${ME} "Exiting\n"
