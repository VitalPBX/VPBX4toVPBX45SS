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
1. Display a Warning Message
The script begins by displaying a bold, red warning message, informing the user about the potential risks of running the script. It emphasizes the need for backups and lab testing.

2. Request User Confirmation
The script asks the user to confirm whether they want to proceed. If the user does not type yes, the script exits without making changes.

3. Update the Current System
   ```bash
   apt update && apt upgrade -y
   apt dist-upgrade -y
Performs a full update of the current Debian 11 system to ensure it's up-to-date.

4. Remove Unnecessary Packages
   ```bash
   apt autoremove --purge -y
Cleans up unused or obsolete packages.

5. Check VitalPBX Integrity
   ```bash
   vitalpbx check-integrity
Runs a VitalPBX command to ensure the installation is error-free before upgrading.

6. Remove the Hotel Management Module
   ```bash
   apt remove vitalpbx-hotel-management -y
The hotel management module is deprecated in VitalPBX 4.5, so it is removed.

7. Update Debian Repositories to Debian 12
   ```bash
   sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
   sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*
Replaces Debian 11 (bullseye) repositories with Debian 12 (bookworm) repositories.

8. Update VitalPBX Repository
   ```bash
   sed -i 's/v4/v4.5/g' /etc/apt/sources.list.d/vitalpbx.list
Updates the VitalPBX repository to point to version 4.5.

9. Set Non-Interactive Mode
   ```bash
   export DEBIAN_FRONTEND=noninteractive
Configures the system to avoid interactive prompts during the upgrade process.

10. Prevent Interactive Prompts
   ```bash
   echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

Prevents manual intervention by setting the default behavior for prompts.

11. Upgrade to Debian 12
   ```bash
   apt update -y
   apt upgrade -yq
   apt dist-upgrade -yq
Performs the full upgrade to Debian 12.

12. Clean Residual Packages
   ```bash
   apt autoremove --purge -y
   apt clean -y
Removes unnecessary files and packages left over from the upgrade.

13. Update GRUB Bootloader
   ```bash
   update-grub
Updates the GRUB bootloader to reflect the changes in the system.

14. Stop and Remove Apache
   ```bash
   systemctl stop apache2.service
   systemctl disable apache2.service
   apt remove apache2 -y
Stops and removes Apache, as it is not required for VitalPBX.

15. Reinstall VitalPBX
   ```bash
   apt reinstall vitalpbx -y
Reinstalls VitalPBX to ensure compatibility with Debian 12.

16. Remove Old Nginx Configuration
   ```bash
   rm -rf /etc/nginx/sites-enabled/default
Removes default Nginx configurations that may cause conflicts.

17. Reboot the System
   ```bash
   reboot
Reboots the server to apply all changes.
