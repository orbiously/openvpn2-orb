#!/bin/bash

case $PLATFORM in
  Linux)
    sudo killall openvpn
    ;;
  Windows)
    net stop "OpenVPN Client"
    ;;
  macOS)
    sudo launchctl stop org.openvpn
    ;;
esac
printf "\nVPN disconnected\n"