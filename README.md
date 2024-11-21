# Debian Upgrade and Cleanup Script (Including VitalPBX 4 to 4.5 Migration)

This script automates the process of upgrading a Debian 11 system to Debian 12 and includes a seamless migration from **VitalPBX 4** to **VitalPBX 4.5**, along with cleanup tasks to optimize the environment. It is especially useful for testing environments but can be used in production systems **at your own risk**.

---

# ⚠️ Warning

Migrating from **Debian 11** to **Debian 12**, as well as upgrading from **VitalPBX 4** to **VitalPBX 4.5** using this script, involves potential risks. 

It is highly recommended to:

- Create full backups or snapshots of your system before proceeding.
- Test the script in a non-production environment to ensure stability.
- Have a rollback plan in place in case of unexpected issues.
- Run this script as root or with sudo privileges.

**Proceed with caution!**

---
## 🚀 How to Use

1. Download the script file.
   ```bash
   wget https://raw.githubusercontent.com/VitalPBX/VPBX4toVPBX45SS/refs/heads/main/vpbx4tovpbx45.sh
2. Make the script executable:
   ```bash
   chmod +x vpbx4tovpbx45.sh
3. Execute the script:
   ```bash
   ./vpbx4tovpbx45.sh
4. Configuration Prompts During Script Execution<br>
When running the script, you may encounter prompts like the following:
   ```bash
   *** mpm_event.conf (Y/I/N/O/D/Z) [default=N] ? <press Enter>
   *** firewalld.conf (Y/I/N/O/D/Z) [default=N] ? <press Enter>

5. Optional: Remove All Unused Kernels from Version 5.x
   ```bash
   dpkg --list | grep 'linux-image-5' | awk '{print $2}' | grep -v "$(uname -r)" | xargs sudo apt remove -y

---
## 📋 How the Script Works

### Step 1: Update the current system
Ensures all current packages on Debian 11 are up-to-date.
   ```bash
   apt update && apt upgrade -y
   apt dist-upgrade -y
### Step 2: Remove unnecessary packages
Cleans up packages that are no longer needed.
   ```bash
   apt autoremove --purge -y

### Step 3: Check VitalPBX Integrity
Verifies that the VitalPBX installation is valid before upgrading.
   ```bash
   vitalpbx check-integrity

### Step 4: Remove Hotel Management Module (Deprecate in V4.5)
Uninstalls the hotel management module, which is no longer supported in version 4.5.
   ```bash
   apt remove vitalpbx-hotel-management -y

### Step 5: Change repositories to Debian 12 (bookworm) and VitalPBX
Updates the Debian and VitalPBX repositories to point to the new versions.
   ```bash
   sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
   sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*
   sed -i 's/v4/v4.5/g' /etc/apt/sources.list.d/vitalpbx.list

### Step 6: Upgrade to Debian 12
Prepares the system for non-interactive operations during the upgrade.
   ```bash
   export DEBIAN_FRONTEND=noninteractive

### Step 7: Prevent interactive prompts
Ensures no manual input is required during the package upgrades.
   ```bash
   echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

### Step 8: Update and upgrade the system
Performs the full system upgrade to Debian 12.
   ```bash
   apt update -y
   apt upgrade -yq
   apt dist-upgrade -yq

### Step 9: Clean up residual packages
Removes unnecessary residual packages and cleans cached files.
   ```bash
   apt autoremove --purge -y
   apt clean -y

### Step 10: Update GRUB bootloader
Updates GRUB to reflect the changes in the system.
   ```bash
   update-grub

### Step 11: Stop and disable apache2 service
Stops and removes the Apache2 web server, as it is not needed for VitalPBX.
   ```bash
   systemctl stop apache2.service
   systemctl disable apache2.service
   apt remove apache2 -y

### Step 12: Re-Install-Upgrade VitalPBX
Reinstalls VitalPBX to ensure compatibility with the new system.
   ```bash
   apt reinstall vitalpbx -y

### Step 13: Remove old packages
Cleans up any outdated packages and configurations.
   ```bash
   apt autoremove -y
   rm -rf /etc/nginx/sites-enabled/default

### Step 14: Restart the system
Reboots the system to apply all the changes made during the upgrade.
   ```bash
   reboot
