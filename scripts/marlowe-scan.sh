#!/usr/bin/env bash

# Make sure that we are executed, not sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 0 ]; then
  echo "You must source this script, rather than try to run it."
  echo "$ ./$0"
  exit 1
fi

# If the variable MARLOWE_SCAN_URL is not set exit with an error
if [ -z "${MARLOWE_SCAN_URL}" ]; then
  echo "Error: MARLOWE_SCAN_URL is not set." >&2
  exit 1
fi

# This script receives in the first argument a Marlowe Contract ID
export MARLOWE_CONTRACT_ID=$1

echo "$MARLOWE_SCAN_URL/contractView?tab=info&contractId=$(echo "$MARLOWE_CONTRACT_ID" | sed 's/#/%23/g')"
