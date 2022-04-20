#!/bin/bash

install() {
    case $1 in
    [Ll]inux*)
        printf "Installing OpenVPN client for Linux\n\n"
        sudo apt-get update
        sudo apt-get install openvpn openvpn-systemd-resolved
        PLATFORM=Linux
        ;;
    [Dd]arwin*)
        printf "Installing OpenVPN client for macOS\n\n"
        HOMEBREW_NO_AUTO_UPDATE=1 brew install openvpn
        curl https://raw.githubusercontent.com/andrewgdotcom/openvpn-mac-dns/master/etc/openvpn/update-resolv-conf --output /tmp/update-resolv-conf
        chmod +x /tmp/update-resolv-conf
        PLATFORM=macOS
        ;;
    msys*|MSYS*|nt|[Ww]in*|NT|WIN*)
        printf "Installing OpenVPN client for Windows\n\n"
        choco install openvpn
        PLATFORM=Windows
        ;;
    esac
}

install "$(uname)"

setup-Linux() {
echo $VPN_CONFIG | base64 --decode > /tmp/config.ovpn

if grep -q auth-user-pass /tmp/config.ovpn; then
  if [ -z "${VPN_USER:-}" ] || [ -z "${VPN_PASSWORD:-}" ]; then
    echo "Your VPN client is configured with a user-locked profile. Make sure to set the VPN_USER and VPN_PASSWORD environment variables"
    exit 1
  else
    printf "%s\\n%s" > "$VPN_USER" "$VPN_PASSWORD" /tmp/vpn.login
  fi
fi
}

setup-Windows() {
cd "/C/progra~1/OpenVPN/config" || exit
echo $VPN_CONFIG | base64 --decode > config.ovpn

if grep -q auth-user-pass config.ovpn; then
  if [ -z "${VPN_USER:-}" ] || [ -z "${VPN_PASSWORD:-}" ]; then
    echo "Your VPN client is configured with a user-locked profile. Make sure to set the VPN_USER and VPN_PASSWORD environment variables"
    exit 1
  else
    printf "%s\\n%s" > "$VPN_USER" "$VPN_PASSWORD" /tmp/vpn.login
    sed -i 's|^auth-user-pass.*|auth-user-pass vpn\.login|' /C/PROGRA~1/OpenVPN/config/config.ovpn
  fi
fi
}

setup-macOS() {
echo $VPN_CONFIG | base64 --decode | tee /tmp/config.ovpn 1>/dev/null

if grep -q auth-user-pass /tmp/config.ovpn; then
  if [ -z "${VPN_USER:-}" ] || [ -z "${VPN_PASSWORD:-}" ]; then
    echo "Your VPN client is configured with a user-locked profile. Make sure to set the VPN_USER and VPN_PASSWORD environment variables"
    exit 1
  else
    printf "%s\\n%s" > "$VPN_USER" "$VPN_PASSWORD" /tmp/vpn.login
    sed -i config.bak 's|^auth-user-pass.*|auth-user-pass /tmp/vpn\.login|' /tmp/config.ovpn
  fi
fi
}
setup-$PLATFORM

printf "\nOpenVPN client for %s installed and configured\n\n" "$PLATFORM"

printf "\nPublic IP before VPN connection is %s\n" "$(curl http://checkip.amazonaws.com)"

echo "export PLATFORM=$PLATFORM" >> $BASH_ENV