#!/usr/bin/env bash

# Make sure that we are sourced, not executed
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 1 ]; then
  echo "You must source this script, rather than try to run it."
  echo "$ source $0"
  exit 1
fi

# This script creates a test wallet with a name provided as the first argument.
# If it is not provided fail
if [ -z "$1" ]; then
    echo "Error: You must provide a name for the wallet." >&2
    echo "Usage: source \$SCRIPTS/create-test-wallet.sh WALLET_NAME" >&2
    return 1
fi
WALLET_NAME=$1
UPPER_CASE_WALLET_NAME=$(echo $WALLET_NAME | tr '[:lower:]' '[:upper:]')
SKEY_VAR_NAME="${UPPER_CASE_WALLET_NAME}_SKEY"
VKEY_VAR_NAME="${UPPER_CASE_WALLET_NAME}_VKEY"
ADDR_VAR_NAME="${UPPER_CASE_WALLET_NAME}_ADDR"

# Make sure that the required programs are available
declare -a requiredPrograms=("marlowe-cli" "cardano-cli" "cardano-address" "cardano-wallet")
for program in "${requiredPrograms[@]}"
do
  if ! [ -x "$(command -v $program)" ]; then
    echo "Error: $program is not installed." >&2
    return 1
  fi
done



# Make sure that the required env variables are available
declare -a requiredEnvVariables=("KEYS" "WALLET_NAME" )
for envVariable in "${requiredEnvVariables[@]}"
do
  if [ -z "${!envVariable}" ]; then
    echo "Error: $envVariable is not set." >&2
    return 1
  fi
done

if [ -z "${CARDANO_TESTNET_MAGIC}" ]; then
    NET_WITH_PREFIX="--mainnet"
else
    NET_WITH_PREFIX="--testnet-magic ${CARDANO_TESTNET_MAGIC}"
fi

# Make sure we don't overwrite any existing file
declare -a filesToCreate=("$KEYS/$WALLET_NAME.address" "$KEYS/$WALLET_NAME.skey" "$KEYS/$WALLET_NAME.vkey" "$KEYS/$WALLET_NAME-recovery-phrase.prv" "$KEYS/$WALLET_NAME-rootkey.prv")
for file in "${filesToCreate[@]}"
do
  if [ -f "$file" ]; then
    echo "The file $file already exists, we won't overwrite it." >&2

    export "${SKEY_VAR_NAME}=$KEYS/$WALLET_NAME.skey"
    export "${VKEY_VAR_NAME}=$KEYS/$WALLET_NAME.vkey"
    export "${ADDR_VAR_NAME}=$(cat $KEYS/$WALLET_NAME.address)"
    echo "Exporting variables:"
    echo "  * ${SKEY_VAR_NAME} = ${!SKEY_VAR_NAME}"
    echo "  * ${VKEY_VAR_NAME} = ${!VKEY_VAR_NAME}"
    echo "  * ${ADDR_VAR_NAME} = ${!ADDR_VAR_NAME}"

    return 0
  fi
done

# Create a new wallet by generating a random 24-word recovery phrase
cardano-wallet recovery-phrase generate > $KEYS/$WALLET_NAME-recovery-phrase.prv

# Create the root key from the recovery phrase
cat $KEYS/$WALLET_NAME-recovery-phrase.prv | cardano-address key from-recovery-phrase Shelley > $KEYS/$WALLET_NAME-rootkey.prv

# TODO Explain
cat $KEYS/$WALLET_NAME-rootkey.prv | cardano-address key child 1852H/1815H/0H/0/0 > $KEYS/$WALLET_NAME-addr.prv

# Create the signing key for the first address
cardano-cli key convert-cardano-address-key --signing-key-file $KEYS/$WALLET_NAME-addr.prv --shelley-payment-key --out-file $KEYS/$WALLET_NAME.skey

# Generate a temporal extended verification key
cardano-cli key verification-key --signing-key-file $KEYS/$WALLET_NAME.skey --verification-key-file $KEYS/$WALLET_NAME-Ext_ShelleyPayment.vkey

# Generate the non extended payment key
cardano-cli key non-extended-key --extended-verification-key-file $KEYS/$WALLET_NAME-Ext_ShelleyPayment.vkey --verification-key-file $KEYS/$WALLET_NAME.vkey

# Generate the address
cardano-cli address build --payment-verification-key-file $KEYS/$WALLET_NAME.vkey  --out-file $KEYS/$WALLET_NAME.address ${NET_WITH_PREFIX}

# Remove intermediate files
rm $KEYS/$WALLET_NAME-Ext_ShelleyPayment.vkey $KEYS/$WALLET_NAME-addr.prv


# Display the recovery phrase to the user with a warning
echo "==========================="
echo "==        WARNING        =="
echo "==========================="
echo "This is a test wallet. Do not use it for real ADA. Do not share the value"
echo "The recovery phrase for wallet ${WALLET_NAME} is:"
echo
cat $KEYS/$WALLET_NAME-recovery-phrase.prv
echo
echo
echo "Generated files:"
echo "  * $KEYS/$WALLET_NAME-recovery-phrase.prv: The recovery phrase for the wallet"
echo "  * $KEYS/$WALLET_NAME-rootkey.prv: The root key for the wallet"
echo "  * $KEYS/$WALLET_NAME.address: The first address"
echo "  * $KEYS/$WALLET_NAME.skey: The signing key for the first address"
echo "  * $KEYS/$WALLET_NAME.vkey: The verification key for the first address"
echo
echo


# export and display the generated files
echo "exported environment variables:"

export "${SKEY_VAR_NAME}=$KEYS/$WALLET_NAME.skey"
export "${VKEY_VAR_NAME}=$KEYS/$WALLET_NAME.vkey"
export "${ADDR_VAR_NAME}=$(cat $KEYS/$WALLET_NAME.address)"


echo "  * ${SKEY_VAR_NAME} = ${!SKEY_VAR_NAME}"
echo "  * ${VKEY_VAR_NAME} = ${!VKEY_VAR_NAME}"
echo "  * ${ADDR_VAR_NAME} = ${!ADDR_VAR_NAME}"


# Unset variables so that they dont pollute the scope
unset SKEY_VAR_NAME
unset VKEY_VAR_NAME
unset ADDR_VAR_NAME
unset NET_WITH_PREFIX
unset requiredEnvVariables
unset requiredPrograms
unset WALLET_NAME
unset UPPER_CASE_WALLET_NAME
