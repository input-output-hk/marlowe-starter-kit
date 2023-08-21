#!/usr/bin/env bash

# Make sure that we are executed, not sourced
(return 0 2>/dev/null) && sourced=1 || sourced=0
if [ $sourced != 0 ]; then
  echo "You must source this script, rather than try to run it."
  echo "$ ./$0"
  exit 1
fi

# If the variable CARDANO_SCAN_URL is not set exit with an error
if [ -z "${CARDANO_SCAN_URL}" ]; then
  echo "Error: CARDANO_SCAN_URL is not set." >&2
  exit 1
fi

# This script receives in the first argument a Cardano address
export ADDRESS=$1

echo "$CARDANO_SCAN_URL/address/$ADDRESS"
