#!/bin/sh
#
# This script, when saved to /mnt/emmc/de/user_init.sh
# will be called by the custom minized-mount.sh script at
# boot time
#

export PATH=/sbin:/usr/sbin:/usr/local/bin:$PATH

echo "Running $0..."

# Turn off PS LED
devmem 0xe000a244 32 0x00300000
devmem 0xe000a248 32 0x00300000
devmem 0xe000a044 32 0x000cff00

# If an openssh rsa key exists at /mnt/emmc
# convert it to dropbear format and install
# This prevents dropbear needing to generate
# a new key on every boot.
# The way that dropbear looks for existing keys
# is defined in /etc/rc0.d/K10dropbear. A suitable
# openssh key may be generated thus:
# ssh-keygen -t rsa -f openssh_rsa_host_key -P ""
# then upload that file to minized /mnt/emmc
OPENSSH_RSA_HOST_KEY=/mnt/emmc/de/openssh_rsa_host_key
if [ -e  "${OPENSSH_RSA_HOST_KEY}" ]
then
    echo "Copying RSA host key from ${OPENSSH_RSA_HOST_KEY}"
    dropbearconvert openssh dropbear ${OPENSSH_RSA_HOST_KEY} \
                    /etc/dropbear/dropbear_rsa_host_key
fi

# Now do a similar thing with authorized_keys
AUTHORIZED_KEYS=/mnt/emmc/de/authorized_keys
KEYS_INSTALL=/home/root/.ssh
if [ -e "${AUTHORIZED_KEYS}" ]
then
    echo "Copying authorized_keys from ${AUTHORIZED_KEYS}"
    mkdir -m 700 ${KEYS_INSTALL}
    cp "${AUTHORIZED_KEYS}" ${KEYS_INSTALL}
    chmod 600 ${KEYS_INSTALL}/authorized_keys
fi

# Decrease kernel loglevel to 3, for some reason is set to 7 at boot
# even though the default is 3
dmesg -n 3

# Test to see if wifi is already up. This condition is for when this script
# is called by the setup_ssh.sh script on an already running board in oreder
# to setup ssh

ifconfig wlan0 | grep "UP" >> /dev/null
RET=$?
if [ $RET -ne "0" ]
then
    echo "Setting up Wifi"
    /usr/local/bin/wifi.sh
    /sbin/ifconfig wlan0 192.168.1.16
fi

if ping -c1 -W1 google.com
then
    #green LED on
    devmem 0xe000a044 32 0x002cff00

    # Try to set date from Google
    date -s "$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z"


    
else
    #red LED on
    devmem 0xe000a044 32 0x001cff00
fi

echo "$0 Exiting"

exit 0
