# Debian Upgrade and Cleanup Script (Including VitalPBX 4 to 4.5 Migration)

This script automates the process of upgrading a Debian 11 system to Debian 12 and includes a seamless migration from **VitalPBX 4** to **VitalPBX 4.5**, along with cleanup tasks to optimize the environment. It is especially useful for testing environments but can be used in production systems **at your own risk**.

---

## ⚠️ Warning
- **Do this at your own risk.** This script has been tested on a lab PBX, not in a production environment.
- **Backup before proceeding.** Take a snapshot or backup of your system before running this script to ensure you can roll back if needed.
- **Superuser privileges required.** Make sure to run this script with `sudo` or as a root user.

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

9. **Migrate VitalPBX from Version 4 to Version 4.5**  
   Updates the VitalPBX repository in `/etc/apt/sources.list.d/vitalpbx.list` to reflect version 4.5 and reinstalls VitalPBX to apply the latest version.

10. **Disable and Remove Apache2**  
    Stops and disables the `apache2` service and removes it from the system.

11. **Reinstall and Upgrade VitalPBX**  
    Reinstalls the latest version of VitalPBX after updating the repositories.

12. **Remove Default NGINX Configuration**  
    Removes the default NGINX configuration file for a cleaner setup.

13. **Reboot the System**  
    Reboots the system to apply all changes.

---
