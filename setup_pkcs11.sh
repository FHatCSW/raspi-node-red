#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# update and upgrade the device
apt-get update && sudo apt-get upgrade -y

# install relevant packages
apt install libpcsclite-dev pcscd pcsc-tools libssl-dev libengine-pkcs11-openssl autoconf libtool openssl git python3-venv -y

# Upgrade pip
python3 -m pip install --upgrade pip

# Load OpenSC
wget https://github.com/swissbit-eis/OpenSC/archive/refs/tags/0.23.0-swissbit.tar.gz

# Bootstrap OpenSC
tar -xf 0.23.0-swissbit.tar.gz
cd OpenSC-0.23.0-swissbit/
./bootstrap
./configure --prefix=/usr
make -j4 install

# Check status of the service
systemctl status pcscd

# Detect the location of the openssl configuration file
OPENSSL_CONF=$(openssl version -d | awk '{print $NF}' | tr -d '"')/openssl.cnf

# Add content to the beginning of the openssl configuration file
sed -i '1i\
openssl_conf = openssl_init\n\n[openssl_init]\nengines = engine_section\n\n[engine_section]\npkcs11 = pkcs11_section\n\n[pkcs11_section]\nengine_id = pkcs11\nMODULE_PATH = /usr/lib/opensc-pkcs11.so\ndynamic_path = /usr/lib/aarch64-linux-gnu/engines-1.1/pkcs11.so\ninit = 0\n' $OPENSSL_CONF

# Search for opensc-pkcs11.so using find
search_result=$(find / -type f -name "opensc-pkcs11.so" 2>/dev/null)

if [ -n "$search_result" ]; then
  echo "The 'opensc-pkcs11.so' file was found at the following location(s):"
  echo "$search_result"
else
  echo "The 'opensc-pkcs11.so' file was not found on the system."
fi
