resource "proxmox_virtual_environment_vm" "vm" {
  # ------------------------------
  # Required Arguments
  # ------------------------------
  node_name = var.node_name

  # ------------------------------
  # Optional Arguments
  # ------------------------------
  acpi                 = try(var.acpi, true)
  bios                 = try(var.bios, "seabios")
  boot_order           = try(var.boot_order, [])
  description          = try(var.description, null)
  keyboard_layout      = try(var.keyboard_layout, "en-us")
  kvm_arguments        = try(var.kvm_arguments, null)
  machine              = try(var.machine, "q35")
  migrate              = try(var.migrate, false)
  name                 = try(var.name, null)
  on_boot              = try(var.on_boot, true)
  pool_id              = try(var.pool_id, null)
  protection           = try(var.protection, false)
  reboot               = try(var.reboot, false)
  reboot_after_update  = try(var.reboot_after_update, true)
  scsi_hardware        = try(var.scsi_hardware, "virtio-scsi-single")
  started              = try(var.started, true)
  stop_on_destroy      = try(var.stop_on_destroy, false)
  tablet_device        = try(var.tablet_device, true)
  tags                 = try(var.tags, [])
  template             = try(var.template, false)
  timeout_clone        = try(var.timeout_clone, 1800)
  timeout_create       = try(var.timeout_create, 1800)
  timeout_migrate      = try(var.timeout_migrate, 1800)
  timeout_reboot       = try(var.timeout_reboot, 1800)
  timeout_shutdown_vm  = try(var.timeout_shutdown_vm, 1800)
  timeout_start_vm     = try(var.timeout_start_vm, 1800)
  timeout_stop_vm      = try(var.timeout_stop_vm, 300)
  vm_id                = try(var.vm_id, null)
  hook_script_file_id  = try(var.hook_script_file_id, null)

  # ------------------------------
  # Dynamic Optional Blocks
  # ------------------------------

  dynamic "agent" {
    for_each = var.optional_blocks.agent ? [1] : []
    content {
      enabled = try(var.agent_enabled, false)
      timeout = try(var.agent_timeout, "15m")
      trim    = try(var.agent_trim, false)
      type    = try(var.agent_type, "virtio")
    }
  }

  dynamic "amd_sev" {
    for_each = var.optional_blocks.amd_sev ? [1] : []
    content {
      type            = try(var.amd_sev_type, "std")
      allow_smt       = try(var.amd_sev_allow_smt, true)
      kernel_hashes   = try(var.amd_sev_kernel_hashes, false)
      no_debug        = try(var.amd_sev_no_debug, false)
      no_key_sharing  = try(var.amd_sev_no_key_sharing, false)
    }
  }

  dynamic "audio_device" {
    for_each = var.optional_blocks.audio_device ? [1] : []
    content {
      device  = try(var.audio_device_device, "intel-hda")
      driver  = try(var.audio_device_driver, "spice")
      enabled = try(var.audio_device_enabled, true)
    }
  }

  dynamic "cdrom" {
    for_each = var.optional_blocks.cdrom ? [1] : []
    content {
      enabled   = try(var.cdrom_enabled, false)
      file_id   = try(var.cdrom_file_id, null)
      interface = try(var.cdrom_interface, "ide0")
    }
  }

  dynamic "clone" {
    for_each = var.optional_blocks.clone ? [1] : []
    content {
      datastore_id = try(var.clone_datastore_id, null)
      node_name    = try(var.clone_node_name, null)
      retries      = try(var.clone_retries, null)
      vm_id        = var.clone_source_vm_id
      full         = try(var.clone_full, true)
    }
  }

  dynamic "cpu" {
    for_each = var.optional_blocks.cpu ? [1] : []
    content {
      architecture = try(var.cpu_architecture, "x86_64")
      cores        = try(var.cpu_cores, 1)
      flags        = try(var.cpu_flags, null)
      hotplugged   = try(var.cpu_hotplugged, 0)
      limit        = try(var.cpu_limit, 0)
      numa         = try(var.cpu_numa, false)
      sockets      = try(var.cpu_sockets, 1)
      type         = try(var.cpu_type, "x86-64-v2-AES")
      units        = try(var.cpu_units, 1024)
      affinity     = try(var.cpu_affinity, null)
    }
  }

  dynamic "disk" {
    for_each = var.optional_blocks.disk ? var.disks : []
    content {
      aio               = try(disk.value.aio, "io_uring")
      backup            = try(disk.value.backup, true)
      cache             = try(disk.value.cache, "none")
      datastore_id      = try(disk.value.datastore_id, "local-lvm")
      path_in_datastore = try(disk.value.path_in_datastore, null)
      discard           = try(disk.value.discard, "ignore")
      file_format       = try(disk.value.file_format, null)
      file_id           = try(disk.value.file_id, null)
      interface         = disk.value.interface
      iothread          = try(disk.value.iothread, false)
      replicate         = try(disk.value.replicate, true)
      serial            = try(disk.value.serial, null)
      size              = try(disk.value.size, 8)
      dynamic "speed" {
        for_each = contains(keys(disk.value), "speed") && disk.value.speed != null ? [1] : []
        content {
            iops_read             = try(disk.value.speed.iops_read, null)
            iops_read_burstable   = try(disk.value.speed.iops_read_burstable, null)
            iops_write            = try(disk.value.speed.iops_write, null)
            iops_write_burstable  = try(disk.value.speed.iops_write_burstable, null)
            read                  = try(disk.value.speed.read, null)
            read_burstable        = try(disk.value.speed.read_burstable, null)
            write                 = try(disk.value.speed.write, null)
            write_burstable       = try(disk.value.speed.write_burstable, null)
        }
      }
      ssd               = try(disk.value.ssd, false)
    }
  }

  dynamic "efi_disk" {
    for_each = var.optional_blocks.efi_disk && var.efi_disk != null ? [1] : []
    content {
      datastore_id      = try(var.efi_disk.datastore_id, "local-lvm")
      file_format       = try(var.efi_disk.file_format, "raw")
      type              = try(var.efi_disk.type, "2m")
      pre_enrolled_keys = try(var.efi_disk.pre_enrolled_keys, false)
    }
  }

  dynamic "hostpci" {
    for_each = var.optional_blocks.hostpci ? var.hostpci_devices : []
    content {
      device   = hostpci.value.device
      id       = try(hostpci.value.id, null)
      mapping  = try(hostpci.value.mapping, null)
      mdev     = try(hostpci.value.mdev, null)
      pcie     = try(hostpci.value.pcie, null)
      rombar   = try(hostpci.value.rombar, true)
      rom_file = try(hostpci.value.rom_file, null)
      xvga     = try(hostpci.value.xvga, null)
    }
  }

  dynamic "usb" {
    for_each = var.optional_blocks.usb ? var.usb_devices : []
    content {
      host    = try(usb.value.host, null)
      mapping = try(usb.value.mapping, null)
      usb3    = try(usb.value.usb3, false)
    }
  }

  dynamic "initialization" {
    for_each = var.optional_blocks.initialization ? [1] : []
    content {
      datastore_id = try(var.initialization.datastore_id, "local-lvm")
      interface    = try(var.initialization.interface, "ide2")

      dynamic "dns" {
        for_each = lookup(var.initialization, "dns", null) != null ? [1] : []
        content {
          domain  = try(var.initialization.dns.domain, null)
          servers = try(var.initialization.dns.servers, [])
        }
      }

      dynamic "ip_config" {
        for_each = try(var.initialization.ip_config, [])
        content {
          dynamic "ipv4" {
            for_each = lookup(ip_config.value, "ipv4", null) != null ? [1] : []
            content {
              address = try(ip_config.value.ipv4.address, null)
              gateway = try(ip_config.value.ipv4.gateway, null)
            }
          }

          dynamic "ipv6" {
            for_each = lookup(ip_config.value, "ipv6", null) != null ? [1] : []
            content {
              address = try(ip_config.value.ipv6.address, null)
              gateway = try(ip_config.value.ipv6.gateway, null)
            }
          }
        }
      }

      dynamic "user_account" {
        for_each = lookup(var.initialization, "user_account", null) != null ? [1] : []
        content {
          username = try(var.initialization.user_account.username, null)
          password = try(var.initialization.user_account.password, null)
          keys     = try(var.initialization.user_account.keys, null)
        }
      }

      network_data_file_id = try(var.initialization.network_data_file_id, null)
      user_data_file_id    = try(var.initialization.user_data_file_id, null)
      vendor_data_file_id  = try(var.initialization.vendor_data_file_id, null)
      meta_data_file_id    = try(var.initialization.meta_data_file_id, null)
    }
  }

  dynamic "memory" {
    for_each = var.optional_blocks.memory ? [1] : []
    content {
      dedicated      = try(var.memory.dedicated, 512)
      floating       = try(var.memory.floating, 0)
      shared         = try(var.memory.shared, 0)
      hugepages      = try(var.memory.hugepages, null)
      keep_hugepages = try(var.memory.keep_hugepages, false)
    }
  }

  dynamic "numa" {
    for_each = var.optional_blocks.numa ? [1] : []
    content {
      device     = numa.value.device
      cpus       = numa.value.cpus
      memory     = numa.value.memory
      hostnodes  = try(numa.value.hostnodes, null)
      policy     = try(numa.value.policy, "preferred")
    }
  }

  dynamic "network_device" {
    for_each = var.optional_blocks.network_device ? var.network_devices : []
    content {
      bridge      = try(network_device.value.bridge, "vmbr0")
      disconnected = try(network_device.value.disconnected, false)
      enabled     = try(network_device.value.enabled, true)
      firewall    = try(network_device.value.firewall, false)
      mac_address = try(network_device.value.mac_address, null)
      model       = try(network_device.value.model, "virtio")
      mtu         = try(network_device.value.mtu, null)
      queues      = try(network_device.value.queues, null)
      rate_limit  = try(network_device.value.rate_limit, null)
      vlan_id     = try(network_device.value.vlan_id, null)
      trunks      = try(network_device.value.trunks, null)
    }
  }

  dynamic "rng" {
    for_each = var.optional_blocks.rng ? [1] : []
    content {
      source     = try(var.rng_source, "/dev/urandom")
      max_bytes  = try(var.rng_max_bytes, 1024)
      period     = try(var.rng_period, 1000)
    }
  }

  dynamic "serial_device" {
    for_each = var.optional_blocks.serial_device ? var.serial_devices : []
    content {
      device = try(serial_device.value.device, "socket")
    }
  }

  dynamic "smbios" {
    for_each = var.optional_blocks.smbios ? [1] : []
    content {
      family       = try(serial_device.value.family)
      manufacturer = try(serial_device.value.manufacturer)
      product      = try(serial_device.value.product)
      serial       = try(serial_device.value.serial)
      sku          = try(serial_device.value.sku)
      uuid         = try(serial_device.value.uuid)
      version      = try(serial_device.value.version)
    }
  }

  dynamic "startup" {
    for_each = var.optional_blocks.startup ? [1] : []
    content {
      order      = var.startup_order
      up_delay   = try(var.startup_up_delay, 0)
      down_delay = try(var.startup_down_delay, 0)
    }
  }

  dynamic "tpm_state" {
    for_each = var.optional_blocks.tpm_state ? [1] : []
    content {
      datastore_id = try(var.tpm_state.datastore_id, "local-lvm")
      version      = try(var.tpm_state.version, "v2.0")
    }
  }

  dynamic "vga" {
    for_each = var.optional_blocks.vga ? [1] : []
    content {
      memory    = try(var.vga_memory, 16)
      type      = try(var.vga_type, "std")
      clipboard = try(var.vga_clipboard, null)
    }
  }

  dynamic "virtiofs" {
    for_each = var.virtiofs != null ? var.virtiofs : []
    content {
      mapping       = virtiofs.value.mapping
      cache         = try(virtiofs.value.cache, null)
      direct_io     = try(virtiofs.value.direct_io, null)
      expose_acl    = try(virtiofs.value.expose_acl, null)
      expose_xattr  = try(virtiofs.value.expose_xattr, null)
    }
  }

  dynamic "watchdog" {
    for_each = var.optional_blocks.watchdog ? [1] : []
    content {
      enabled = try(var.watchdog_enabled, false)
      model   = try(var.watchdog_model, "i6300esb")
      action  = try(var.watchdog_action, "none")
    }
  }
}
