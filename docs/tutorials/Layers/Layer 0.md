# Layer 0: Hardware

Prepare the physical hardware and networking before provisioning any software.

## Goals

- Stable power and network connectivity
- Consistent node naming and IP addressing
- Console access for initial install

## Steps

1. Prepare hardware, minimum of three nodes. For example, Intel N150 mini PCs (GMKtec NucBox G3 Plus) for two nodes.
2. Connect each node to a UPS or stable power source.
3. Connect each node to wired Ethernet (switch or router).
4. Attach a display and USB keyboard for Debian installation.

## Verification

- Note each node's MAC address and DHCP IP.
- Confirm you can access the BIOS/UEFI menu.

## Next step

Proceed to [Layer 1: Debian Preseed](Layer%201).

## Troubleshooting

- If a node does not appear on the network, confirm the NIC and switch port.
- If the BIOS menu is unavailable, reseat storage and memory.
