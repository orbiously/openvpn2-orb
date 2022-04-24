#!/bin/bash

counter=0
until [ -f "$CLIENT_LOG" ]  && grep -iq "Initialization Sequence Completed" "$CLIENT_LOG" || [ "$counter" -eq $((TIMEOUT)) ]; do
    sleep 1
    ((counter++))
    #echo $counter
    printf "\nAttempting to connect to VPN server...\n";
done

if [ ! -f "$CLIENT_LOG" ] || (! grep -iq "Initialization Sequence Completed" "$CLIENT_LOG"); then
    printf "\nUnable to establish connection within the allocated time ---> Giving up.\n"
    if [ "$KILLSWITCH" = "on" ]; then
      printf "\nVPN connection attempt was unsuccessful and Killswitch is 'on' ---> Failing the build"
      exit 1
    fi
else
    printf "\nVPN connected\n"
    printf "\nPublic IP is now %s\n" "$(curl -s http://checkip.amazonaws.com)"
fi
