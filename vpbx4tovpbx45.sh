#!/bin/bash

# Display warning in a bold, red format
echo -e "\033[1;31m###############################################\033[0m"
echo -e "\033[1;31m# WARNING                                    #\033[0m"
echo -e "\033[1;31m#                                            #\033[0m"
echo -e "\033[1;31m# Do this at your own risk!                  #\033[0m"
echo -e "\033[1;31m# This script was tested on a lab PBX,       #\033[0m"
echo -e "\033[1;31m# not in production.                         #\033[0m"
echo -e "\033[1;31m#                                            #\033[0m"
echo -e "\033[1;31m# Take a checkpoint/snapshot beforehand,     #\033[0m"
echo -e "\033[1;31m# in case you need to roll back.             #\033[0m"
echo -e "\033[1;31m#                                            #\033[0m"
echo -e "\033[1;31m# Make sure to run this script with sudo.    #\033[0m"
echo -e "\033[1;31m###############################################\033[0m"

read -p "Are you sure you want to proceed? (yes/no): " confirmation
# Check the user's input
if [[ "$confirmation" != "yes" ]]; then
    echo "Upgrade process canceled by the user."
    exit 1
fi

echo "=== Starting the upgrade process from Debian 11 to Debian 12 ==="

# Step 1: Update the current system
echo "Updating the current system..."
apt update && apt upgrade -y
apt dist-upgrade -y

# Step 2: Remove unnecessary packages
echo "Removing unnecessary packages..."
apt autoremove --purge -y

# Step 3: Check the current Debian version
echo "Checking the current Debian version..."
lsb_release -a

# Step 4: Change repositories to Debian 12 (bookworm)
echo "Updating repositories to Debian 12..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list

# Step 5: Upgrade to Debian 12
echo "Updating the package list..."
apt update

echo "Upgrading packages to Debian 12..."
DEBIAN_FRONTEND=noninteractive apt upgrade -yq --force-confdef --force-confold

echo "Performing a full system upgrade..."
apt dist-upgrade -y

# Step 6: Clean up residual packages
echo "Removing residual packages..."
apt autoremove --purge -y

# Step 7: Update GRUB bootloader
echo "Updating GRUB..."
update-grub

# Step 8: Update VitalPBX Repo to V4.5
echo "Update VitalPBX Repo to V4.5:"
sed -i 's/v4/v4.5/g' /etc/apt/sources.list.d/vitalpbx.list

# Step 9: Stop and disable apache2 service
systemctl stop apache2.service
systemctl disable apache2.service
apt remove apache2 -y

# Step 10: Re-Install-Upgrade VitalPBX
apt update
apt reinstall vitalpbx -y

# Step 11: Remove old packages
apt autoremove -y
rm -rf /etc/nginx/sites-enabled/default
echo "=== Upgrade process completed ==="

# Step 12: Restart the system
echo "Rebooting the system to apply changes..."
reboot
