#!/bin/bash

# Fetch the GitHub Meta API to get the list of GitHub Actions IP addresses
GITHUB_META_URL="https://api.github.com/meta"
IP_JSON=$(curl -s $GITHUB_META_URL)
GITHUB_IPS=$(echo $IP_JSON | jq -r '.actions[]')

# Loop through each IP address and add it to the firewall whitelist
for IP in $GITHUB_IPS; do
    sudo ufw allow from $IP to any port 22 proto tcp
    echo "$IP"
done
