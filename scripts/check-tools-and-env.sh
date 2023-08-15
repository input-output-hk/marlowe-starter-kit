#!/usr/bin/env bash
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

# See if the CARDANO_TESTNET_MAGIC env variable is set
if [ -z "${CARDANO_TESTNET_MAGIC}" ]; then
  export "CARDANO_SCAN_URL=https://cardanoscan.io"
  export "MARLOWE_SCAN_URL=https://mainnet.marlowescan.com"

  # WARN if NETWORK is not an explicit mainnet
  if [ "${NETWORK}" == "mainnet" ]; then
    echo "The NETWORK is set to mainnet"
  elif [ "${NETWORK}" == "mainnet" ]; then
    echo "WARNING: CARDANO_TESTNET_MAGIC is unset, assuming mainnet. BE CAREFUL"
  fi
elif [ "${CARDANO_TESTNET_MAGIC}" == "1" ]; then
  echo "The NETWORK is set to preprod"
  export "CARDANO_SCAN_URL=https://preprod.cardanoscan.io"
  export "MARLOWE_SCAN_URL=https://preprod.marlowescan.com"

elif [ "${CARDANO_TESTNET_MAGIC}" == "2" ]; then
  echo "The NETWORK is set to preview"
  export "CARDANO_SCAN_URL=https://preview.cardanoscan.io"
  export "MARLOWE_SCAN_URL=https://preview.marlowescan.com"

else
  echo "Warning: unknown network ${CARDANO_TESTNET_MAGIC}"
fi
echo "CARDANO_SCAN_URL = $CARDANO_SCAN_URL"
echo "MARLOWE_SCAN_URL = $MARLOWE_SCAN_URL"

