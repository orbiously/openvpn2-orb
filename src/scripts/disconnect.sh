#!/bin/bash

printf "VPN client disconnecting...\n"
printf "Deleting VPN configuration and credentials\n"
case $PLATFORM in
  Linux)
    sudo killall openvpn
    rm -f /tmp/config.ovpn
    if [ -f /tmp/vpn.login ]; then
      rm -f /tmp/vpn.login
    fi
    ;;
  Windows)
    net stop "OpenVPN Client"
    rm -f /C/PROGRA~1/OpenVPN/config/config.ovpn
    if [ -f /C/PROGRA~1/OpenVPN/config/vpn.login ]; then
      rm -f /C/PROGRA~1/OpenVPN/config/vpn.login
    fi
    if [ "$DEBUG" = "1" ]; then 
        sleep 2
        mv $CLIENT_LOG /c/tmp/openvpn.log
    fi
    ;;
  macOS)
    sudo launchctl stop org.openvpn
    rm -f /tmp/config.ovpn
    if [ -f /tmp/vpn.login ]; then
      rm -f /tmp/vpn.login
    fi
    ;;
esac
printf "\nVPN disconnected\n"
printf "VPN client configuration and VPN user credentials (if any) removed"