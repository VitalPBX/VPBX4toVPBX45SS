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
## 📋 Detailed Explanation of Script Workflow

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
