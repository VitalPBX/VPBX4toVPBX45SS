#!/bin/bash

set -e

# Functions for logging
log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
    exit 1
}

# Check for root permissions
if [ "$EUID" -ne 0 ]; then
    error "Please run this script with root privileges. Use 'su -' to switch to the root user."
fi

#Check OS Version
os_codename=`cat /etc/os-release | grep -e VERSION_CODENAME | awk -F '=' '{print $2}' | xargs`
if [ "$os_codename" != "bullseye" ]; then
        error "This script must be run on Debian 11 (bullseye). Please ensure you are using the correct operating system."
fi


# Display warning in a bold, red format
echo -e "\033[1;31m#########################################################\033[0m"
echo -e "\033[1;31m#                      WARNING                          #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# Migrating from Debian 11 to Debian 12 and upgrading   #\033[0m"
echo -e "\033[1;31m# from VitalPBX 4 to VitalPBX 4.5 with this script      #\033[0m"
echo -e "\033[1;31m# involves potential risks.                             #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# Take proper precautions, including creating backups   #\033[0m"
echo -e "\033[1;31m# or snapshots and testing in a lab environment first.  #\033[0m"
echo -e "\033[1;31m# Ensure you have a rollback plan before proceeding.    #\033[0m"
echo -e "\033[1;31m#                                                       #\033[0m"
echo -e "\033[1;31m# During the upgrade, press [ENTER] whenever prompted.  #\033[0m"
echo -e "\033[1;31m#########################################################\033[0m"

# Prompt the user about making a backup
read -p "Do you want to continue? [Y/N]: " proceed

if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    log "Migration process aborted by the user."
    exit 0
fi

# 1. Upgrade the machine to the latest version of Bullseye
log "Updating Debian Bullseye to the latest available version..."
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
log "Bullseye version updated successfully."

# 2. Update Debian sources for the distribution upgrade
log "Updating Debian sources from Bullseye to Bookworm..."
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list
log "Repository files updated for Debian Bookworm."

# 3. Hold VitalPBX Packages
log "Holding VitalPBX packages to avoid removal..."
apt-mark hold $(dpkg-query -f '${binary:Package}\n' -W 'vitalpbx*')
apt-mark hold logger-core
apt-mark hold provisioning-core 2>/dev/null || log "Package 'provisioning-core' not found."
apt-mark hold vitxi 2>/dev/null || log "Package 'vitxi' not found."
apt-mark hold $(dpkg-query -f '${binary:Package}\n' -W 'sonata-*') 2>/dev/null || log "No Sonata add-ons."

# 4. Step 1 of upgrading the system
log "Performing an in-place package upgrade without installing new packages..."
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt upgrade --without-new-pkgs -y
log "In-place upgrade completed."

# 5. Step 2 of upgrading the system
log "Performing a full system upgrade..."
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
log "Full system upgrade completed successfully."

# 6. Unhold VitalPBX Packages
log "Unholding VitalPBX packages..."
apt-mark unhold $(dpkg-query -f '${binary:Package}\n' -W 'vitalpbx*')
apt-mark unhold logger-core
apt-mark unhold provisioning-core 2>/dev/null || log "Package 'provisioning-core' not found."
apt-mark unhold vitxi 2>/dev/null || log "Package 'vitxi' not found."
apt-mark unhold $(dpkg-query -f '${binary:Package}\n' -W 'sonata-*') 2>/dev/null || log "No Sonata add-ons."

# 7. Update VitalPBX repository to v4.5
log "Updating VitalPBX repository to version 4.5..."
vitalpbx_repo="/etc/apt/sources.list.d/vitalpbx.list"
sed -i 's/v4/v4.5/g' $vitalpbx_repo
log "Updated repository file: $vitalpbx_repo"

# 8. Disable Apache before upgrading to VitalPBX v4.5
log "Disabling Apache2..."
systemctl stop apache2
systemctl disable apache2
sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
sed -i "s/Listen 443/Listen 4443/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:80>/<VirtualHost *:8080>/" /etc/apache2/sites-available/vitalpbx.conf
sed -i "s/<VirtualHost \*:443>/<VirtualHost *:4443>/" /etc/apache2/sites-available/vitalpbx.conf
sed -i "s/<VirtualHost \*:3500>/<VirtualHost *:2500>/" /etc/apache2/sites-available/vitalpbx.conf
sed -i "s/<VirtualHost \*:3501>/<VirtualHost *:2501>/" /etc/apache2/sites-available/vitalpbx.conf
log "Apache is stopped and disable..."

# 9. Upgrade VitalPBX Packages
log "Upgrade VitalPBX packages..."
apt update
apt upgrade -y

# 10. Configure Firewall and Optimize Server
log "Updating and configuring the firewall..."
sed -i '/<source ipset=".*"\/>/d' /etc/firewalld/zones/drop.xml
php /usr/share/vitalpbx/scripts/configure_fail2ban
php /usr/share/vitalpbx/scripts/build_firewall
php /usr/share/vitalpbx/scripts/vitalpbx "optimizeMariaDB"
php /usr/share/vitalpbx/scripts/vitalpbx "optimizeNginxSettings"
php /usr/share/vitalpbx/scripts/vitalpbx "optimizePHPFPM"
php /usr/share/vitalpbx/scripts/vitalpbx "optimizeServerSettings"

# 11. Remove obsolete packages
log "Removing obsolete packages..."
DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
DEBIAN_FRONTEND=noninteractive apt autoclean -y
log "Obsolete packages removed."

# 12. Remove Apache
log "Removing Apache..."
systemctl stop apache2
systemctl disable apache2
rm -rf /var/lib/apache2/*  2>/dev/null || log "No Apache2 bin directory."
DEBIAN_FRONTEND=noninteractive apt remove -y apache2
DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
log "Apache removed successfully."

# 13. Remove Nginx Default site
log "Disabling Nginx default site..."
unlink /etc/nginx/sites-enabled/default 2>/dev/null || log "No default nginx site present."
log "Nginx default site disabled..."

# 14. Cleanup
log "Performing final cleanup..."
DEBIAN_FRONTEND=noninteractive apt autoclean -y

# 15. Reboot the server
log "Migration completed successfully. The system will now reboot."
reboot
