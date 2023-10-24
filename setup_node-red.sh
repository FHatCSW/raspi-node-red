#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Install Node.js and npm
apt install nodejs npm

# Install Node-Red
npm install -g --unsafe-perm node-red

# Create the Node-RED service unit file
echo "[Unit]
Description=Node-Red

[Service]
User=admin
ExecStart=node-red
Restart=on-failure

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/node-red.service

# Enable and start the Node-RED service
systemctl enable node-red.service
systemctl start node-red.service

# Check the status of the Node-RED service
systemctl status node-red.service

echo "Node-RED has been configured as a systemd service."

# Provide instructions for accessing Node-RED
echo "You can access Node-RED by opening a web browser and navigating to:"
echo "http://localhost:1880 (if you're on the Raspberry Pi itself)"
echo "or"
echo "http://<your_pi_IP_address>:1880 (from another device on the same network)"
