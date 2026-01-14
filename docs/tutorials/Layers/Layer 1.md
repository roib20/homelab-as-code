# Layer 1: Debian Preseed

## How to install Debian with my preseed file

1. Download a [Debian netinst ISO](https://www.debian.org/CD/netinst/).
2. Load it onto a USB. For this purpose, I usually use [Ventoy](https://www.ventoy.net/), [Rufus](https://rufus.ie/) or [balenaEtcher](https://etcher.balena.io/).
3. Configure BIOS settings to UEFI mode (**not** LEGACY) and Secure Boot **ON**.
4. Boot into the USB. Prefer not to change the boot order, instead do a one-time boot.
5. Once the Debian installer boots, select "Advanced options ..." then "Graphical automated install" (NOTE: if the graphical installer doesn't boot, try the regular "... Automated install" option).
6. Under "Location of inital preconfiguration file", type a URL or local IP of a webserver serving the `preseed.cfg` file.
6a. If this repository is public, I can use: [https://github.com/roib20/homelab-as-code/tree/debian-preseed/debian](https://github.com/roib20/homelab-as-code/tree/debian-preseed/debian)
6b. Alternatively, open a terminal in the "debian" directory and run a temporary webserver on a local IP: `python3 -m http.server 80`
7. Continue with the installation. I will need to choose a password for the default user (for security reasons, a password is not included in the public `preseed.cfg` file).
8. Assuming the preseed file is correct and the correct drive exists on the system, the rest of the installation should continue automatically with no further input needed.
9. Once the installation completes succefuly, Debian will automatically reboot. If the UEFI boot order is correct, the new Debian installation will automatically boot.
10. **I** can login into the system from its DHCP IP using my SSH keys.
