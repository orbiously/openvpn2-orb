#!/bin/bash

case $PLATFORM in
    Linux)
      vpn_command=(sudo openvpn
        --config /tmp/config.ovpn
        --script-security 2
        --up /etc/openvpn/update-systemd-resolved --up-restart
        --down /etc/openvpn/update-systemd-resolved --down-pre
        --dhcp-option DOMAIN-ROUTE .)

      vpn_command+=(--route 169.254.0.0 255.255.0.0 net_gateway)
      echo "Added route to 169.254.0.0/16 via default gateway"
      if grep -q auth-user-pass /tmp/config.ovpn; then
        vpn_command+=(--auth-user-pass /tmp/vpn.login)
      fi

      ET_phone_home=$(ss -Hnto state established '( sport = :ssh )' | head -n1 | awk '{ split($4, a, ":"); print a[1] }')
      if [ -n "$ET_phone_home" ]; then
        vpn_command+=(--route $phone_home 255.255.255.255 net_gateway)
        echo "Added route to $ET_phone_home/24 via default gateway"
      fi

      for IP in $(host runner.circleci.com | awk '{ print $4; }')
        do
        vpn_command+=(--route $IP 255.255.255.255 net_gateway)
        echo "Added route to $IP/24 via default gateway"
      done

      for SYS_RES_DNS in $(systemd-resolve --status | grep 'DNS Servers'|awk '{print $3}')
        do
        vpn_command+=(--route $SYS_RES_DNS 255.255.255.255 net_gateway)
        echo "Added route to $SYS_RES_DNS/24 via default gateway"
      done

      "${vpn_command[@]}" --daemon --log /tmp/openvpn.log
      sudo chmod +r /tmp/openvpn.log
      CLIENT_LOG=/tmp/openvpn.log
    ;;

    Windows)
      echo "route 169.254.0.0 255.255.0.0 net_gateway" >> "/C/PROGRA~1/OpenVPN/config/config.ovpn"
      echo "Added route to 169.254.0.0/16 via default gateway"

      ET_phone_home=$(netstat -an | grep ':22 .*ESTABLISHED' | head -n1 | awk '{ split($3, a, ":"); print a[1] }')
      echo "route $ET_phone_home 255.255.255.255 net_gateway" >> "/C/PROGRA~1/OpenVPN/config/config.ovpn"
      echo "Added route to $ET_phone_home/24 via default gateway"

      sc.exe create "OpenVPN Client" binPath= "C:\PROGRA~1\OpenVPN\bin\openvpnserv.exe"
      net start "OpenVPN Client"
      CLIENT_LOG=/C/PROGRA~1/OpenVPN/log/config.log
    ;;

    macOS)
      touch /tmp/openvpn.log

      echo "route 169.254.0.0 255.255.0.0 net_gateway" >> /tmp/config.ovpn
      echo "Added route to 169.254.0.0/16 via default gateway"

      ET_phone_home="$(netstat -an | grep '\.2222\s.*ESTABLISHED' | head -n1 | awk '{ split($5, a, "."); print a[1] "." a[2] "." a[3] "." a[4] }')"
      echo "route $ET_phone_home 255.255.255.255 net_gateway" >> /tmp/config.ovpn
      echo "Added route to $ET_phone_home/24 via default gateway"

cat << EOF | sudo tee /Library/LaunchDaemons/org.openvpn.plist 1>/dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>Label</key>
<string>org.openvpn</string>
<key>Program</key>
    <string>/usr/local/opt/openvpn/sbin/openvpn</string>
<key>ProgramArguments</key>
<array>
    <string>/usr/local/opt/openvpn/sbin/openvpn</string>
    <string>--config</string>
    <string>/tmp/config.ovpn</string>
    <string>--script-security</string>
    <string>2</string>
    <string>--up</string>
    <string>/tmp/update-resolv-conf</string>
    <string>--down</string>
    <string>/tmp/update-resolv-conf</string>
</array>
<key>RunAtLoad</key>
    <false/>
<key>TimeOut</key>
    <integer>90</integer>
<key>StandardErrorPath</key>
    <string>/tmp/openvpn.log</string>
<key>StandardOutPath</key>
    <string>/tmp/openvpn.log</string>
<key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

      sudo launchctl load /Library/LaunchDaemons/org.openvpn.plist
      sudo launchctl start org.openvpn
      CLIENT_LOG=/tmp/openvpn.log
    ;;
esac

echo "export CLIENT_LOG=$CLIENT_LOG" >> $BASH_ENV