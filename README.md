# Debian Upgrade and Cleanup Script (Including VitalPBX 4 to 4.5 Migration)

This script automates the process of upgrading a Debian 11 system to Debian 12 and includes a seamless migration from **VitalPBX 4** to **VitalPBX 4.5**, along with cleanup tasks to optimize the environment.<br> 
Before upgrading your system, it is strongly recommended that you make a full backup, or at least back up any data or configuration information you can't afford to lose. The upgrade tools and process are quite reliable, but a hardware failure in the middle of an upgrade could result in a severely damaged system.

Please read the [Debian Release Notes](https://www.debian.org/releases/stable/i386/release-notes/ch-upgrading.html) to be clear about the risks
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
```
wget https://raw.githubusercontent.com/VitalPBX/VPBX4toVPBX45SS/refs/heads/main/vpbx4tovpbx45.sh
```
2. Make the script executable:
```
chmod +x vpbx4tovpbx45.sh
```
3. Execute the script:
```
./vpbx4tovpbx45.sh
```
4. Configuration Prompts During Script Execution<br>
When running the script, you may encounter prompts like the following:
```
*** mpm_event.conf (Y/I/N/O/D/Z) [default=N] ? <press Enter>
.......
*** firewalld.conf (Y/I/N/O/D/Z) [default=N] ? <press Enter>
```
5. Optional: Remove All Unused Kernels from Version 5.x
```
dpkg --list | grep 'linux-image-5' | awk '{print $2}' | grep -v "$(uname -r)" | xargs sudo apt remove -y
```
---
## 📋 How the Script Works

**Step 1:** Upgrade Current System (Bullseye) <br>
Upgrades the current system to the latest version available for Debian 11.
```
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt upgrade -y
```
**Step 2:** Update Sources to Debian 12 (Bookworm) <br>
Updates APT source files to point to Debian 12 repositories.
```
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list
sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list.d/*.list
```
**Step 3:** Hold VitalPBX Packages <br>
Prevents critical VitalPBX packages from being removed or modified during the upgrade.
```
apt-mark hold $(dpkg-query -f '${binary:Package}\n' -W 'vitalpbx*')
apt-mark hold logger-core
apt-mark hold provisioning-core
apt-mark hold vitxi
apt-mark hold $(dpkg-query -f '${binary:Package}\n' -W 'sonata-*')
```
**Step 4:** Perform a Complete Upgrade <br>
Executes a system upgrade in two stages: first without installing new packages, followed by a full upgrade.
```
DEBIAN_FRONTEND=noninteractive apt upgrade --without-new-pkgs -y
DEBIAN_FRONTEND=noninteractive apt full-upgrade -y
```
**Step 5:** Unhold VitalPBX Packages <br>
Releases held VitalPBX packages to allow further updates.
```
apt-mark unhold $(dpkg-query -f '${binary:Package}\n' -W 'vitalpbx*')
apt-mark unhold logger-core
```
**Step 6:** Update VitalPBX Repository <br>
Modifies the VitalPBX repository file to point to version 4.5..
```
sed -i 's/v4/v4.5/g' /etc/apt/sources.list.d/vitalpbx.list
```
**Step 7:** Disable Apache2 <br>
Stops and disables Apache2, modifying its configuration to avoid port conflicts.
```
systemctl stop apache2
systemctl disable apache2
sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
```
**Step 8:** Upgrade VitalPBX <br>
Updates VitalPBX packages to version 4.5.
```
apt update
apt upgrade -y
```
**Step 9:** Optimize the Server <br>
Runs scripts to optimize MariaDB, Nginx, and other VitalPBX-related configurations.
```
php /usr/share/vitalpbx/scripts/vitalpbx "optimizeMariaDB"
php /usr/share/vitalpbx/scripts/vitalpbx "optimizeNginxSettings"
```
**Step 10:** Remove Obsolete Packages <br>
Cleans up unused packages and performs general system cleanup.
```
DEBIAN_FRONTEND=noninteractive apt --purge autoremove -y
DEBIAN_FRONTEND=noninteractive apt autoclean -y
```
**Step 11:** Reboot the Server <br>
Reboots the system to apply all changes.
```
reboot
```

