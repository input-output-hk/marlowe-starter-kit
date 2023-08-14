#!/usr/bin/env bash
set -e

echo "########################"
echo "## Check CLI commands ##"
echo "########################"
echo ""


# Make sure that we are sourced, not executed
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 1 ]; then
  echo "You must source this script, rather than try to run it."
  echo "$ source $0"
  exit 1
fi

# Make sure that all required programs are available
declare -a requiredPrograms=("jq" "json2yaml" "marlowe-cli" "marlowe-runtime-cli" "cardano-cli" "cardano-address" "cardano-wallet")
for program in "${requiredPrograms[@]}"
do
  if ! [ -x "$(command -v $program)" ]; then
    echo "Error: $program is not installed." >&2
    return 1
  fi
done

echo "The following required programs are available in the shell:"
for program in "${requiredPrograms[@]}"
do
  echo "  * $program"
done

echo ""
echo "#########################"
echo "## Check required envs ##"
echo "#########################"
echo ""

# Make sure that the required env variables are available
declare -a requiredEnvVariables=("CARDANO_NODE_SOCKET_PATH" "MARLOWE_RT_HOST" "MARLOWE_RT_PORT" "MARLOWE_RT_WEBSERVER_HOST" "MARLOWE_RT_WEBSERVER_PORT" "MARLOWE_RT_WEBSERVER_URL")
for envVariable in "${requiredEnvVariables[@]}"
do
  if [ -z "${!envVariable}" ]; then
    echo "Error: $envVariable is not set." >&2
    return 1
  fi
done

echo "The following environment variables are available in the shell:"
for envVariable in "${requiredEnvVariables[@]}"
do
  echo "  * $envVariable = ${!envVariable}"
done

echo ""
echo "###################"
echo "## Check Network ##"
echo "###################"
echo ""

# The following block sets the value of CARDANO_TESTNET_MAGIC from the NETWORK variable.
if [ "${NETWORK}" == "mainnet" ]; then
  unset CARDANO_TESTNET_MAGIC
elif [ "${NETWORK}" == "preprod" ]; then
  export CARDANO_TESTNET_MAGIC=1
elif [ "${NETWORK}" == "preview" ]; then
  export CARDANO_TESTNET_MAGIC=2
fi


# See if the CARDANO_TESTNET_MAGIC env variable is set, if it is, check if it is the value 1 and print preprod, check if the value is 2 and print preview if it is a different value print it with a warning and if the variable is unset print mainnet
if [ -z "${CARDANO_TESTNET_MAGIC}" ]; then
  # See if the NETWORK variable is set to mainnet, if it is print mainnet, if its not print warnign
  if [ -z "${NETWORK}" ]; then
    echo "WARNING: Both NETWORK and CARDANO_TESTNET_MAGIC are unset, assuming mainnet, be careful"
  elif [ "${NETWORK}" == "mainnet" ]; then
    echo "The NETWORK is set to mainnet"
  fi
elif [ "${CARDANO_TESTNET_MAGIC}" == "1" ]; then
  echo "The NETWORK is set to preprod"
elif [ "${CARDANO_TESTNET_MAGIC}" == "2" ]; then
  echo "The NETWORK is set to preview"
else
  echo "Warning: unknown network ${CARDANO_TESTNET_MAGIC}"
fi