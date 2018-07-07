#!/bin/sh
# Add any custom code to be run at startup in this file
#

P_PRINT()
{
    echo -e "\nminized-mount.sh: $1\n"
}

P_PRINT "Running Minized Startup Script ..."

P_PRINT "echo Mounting /dev/mmcblk1p1 on /mnt/emmc"
mkdir /mnt/emmc
mount /dev/mmcblk1p1 /mnt/emmc

P_PRINT "Mounting /dev/sda1 on /mnt/usb"
mkdir /mnt/usb
mount /dev/sda1 /mnt/usb

# Run a User's init/startup script if exists
if [ -e /mnt/emmc/user_minized_init.sh ]
then
    /mnt/emmc/user_minized_init.sh
fi

# If an openssh rsa key exists at /mnt/emmc
# convert it to dropbear format and install
# This prevents dropbear needing to generate
# a new key on every boot.
# The way that dropbear looks for existing keys
# is defined in /etc/rc0.d/K10dropbear. A suitable
# openssh key may be generated thus:
# ssh-keygen -t rsa -f openssh_rsa_host_key -P ""
# then upload that file to minized /mnt/emmc
OPENSSH_RSA_HOST_KEY=/mnt/emmc/openssh_rsa_host_key
if [ -e  "${OPENSSH_RSA_HOST_KEY}" ]
then
    P_PRINT "Copying RSA host key from ${OPENSSH_RSA_HOST_KEY}"
    dropbearconvert openssh dropbear ${OPENSSH_RSA_HOST_KEY} \
                    /etc/dropbear/dropbear_rsa_host_key
fi

# Now do a similar thing with authorized_keys
AUTHORIZED_KEYS=/mnt/emmc/authorized_keys
KEYS_INSTALL=/home/root/.ssh
if [ -e "${AUTHORIZED_KEYS}" ]
then
    P_PRINT "Copying authorized_keys from ${AUTHORIZED_KEYS}"
    mkdir -m 700 ${KEYS_INSTALL}
    cp "${AUTHORIZED_KEYS}" ${KEYS_INSTALL}
    chmod 600 ${KEYS_INSTALL}/authorized_keys
fi

# Decrease kernel loglevel to 3, for some reason is set to 7 at boot
# even though the default is 3
dmesg -n 3

P_PRINT "MiniZed Startup Script DONE!"
