#!/usr/bin/env bash

# Make sure that we are executed, not sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 0 ]; then
  echo "Error: You must execute this script, rather than try to source it."
  echo "Usage: \$SCRIPTS/fund-wallets.sh ADDRESS_1 [ADDRESS_2] ... [ADDRESS_N]" >&2
  return 1
fi

# Exit on any error
set -e

# This script will fund with 1000 ADA to the addresses passed as arguments
ADDRESSES=("$@")

# If the ADDRESSES are not provided, fail
if [ -z "$ADDRESSES" ]; then
    echo "Error: You must provide at least one address to fund." >&2
    echo "Usage: \$SCRIPTS/fund-wallets.sh ADDRESS_1 [ADDRESS_2] ... [ADDRESS_N]" >&2
    exit 1
fi

# Make sure that the required programs are available
declare -a requiredPrograms=("marlowe-cli" "cardano-cli" "cardano-address" "cardano-wallet")
for program in "${requiredPrograms[@]}"
do
  if ! [ -x "$(command -v $program)" ]; then
    echo "Error: $program is not installed." >&2
    exit 1
  fi
done


# Make sure that the required env variables are available
declare -a requiredEnvVariables=("FAUCET_ADDR" "FAUCET_SKEY")
for envVariable in "${requiredEnvVariables[@]}"
do
  if [ -z "${!envVariable}" ]; then
    echo "Error: $envVariable is not set." >&2
    exit 1
  fi
done

if [ -z "${CARDANO_TESTNET_MAGIC}" ]; then
    NET_WITH_PREFIX="--mainnet"
else
    NET_WITH_PREFIX="--testnet-magic ${CARDANO_TESTNET_MAGIC}"
fi

# Make sure that the faucet has enough ADA
ADA=1000000

# Send 1000 ada
FUND_AMOUNT=$((1000 * ADA))

export TOTAL_LOVELACE=$(cardano-cli query utxo --address "$FAUCET_ADDR" $NET_WITH_PREFIX --out-file=/dev/stdout | jq '[.[] | .value.lovelace] | add' )
echo "Faucet Total lovelaces: $TOTAL_LOVELACE"
# TOTAL_LOVELACE needs to be bigger than FUND_AMOUNT * number of addresses
if [ "$TOTAL_LOVELACE" -lt "$(($FUND_AMOUNT * ${#ADDRESSES[@]}))" ]; then
    echo "Error: The faucet does not have enough ADA to fund the addresses." >&2
    exit 1
fi

# For each address, echo it
for address in "${ADDRESSES[@]}"
do
  echo "Funding $address"
done
echo
echo

# Execute the transaction.
marlowe-cli util fund-address \
 --lovelace "$FUND_AMOUNT" \
 --out-file /dev/null \
 --source-wallet-credentials "$FAUCET_ADDR":"$FAUCET_SKEY" \
 --submit 600 \
 "${ADDRESSES[@]}"
