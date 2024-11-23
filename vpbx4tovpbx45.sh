#!/bin/bash

# Display warning in a bold, red format
echo -e "\033[1;31m#########################################################\033[0m"
echo -e "\033[1;31m#                      WARNING                          #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# Migrating from Debian 11 to Debian 12 and upgrading   #\033[0m"
echo -e "\033[1;31m# from VitalPBX 4 to VitalPBX 4.5 with this script      #\033[0m"
echo -e "\033[1;31m# involves potential risks.                            #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# Take proper precautions, including creating backups   #\033[0m"
echo -e "\033[1;31m# or snapshots and testing in a lab environment first. #\033[0m"
echo -e "\033[1;31m# Ensure you have a rollback plan before proceeding.    #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# Run this script as root or with sudo privileges.      #\033[0m"
echo -e "\033[1;31m#########################################################\033[0m"

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

# Step 3: Check VitalPBX Integrity
echo "Checking VitalPBX Integrityn..."
vitalpbx check-integrity

# Step 4: Remove Hotel Management Module (Deprecate in V4.5)
apt remove vitalpbx-hotel-management -y

# Step 5: Stop and disable apache2 service
systemctl stop apache2.service
systemctl disable apache2.service

# Step 6: Change repositories to Debian 12 (bookworm) and VitalPBBX
echo "Updating repositories to Debian 12..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*
echo "Update VitalPBX Repo to V4.5:"
sed -i 's/v4/v4.5/g' /etc/apt/sources.list.d/vitalpbx.list

# Step 7: Upgrade to Debian 12
# Set non-interactive mode globally
export DEBIAN_FRONTEND=noninteractive

# Step 8: Prevent interactive prompts
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
echo "Updating the package list..."
apt update -y

# Step 9: Update and upgrade the system
echo "Updating and upgrading the system..."
apt upgrade -yq
apt dist-upgrade -yq

# Step 10: Clean up residual packages
echo "Removing residual packages..."
apt autoremove --purge -y
apt clean -y

# Step 11: Update GRUB bootloader
echo "Updating GRUB..."
update-grub

# Step 12: Remove Apache
apt remove apache2 -y

# Step 13: Re-Install-Upgrade VitalPBX
apt reinstall vitalpbx -y

# Step 14: Remove old packages
apt autoremove -y
rm -rf /etc/nginx/sites-enabled/default
echo "=== Upgrade process completed ==="

# Step 15: Restart the system
echo "Rebooting the system to apply changes..."
reboot
