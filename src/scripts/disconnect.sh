#!/bin/bash

printf "VPN client disconnecting...\n"
printf "Deleting VPN configuration and credentials\n"
case $PLATFORM in
  Linux)
    sudo killall openvpn
    rm -f /tmp/config.ovpn
    rm -f /tmp/vpn.login
    ;;
  Windows)
    net stop "OpenVPN Client"
    rm -f /C/PROGRA~1/OpenVPN/config/config.ovpn
    rm -f /C/PROGRA~1/OpenVPN/config/vpn.login
    ;;
  macOS)
    sudo launchctl stop org.openvpn
    rm -f /tmp/config.ovpn
    rm -f /tmp/vpn.login
    ;;
esac
printf "\nVPN disconnected\n"