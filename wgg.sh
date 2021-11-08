#!/bin/bash
PEERFILE=/etc/wireguard/peers
WGCOMMAND=$(which wg)

# Make sure peer file exists
if [[ ! -f "$PEERFILE" ]]; then
  touch "$PEERFILE" 2>/dev/null

  if [[ "$?" != "0" ]]; then
    echo "Peer file $PEERFILE is not accesible by your user"

    exit 0
  fi
fi

function updatePeerFile() {
  local NEWPEERS=()

  # Loop config, extract peers, check peers file, add if not present
  while read LINE ; do
    # Check if its a peer line
    if [[ $LINE == *"peer"* ]]; then
      # Isolate peer public key, cut peer: (hardcoded)
      PEERPK=$(printf '%s' "$LINE" | cut -c7-)

      # See if we can find peer in peers file
      PEERCOUNT=$(grep $PEERPK "$PEERFILE" | wc -l)

      if [[ $PEERCOUNT -eq 0 ]]; then
        # Peer not found in peers file, add for later processing
        NEWPEERS+=("$PEERPK")
      fi
    fi
  done <<< $("$WGCOMMAND")

  for PEERPK in "${NEWPEERS[@]}"; do
    echo -n "Enter friendly name for peer "
    tput setaf 7; tput bold
    echo -n $PEERPK
    tput setaf 9; tput sgr0
    read -r -p " : " PEERNAME

    if [[ "$PEERNAME" == "" ]]; then
      PEERNAME="Unnamed peer"
    fi

    echo "$PEERPK:$PEERNAME" >> "$PEERFILE"
  done
}

function showConfiguration() {
  # Determine if we are using rich (colorful) output or not
  local RICHOUTPUT=1;

  if [[ ! -t 1 ]]; then
    RICHOUTPUT=0
  fi

  # Run wg through script to preserve color coding
  script --flush --quiet /dev/null --command "$WGCOMMAND" | while read LINE ; do 
    # Check if its a peer line
    if [[ $LINE == *"peer"* ]]; then
      # Isolate peer public key, cut peer: (incl colors) hardcoded, then cut until first ESC character
      PEERPK=$(printf '%s' "$LINE" | cut -c25- | cut -d $(echo -e '\033') -f1)

      # Output peer line
      echoLine "$LINE" $RICHOUTPUT 1

      # See if we can find peer in peers file
      PEER=$(grep $PEERPK "$PEERFILE" | cut -d ':' -f2)

      # If we found a friendly name, print that
      if [[ "$PEER" != "" ]]; then
        # Pretty print friendly name
        echoLine "$(printf '%s' "$(tput bold)$(tput setaf 7)  friendly name$(tput setaf 9)$(tput sgr0)")" $RICHOUTPUT 0
        echoLine "$(printf '%s' ": $PEER")" $RICHOUTPUT 1
      fi
    else
      # Non-peer line, just output, but remember indentation
      if [[ "$LINE" == *"interface"* ]]; then
        echoLine "$LINE" $RICHOUTPUT 1
      else
        echoLine "  $LINE" $RICHOUTPUT 1
      fi
    fi
  done
}

# $1: text, $2 richoutput, $3 print linebreak
function echoLine() {
  # Strip any newline characters
  local OUTPUTLINE=$(printf '%s' "$1" | sed '$ s/\[\r\n]$//')

  # If not rich output, strip ANSI control codes
  if [[ $2 -eq 0 ]]; then
    OUTPUTLINE=$(printf '%s' "$OUTPUTLINE" | sed 's/\x1b\[[0-9]\{0,\}m\{0,1\}\x0f\{0,1\}//g')
  fi

  # Handle newline printing
  if [[ $3 -eq 0 ]]; then
    printf '%s' "$OUTPUTLINE"
  else
    printf '%s\r\n' "$OUTPUTLINE"
  fi
}

# What are we doing?
if [[ $# -gt 0 ]]; then
  while getopts :u OPTION; do
    case ${OPTION} in
      u)  updatePeerFile
          exit
          ;;
    esac
  done

  echo Usage: wgg.sh [-u]
  echo -e "  -u\tAdd missing peers to $PEERFILE"
  echo ""
  echo If no arguments are given, shows wg configuration with friendly peernames added
else
  # Show the peer-enriched configuration overview
  showConfiguration
fi
