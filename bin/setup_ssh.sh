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

SSH_TEMP=${PROJWS}/temp
HOST_ID_FILE=${SSH_TEMP}/openssh_rsa_host_key
AUTHORIZED_KEYS=${SSH_TEMP}/authorized_keys
USER_INIT_SH=${PROJWS}/support/petalinux/minized/user_init.sh

P_PRINT "\n${ME}" "Running\n"

export DE_SSH_OPTIONS=" -o UserKnownHostsFile=${PROJ_SSH_PATH}/known_hosts -o PreferredAuthentications=publickey"
export DE_SSH="ssh ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa root@${MZ_IP}"
export DE_SCP="scp ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa"

# Can we log in with publickey?
# The && at the end is a hack to make bash ignore the return value of the command.
# Because of the "set -e" context, if this command fails, the script will terminate.
# set -e is not set in this file, but it is set in files that source this one.
ssh ${DE_SSH_OPTIONS} -o BatchMode=yes -i ${PROJ_SSH_PATH}/id_rsa  root@${MZ_IP} exit && true
RET=$?
if [ "${RET}" -ne 0 ]
then

    mkdir -p ${SSH_TEMP}
    
    # Not able to log in with public key auth, so set that up now
    if [ -e "${PROJ_SSH_PATH}" ]
    then
        P_PRINT ${ME} "Removing ${PROJ_SSH_PATH}"
        rm -rf "${PROJ_SSH_PATH}"
    fi

    P_PRINT ${ME} "Creating ${PROJ_SSH_PATH}"
    mkdir -m=700 "${PROJ_SSH_PATH}"
    touch "${PROJ_SSH_PATH}/known_hosts"

    P_PRINT ${ME} "Creating key pair"
    ssh-keygen -q -f "${PROJ_SSH_PATH}/id_rsa" -P ""

    # Create authorized_keys to be used by board
    cp "${PROJ_SSH_PATH}/id_rsa.pub" ${AUTHORIZED_KEYS}

    # Create host id to be used by the board
    P_PRINT ${ME} "Creating host key for board"
    rm -f ${HOST_ID_FILE}
    ssh-keygen -q -f ${HOST_ID_FILE} -P ""

    # Add board host id to local known hosts file
    #TBD

    # Copy id to the board, this will enable easy copying of the following files
    ssh-copy-id -o UserKnownHostsFile="${PROJ_SSH_PATH}/known_hosts" -i "${PROJ_SSH_PATH}/id_rsa" root@${MZ_IP}

    # Make sure the de directory exists, create if needed
    P_PRINT ${ME} "Creating de directory on board"
    ${DE_SSH} mkdir -p /mnt/emmc/de

    # Copy authorized_keys to board
    P_PRINT ${ME} "Copying authorized_keys to the board"
    scp ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa ${AUTHORIZED_KEYS} root@$MZ_IP:/mnt/emmc/de/

    # Copy host id to board
    P_PRINT ${ME} "Copying host id to the board"
    scp ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa ${HOST_ID_FILE} root@$MZ_IP:/mnt/emmc/de/

    # Copy user_init.sh to board
    P_PRINT ${ME} "Copying user init script to the board"
    scp ${DE_SSH_OPTIONS} -i ${PROJ_SSH_PATH}/id_rsa ${USER_INIT_SH} root@$MZ_IP:/mnt/emmc/de/

    # Sync writes to flash
    ${DE_SSH} /bin/sync

    # Run user_init.sh on board
    P_PRINT ${ME} "Running user init script"
    ${DE_SSH} /mnt/emmc/de/user_init.sh

    # Restart Dropbear
    ${DE_SSH} /etc/rc0.d/K10dropbear restart

    # Remove stale known_hosts on local machine
    # and replace with the dropbearconvert'ed host key from the board
    #P_PRINT ${ME} "Updating known_hosts"
    ssh-keyscan -t rsa $MZ_IP > ${PROJ_SSH_PATH}/known_hosts

    # cleanup
    rm -rf ${SSH_TEMP}
    
fi

# The following functions will be available at the command line and
# can replace ssh/scp for easy access to the devel board
# The reason for sourcing this file in the function is to make sure
# that scp and ssh are setup and working before trying to actually ssh/scp.
function descp ()
{
    . ${PROJWS}/bin/setup_ssh.sh
    #echo "${DE_SCP} $*"
    ${DE_SCP} $*
}
export -f descp

function dessh ()
{
    . ${PROJWS}/bin/setup_ssh.sh
    #echo "${DE_SSH} $*"
    ${DE_SSH} $*
}
export -f dessh


P_PRINT ${ME} "Exiting\n"
