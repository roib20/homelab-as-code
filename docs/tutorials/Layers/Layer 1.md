# Layer 1: Debian Preseed

Install Debian consistently across nodes using the `debian/preseed.cfg` file.

## What this layer does

- Installs a baseline Debian OS
- Configures SSH access and base packages
- Standardizes disk layout

## Steps

1. Download a [Debian netinst ISO](https://www.debian.org/CD/netinst/).
2. Load it onto a USB. For this purpose, use [Ventoy](https://www.ventoy.net/), [Rufus](https://rufus.ie/) or [balenaEtcher](https://etcher.balena.io/).
3. Configure BIOS settings to UEFI mode (**not** LEGACY) and Secure Boot **ON**.
4. Boot into the USB and choose a one-time boot.
5. Select "Advanced options ..." then "Graphical automated install".
6. Under "Location of initial preconfiguration file", provide a URL to `preseed.cfg`.
   - Public repository option: [https://github.com/roib20/homelab-as-code/tree/debian-preseed/debian](https://github.com/roib20/homelab-as-code/tree/debian-preseed/debian)
   - Local webserver option: `python3 -m http.server 80` from the `debian` directory.
7. Choose a password for the default user when prompted.
8. Let the installation run to completion. Debian will reboot automatically.

## Verification

- Confirm the node boots into Debian without manual intervention.
- Verify SSH access from your workstation.

## Next step

Proceed to [Layer 2: Ansible (pve-cluster)](Layer%202).

## Troubleshooting

- If preseed download fails, verify the URL is reachable on the installer network.
- If the installer hangs, try the non-graphical automated install option.
- If SSH is unavailable, confirm the user password and IP address.
