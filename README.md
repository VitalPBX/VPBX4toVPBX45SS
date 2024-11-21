# Debian Upgrade and Cleanup Script

This script automates the process of upgrading a Debian 11 system to Debian 12 and performs cleanup tasks to optimize the environment. It is especially useful for testing environments but can be used in production systems **at your own risk**.

---

## ⚠️ Warning
- **Do this at your own risk.** This script has been tested on a lab PBX, not in a production environment.
- **Backup before proceeding.** Take a snapshot or backup of your system before running this script to ensure you can roll back if needed.
- **Superuser privileges required.** Make sure to run this script with `sudo` or as a root user.

---

## 📋 Script Steps

1. **User Confirmation**  
   Prompts the user to confirm before proceeding with the upgrade.

2. **Update Current System**  
   Runs `apt update`, `apt upgrade`, and `apt dist-upgrade` to ensure the current system is up to date.

3. **Remove Unnecessary Packages**  
   Cleans up unused packages using `apt autoremove --purge`.

4. **Verify Current Debian Version**  
   Displays the current Debian version using `lsb_release -a`.

5. **Update Repositories**  
   Modifies `/etc/apt/sources.list` to switch from Debian 11 (`bullseye`) to Debian 12 (`bookworm`).

6. **Upgrade to Debian 12**  
   Updates the package list and performs a full system upgrade.

7. **Clean Up Residual Packages**  
   Removes old and residual packages.

8. **Update GRUB Bootloader**  
   Ensures the bootloader is updated to reflect the changes.

9. **Update VitalPBX Repository**  
   Updates the VitalPBX repository to version 4.5.

10. **Disable and Remove Apache2**  
    Stops and disables the `apache2` service and removes it from the system.

11. **Reinstall and Upgrade VitalPBX**  
    Reinstalls the latest version of VitalPBX.

12. **Remove Default NGINX Configuration**  
    Removes the default NGINX configuration file.

13. **Reboot the System**  
    Reboots the system to apply all changes.

---

## 🚀 How to Use

1. Clone the repository or download the script file.
2. Make the script executable:
   ```bash
   chmod +x upgrade_debian.sh

