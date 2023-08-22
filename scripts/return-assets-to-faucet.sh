#!/usr/bin/env bash

# Make sure that we are executed, not sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 0 ]; then
  echo "You must execute this script, rather than try to source it."
  echo "$ ./$0"
  return 1
fi

# Exit on any error
set -e

# This script creates a test wallet with a name provided as the first argument.
# If it is not provided fail
if [ -z "$1" ]; then
    echo "Error: You must provide a name for the wallet." >&2
    echo "Usage: source \$SCRIPTS/create-test-wallet.sh WALLET_NAME" >&2
    exit 1
fi
WALLET_NAME=$1
UPPER_CASE_WALLET_NAME=$(echo $WALLET_NAME | tr '[:lower:]' '[:upper:]')


# Make sure that the required programs are available
declare -a requiredPrograms=("cardano-cli" "cardano-address" "cardano-wallet")
for program in "${requiredPrograms[@]}"
do
  if ! [ -x "$(command -v $program)" ]; then
    echo "Error: $program is not installed." >&2
    exit 1
  fi
done

SKEY_VAR_NAME="${UPPER_CASE_WALLET_NAME}_SKEY"
ADDR_VAR_NAME="${UPPER_CASE_WALLET_NAME}_ADDR"

# Make sure that the required env variables are available
declare -a requiredEnvVariables=("KEYS" "FAUCET_ADDR" )
for envVariable in "${requiredEnvVariables[@]}"
do
  if [ -z "${!envVariable}" ]; then
    echo "Error: $envVariable is not set." >&2
    exit 1
  fi
done

# make sure both the skey and address file exists
SKEY="$KEYS/${WALLET_NAME}.skey"
ADDR_FILE="$KEYS/${WALLET_NAME}.address"

if [ ! -f "$SKEY" ]; then
    echo "Error: $SKEY does not exist." >&2
    exit 1
fi

if [ ! -f "$ADDR_FILE" ]; then
    echo "Error: $ADDR_FILE does not exist." >&2
    exit 1
fi

ADDR=$(cat $ADDR_FILE)


if [ -z "${CARDANO_TESTNET_MAGIC}" ]; then
    NET_WITH_PREFIX="--mainnet"
else
    NET_WITH_PREFIX="--testnet-magic ${CARDANO_TESTNET_MAGIC}"
fi

# Query the UTXO for the wallet
cardano-cli query utxo --address $ADDR $NET_WITH_PREFIX --out-file="tmp_${WALLET_NAME}_utxo.json"

# All TX_IN (doesn't work with non-native assets)
# export TX_IN=$(cat tmp_${WALLET_NAME}_utxo.json | jq -r 'keys[] as $k | "--tx-in \($k)"')

# TX_IN with only native ada
export TX_IN=$(cat tmp_${WALLET_NAME}_utxo.json | jq -r 'keys[] as $k | select(.[$k].value | length == 1) | "--tx-in \($k)"')

# If TX_IN is empty, exit with a warning
if [ -z "$TX_IN" ]; then
    echo "Warning: No native-assets UTXO found for wallet ${WALLET_NAME}."
    rm -f "tmp_${WALLET_NAME}_utxo.json"
    exit 1
fi

# Build the transaction
cardano-cli transaction build --alonzo-era \
    $NET_WITH_PREFIX \
     $TX_IN \
     --change-address $FAUCET_ADDR \
     --out-file "tmp_${WALLET_NAME}_return_tx.unsigned"

# Sign and submit the transaction
cardano-cli transaction sign \
    --tx-body-file "tmp_${WALLET_NAME}_return_tx.unsigned" \
    --signing-key-file "$SKEY" \
    $NET_WITH_PREFIX \
    --out-file "tmp_${WALLET_NAME}_return_tx.signed"


cardano-cli transaction submit \
    --tx-file "tmp_${WALLET_NAME}_return_tx.signed" \
    $NET_WITH_PREFIX

# Clean up
rm -f "tmp_${WALLET_NAME}_utxo.json"
rm -f "tmp_${WALLET_NAME}_return_tx.unsigned"
rm -f "tmp_${WALLET_NAME}_return_tx.signed"

