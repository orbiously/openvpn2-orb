#!/bin/bash
if [ -f /.dockerenv ]; then
    printf "OpenVPN cannot be set up with the 'docker' executor\n"
    printf "Please use the Linux 'machine' executor"
else
  printf "VPN client disconnecting...\n"
  printf "Deleting VPN configuration and credentials\n"
  case $PLATFORM in
    Linux)
      sudo killall openvpn || true
      rm -f /tmp/config.ovpn
      if [ -f /tmp/vpn.login ]; then
        rm -f /tmp/vpn.login
      fi
      ;;
    Windows)
      net stop "OpenVPN Client" || true
      rm -f /C/PROGRA~1/OpenVPN/config/config.ovpn
      if [ -f /C/PROGRA~1/OpenVPN/config/vpn.login ]; then
        rm -f /C/PROGRA~1/OpenVPN/config/vpn.login
      fi
      if [ "$DEBUG" = "1" ]; then 
        sleep 2
        cp $CLIENT_LOG /c/tmp/openvpn.log
      fi
      ;;
    macOS)
      sudo launchctl stop org.openvpn || true
      rm -f /tmp/config.ovpn
      if [ -f /tmp/vpn.login ]; then
        rm -f /tmp/vpn.login
      fi
        ;;
    esac
fi

printf "\nVPN disconnected\n"
printf "VPN client configuration and VPN user credentials (if any) removed"