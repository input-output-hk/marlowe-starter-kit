#!/usr/bin/env bash

# Make sure that we are sourced, not executed
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 1 ]; then
  echo "You must source this script, rather than try to run it."
  echo "$ source $0"
  exit 1
fi

# Make sure the network variable is either preprod preview or mainnet
if [ "${NETWORK}" != "preprod" ] && [ "${NETWORK}" != "preview" ] && [ "${NETWORK}" != "mainnet" ]; then
  echo "Error: NETWORK variable must be either preprod, preview or mainnet."
  return 1
fi

# Make sure that all required programs for this script are available
declare -a requiredPrograms=("jq" "docker-compose")
for program in "${requiredPrograms[@]}"
do
  if ! [ -x "$(command -v $program)" ]; then
    echo "Error: $program is not installed." >&2
    return 1
  fi
done

# Make sure the node container is running
if ! docker-compose ps --format json | jq -e '.[] | select(.Name | contains("node")) | .State' > /dev/null; then
  echo "Error: cardano-node docker instance is not running."
  return 1
fi

# If the CARDANO_NODE_SOCKET_PATH is not set, set it to the node.socket file in the shared volume
if [ -z "${CARDANO_NODE_SOCKET_PATH}" ]; then
  export CARDANO_NODE_SOCKET_PATH=$(docker volume inspect marlowe-starter-kit_shared | jq -r '.[0].Mountpoint')/node.socket
fi

# Make sure we have write access to the socket file
if [ ! -w "${CARDANO_NODE_SOCKET_PATH}" ]; then
  echo "Error: CARDANO_NODE_SOCKET_PATH is not writable: $CARDANO_NODE_SOCKET_PATH"
  echo "    try to execute:"
  echo "    sudo chmod a+rwx $f"

  # For each directory try to see if its executable (we can enter)
  f=$(dirname $CARDANO_NODE_SOCKET_PATH)

  while [ ! -x "$f" ] && [ "$f" != "/" ]; do
      echo "  * $f is not executable"
      echo "    try to execute:"
      echo "    sudo chmod a+rx $f"
      f=$(dirname $f)
  done
  return 1
fi

echo "Env variables set: "

export MARLOWE_RT_HOST=localhost
export MARLOWE_RT_PORT=3700
export MARLOWE_RT_WEBSERVER_HOST=localhost
export MARLOWE_RT_WEBSERVER_PORT=3780
export MARLOWE_RT_WEBSERVER_URL=http://localhost:3780
export PGHOST=localhost
export PGUSER=postgres
export PGPASSWORD=postgres
echo "CARDANO_NODE_SOCKET_PATH = $CARDANO_NODE_SOCKET_PATH"
echo "MARLOWE_RT_HOST = $MARLOWE_RT_HOST"
echo "MARLOWE_RT_PORT = $MARLOWE_RT_PORT"
echo "MARLOWE_RT_WEBSERVER_HOST = $MARLOWE_RT_WEBSERVER_HOST"
echo "MARLOWE_RT_WEBSERVER_PORT = $MARLOWE_RT_WEBSERVER_PORT"
echo "MARLOWE_RT_WEBSERVER_URL = $MARLOWE_RT_WEBSERVER_URL"
echo "PGHOST = $PGHOST"
echo "PGUSER = $PGUSER"
echo "PGPASSWORD = $PGPASSWORD"