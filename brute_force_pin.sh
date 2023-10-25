#!/bin/bash

# Define the PKCS11 module and PIN
PKCS11_MODULE="/usr/lib/opensc-pkcs11.so"

# URL of the text file containing PKCS11 types
PWD_URL="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/Common-Credentials/best1050.txt"

# Download the types file
curl -s -o pwd.txt "$PWD_URL"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Error downloading the types file."
  exit 1
fi

# Function to run pkcs11-tool and check for the error
run_pkcs11_tool() {
  local pwd="$1"
  local result
  result=$(pkcs11-tool --module "$PKCS11_MODULE" --list-slots --pin "$pwd" 2>&1)

  set -- $result

  echo ">$1<"

  if [[ $1 == *"error:"* ]]; then
    echo "PIN >$pwd< is incorrect."
  else
    echo "PIN >$pwd< is correct. Stopping."
    exit 0
  fi
}

# Read the types from the file and loop through them
while read PWD; do
  run_pkcs11_tool "$PWD"
done <pwd.txt

echo "All types tested, but no correct type found."
