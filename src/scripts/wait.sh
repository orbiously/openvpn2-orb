#!/bin/bash

until [ -f $CLIENT_LOG ] && [ "$(grep -c "Initialization Sequence Completed" $CLIENT_LOG)" != 0 ]; do
  sleep 1
  echo "Attempting to connect to VPN server...";
done

printf "\nVPN connected\n"
printf "\nPublic IP is now $(curl -s http://checkip.amazonaws.com)\n"
