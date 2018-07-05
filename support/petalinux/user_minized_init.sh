#!/bin/sh

# Assumed the peekpoke application exists in the distro
# could use native devmem application instead

echo "Running $0..."

echo "Setting up Wifi"
/usr/local/bin/wifi.sh
ifconfig wlan0 192.168.1.16

# Turn off PS LED
poke 0xe000a244 0x00300000
poke 0xe000a248 0x00300000
poke 0xe000a044 0x000cff00

# To turn on PS LED:

#red
#poke 0xe000a044 0x001cff00

#green 
poke 0xe000a044 0x002cff00 

echo "$0 Exiting"

exit 0
