#!/bin/bash
PEERFILE=/etc/wireguard/peers
ESC=`echo -e '\033'`

# Run through script to preserve color coding
script --flush --quiet /dev/null --command "wg" | while read LINE ; do
  # Check if its a peer line
  if [[ $LINE == *"peer"* ]]; then
    # Isolate peer public key, cut peer: (incl colors) hardcoded, then cut until first ESC character
    PEERPK=`echo $LINE | cut -c25- | cut -d $ESC -f1`

    # Output peer line
    echo $LINE

    # See if we can find peer in peers file
    PEER=`grep $PEERPK $PEERFILE | cut -d ':' -f2`

    # If we found a friendly name, print that
    if [[ "$PEER" != "" ]]; then
      # Pretty print friendly name
      tput bold; tput setaf 7
      echo -n "  friendly name"
      tput setaf 9; tput sgr0
      echo -ne ": $PEER\r\n"
    fi
  else
    # Non-peer line, just output, but remember indentation
    if [[ $LINE == *"interface"* ]]; then
      echo $LINE
    else
      echo "  $LINE"
    fi
  fi
done
