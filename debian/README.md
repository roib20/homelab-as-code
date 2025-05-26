# Opinonated Automated Debian Install with d-i preseed

This project's goal is to automate as much as possible. For this purpose, I wanted a solution to automate my Debian installs, primarily for installing Debian bare-mental as a base for my Proxmox VE nodes.

For this purpose, I am using [DebianInstaller](https://wiki.debian.org/DebianInstaller) [Preseed](https://wiki.debian.org/DebianInstaller/Preseed).

## Opinonated Install

The preseed file included here is designed to install my prefered Debian base OS. It configures EFI, boot and root partitions with Btrfs (with zstd compression) and my **public SSH keys**. As such, this specific preseed file is designed for my personal use only (after all, I don't want my public SSH keys to accidently end up on anyone else's machines).

> If I are going to use this, at the very least remove my public SSH keys. Otherwise refer to [the Debian documentation on Preseed](https://wiki.debian.org/DebianInstaller/Preseed).

For hardening, "root" user is disabled.

Other settings are kept mostly default or sane defaults/fallbacks, requiring minimal input during the installation. However not everything is configured during the install. The goal is to get the basic OS environment up and running with SSH access to then allow further configuration using Ansible.

## How to install Debian with this preseed

1. Download a [Debian netinst ISO](https://www.debian.org/CD/netinst/).
2. Load it onto a USB. For this purpose, I usually use [Ventoy](https://www.ventoy.net/), [Rufus](https://rufus.ie/) or [balenaEtcher](https://etcher.balena.io/).
3. Configure BIOS settings to UEFI mode (**not** LEGACY) and Secure Boot **ON**.
4. Boot into the USB. Prefer not to change the boot order, instead do a one-time boot.
5. Once the Debian installer boots, select "Advanced options ..." then "Graphical automated install" (NOTE: if the graphical installer doesn't boot, try the regular "... Automated install" option).
6. Under "Location of inital preconfiguration file", type a URL or local IP of a webserver serving the `preseed.cfg` file.
6a. If this repository is public, I can use: <https://github.com/roib20/homelab-as-code/tree/debian-preseed/debian>
6b. Alternatively, open a terminal in the "debian" directory and run a temporary webserver on a local IP: `python3 -m http.server 80`
7. Continue with the installation. I will need to choose a password for the default user (for security reasons, a password is not included in the public `preseed.cfg` file).
8. Assuming the preseed file is correct and the correct drive exists on the system, the rest of the installation should continue automatically with no further input needed.
9. Once the installation completes succefuly, Debian will automatically reboot. If the UEFI boot order is correct, the new Debian installation will automatically boot.
10. **I** can login into the system from its DHCP IP using my SSH keys.

## Other solutions for automating installs

I considered other solutions for automating OS installs:

* [**Cloud-init**](https://cloud-init.io/): I am already using Cloud-init with Proxmox VE, previously with my [Proxmox Scripts](https://github.com/roib20/proxmox-scripts/tree/main/proxmox-cloudinit-script) and now with the [bpg/proxmox Terraform provider](https://registry.terraform.io/providers/bpg/proxmox/). Cloud-init works well with virtualized and cloud environments, including Proxmox VE. However, I have found it trickier to use bare-metal, although it should be possible.

* [**FAI**](https://fai-project.org/): This is a cool project which I experimented with, thpugh ultimately I didn't want to rely on self-hosting a server or the hosted [FAI.ME build service](https://fai-project.org/FAIme).

* [**Proxmox Automated Installation**](https://pve.proxmox.com/wiki/Automated_Installation): [Introduced with Proxmox VE 8.2](https://www.proxmox.com/en/services/training-courses/videos/proxmox-virtual-environment/whats-new-in-proxmox-ve-8-2), Proxmox has its own solution for automated and unattended installation. I like that they use a modern format: [Answer File Format](https://pve.proxmox.com/wiki/Automated_Installation#Answer_File_Format) (TOML). If installing Proxmox VE directly I would go with this solution. However, the Ansible role I am using for configuring the PVE cluster, [lae.proxmox](https://galaxy.ansible.com/ui/standalone/roles/lae/proxmox/documentation/), recommends using Debian as base. In the past I have also had issues with the Proxmox VE installer not booting on some machines, whereas the Debian installer for me always booted with no problems (then [Proxmox VE can be installed on top of Debian](https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_12_Bookworm)).

* [**Ubuntu autoinstall**](https://canonical-subiquity.readthedocs-hosted.com/en/latest/intro-to-autoinstall.html): Ubuntu itself dropped support for *debian-installer* preseeding and instead now uses its own autoinstall solution (in addition to Cloud-init). Ubuntu autoinstall is not supported in upstream Debian, leading to an interesting divergance between Debian and Ubuntu.

* [**bootc**](https://bootc-dev.github.io/bootc/): This is an exciting "bootable containers" project which I experimented a bit with and hope to work more with in the future. Over on the Fedora and Red Hat side, bootc is progressing rapidly. I experimented with [uBlue](https://universal-blue.org/) and even ran a custom built [Bluefin](https://projectbluefin.io/) desktop for a few months (built with [ublue-os/image-template](https://github.com/ublue-os/image-template) and later [BlueBuild](https://blue-build.org/)). I hope Debian also supports bootc in the future more directly.

* **PXE**: This in theory allows fully automating installation without even touching the machine. This may be something I experiment with in the future in my homelab.
