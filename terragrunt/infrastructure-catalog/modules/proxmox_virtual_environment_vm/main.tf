resource "proxmox_virtual_environment_vm" "vm" {
  # Avoid unnecessary changes when CDROM, boot order, or the system disk image identifier are updated externally
  lifecycle {
    ignore_changes = [
      boot_order,
      cdrom,
      disk,
    ]
  }

  # ------------------------------
  # Required Arguments
  # ------------------------------
  node_name = var.node_name

  # ------------------------------
  # Optional Arguments
  # ------------------------------
  acpi                = try(var.acpi, true)
  bios                = try(var.bios, "seabios")
  boot_order          = try(var.boot_order, [])
  description         = try(var.description, null)
  keyboard_layout     = try(var.keyboard_layout, "en-us")
  kvm_arguments       = try(var.kvm_arguments, null)
  machine             = try(var.machine, "q35")
  migrate             = try(var.migrate, false)
  name                = try(var.name, null)
  on_boot             = try(var.on_boot, true)
  pool_id             = try(var.pool_id, null)
  protection          = try(var.protection, false)
  reboot              = try(var.reboot, false)
  reboot_after_update = try(var.reboot_after_update, true)
  scsi_hardware       = try(var.scsi_hardware, "virtio-scsi-single")
  started             = try(var.started, true)
  stop_on_destroy     = try(var.stop_on_destroy, false)
  tablet_device       = try(var.tablet_device, true)
  tags                = try(var.tags, [])
  template            = try(var.template, false)
  timeout_clone       = try(var.timeout_clone, 1800)
  timeout_create      = try(var.timeout_create, 1800)
  timeout_migrate     = try(var.timeout_migrate, 1800)
  timeout_reboot      = try(var.timeout_reboot, 1800)
  timeout_shutdown_vm = try(var.timeout_shutdown_vm, 1800)
  timeout_start_vm    = try(var.timeout_start_vm, 1800)
  timeout_stop_vm     = try(var.timeout_stop_vm, 300)
  vm_id               = try(var.vm_id, null)
  hook_script_file_id = try(var.hook_script_file_id, null)

  # ------------------------------
  # Dynamic Optional Blocks
  # ------------------------------

  dynamic "agent" {
    for_each = var.agent != null ? [var.agent] : []
    content {
      enabled = try(agent.value.enabled, false)
      timeout = try(agent.value.timeout, "15m")
      trim    = try(agent.value.trim, false)
      type    = try(agent.value.type, "virtio")
    }
  }

  dynamic "amd_sev" {
    for_each = var.amd_sev != null ? [var.amd_sev] : []
    content {
      type           = try(amd_sev.value.type, "std")
      allow_smt      = try(amd_sev.value.allow_smt, true)
      kernel_hashes  = try(amd_sev.value.kernel_hashes, false)
      no_debug       = try(amd_sev.value.no_debug, false)
      no_key_sharing = try(amd_sev.value.no_key_sharing, false)
    }
  }

  dynamic "audio_device" {
    for_each = var.audio_device != null ? [var.audio_device] : []
    content {
      device  = try(audio_device.value.device, "intel-hda")
      driver  = try(audio_device.value.driver, "spice")
      enabled = try(audio_device.value.enabled, true)
    }
  }

  dynamic "cdrom" {
    for_each = var.cdrom != null ? [var.cdrom] : []
    content {
      enabled   = try(cdrom.value.enabled, false)
      file_id   = try(cdrom.value.file_id, null)
      interface = try(cdrom.value.interface, "ide0")
    }
  }

  dynamic "clone" {
    for_each = var.clone != null ? [var.clone] : []
    content {
      datastore_id = try(clone.value.datastore_id, null)
      node_name    = try(clone.value.node_name, null)
      retries      = try(clone.value.retries, null)
      vm_id        = clone.value.source_vm_id
      full         = try(clone.value.full, true)
    }
  }

  dynamic "cpu" {
    for_each = var.cpu != null ? [var.cpu] : []
    content {
      architecture = try(cpu.value.architecture, null)
      cores        = try(cpu.value.cores, 1)
      flags        = try(cpu.value.flags, null)
      hotplugged   = try(cpu.value.hotplugged, 0)
      limit        = try(cpu.value.limit, 0)
      numa         = try(cpu.value.numa, false)
      sockets      = try(cpu.value.sockets, 1)
      type         = try(cpu.value.type, "x86-64-v2-AES")
      units        = try(cpu.value.units, 1024)
      affinity     = try(cpu.value.affinity, null)
    }
  }

  dynamic "disk" {
    for_each = var.disks != null && length(var.disks) > 0 ? var.disks : []
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
          iops_read            = try(disk.value.speed.iops_read, null)
          iops_read_burstable  = try(disk.value.speed.iops_read_burstable, null)
          iops_write           = try(disk.value.speed.iops_write, null)
          iops_write_burstable = try(disk.value.speed.iops_write_burstable, null)
          read                 = try(disk.value.speed.read, null)
          read_burstable       = try(disk.value.speed.read_burstable, null)
          write                = try(disk.value.speed.write, null)
          write_burstable      = try(disk.value.speed.write_burstable, null)
        }
      }
      ssd = try(disk.value.ssd, false)
    }
  }

  dynamic "efi_disk" {
    for_each = var.efi_disk != null ? [var.efi_disk] : []
    content {
      datastore_id      = try(efi_disk.value.datastore_id, "local-lvm")
      file_format       = try(efi_disk.value.file_format, "raw")
      type              = try(efi_disk.value.type, "2m")
      pre_enrolled_keys = try(efi_disk.value.pre_enrolled_keys, false)
    }
  }

  dynamic "hostpci" {
    for_each = var.hostpci_devices != null && length(var.hostpci_devices) > 0 ? var.hostpci_devices : []
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
    for_each = var.usb_devices != null && length(var.usb_devices) > 0 ? var.usb_devices : []
    content {
      host    = try(usb.value.host, null)
      mapping = try(usb.value.mapping, null)
      usb3    = try(usb.value.usb3, false)
    }
  }

  dynamic "initialization" {
    for_each = var.initialization != null ? [var.initialization] : []
    content {
      datastore_id = try(initialization.value.datastore_id, "local-lvm")
      interface    = try(initialization.value.interface, "ide2")

      dynamic "dns" {
        for_each = initialization.value.dns != null ? [1] : []
        content {
          domain  = try(initialization.value.dns.domain, null)
          servers = try(initialization.value.dns.servers, [])
        }
      }

      dynamic "ip_config" {
        for_each = try(initialization.value.ip_config, [])
        content {
          dynamic "ipv4" {
            for_each = try(ip_config.value.ipv4 != null ? [1] : [], [])
            content {
              address = try(ip_config.value.ipv4.address, null)
              gateway = try(ip_config.value.ipv4.gateway, null)
            }
          }

          dynamic "ipv6" {
            for_each = try(ip_config.value.ipv6 != null ? [1] : [], [])
            content {
              address = try(ip_config.value.ipv6.address, null)
              gateway = try(ip_config.value.ipv6.gateway, null)
            }
          }
        }
      }

      dynamic "user_account" {
        for_each = initialization.value.user_account != null ? [1] : []
        content {
          username = try(initialization.value.user_account.username, null)
          password = try(initialization.value.user_account.password, null)
          keys     = [trimspace(try(initialization.value.user_account.keys, null))]
        }
      }

      network_data_file_id = try(initialization.value.network_data_file_id, null)
      user_data_file_id    = try(initialization.value.user_data_file_id, null)
      vendor_data_file_id  = try(initialization.value.vendor_data_file_id, null)
      meta_data_file_id    = try(initialization.value.meta_data_file_id, null)
    }
  }

  dynamic "memory" {
    for_each = var.memory != null ? [var.memory] : []
    content {
      dedicated      = try(memory.value.dedicated, 512)
      floating       = try(memory.value.floating, 0)
      shared         = try(memory.value.shared, 0)
      hugepages      = try(memory.value.hugepages, null)
      keep_hugepages = try(memory.value.keep_hugepages, false)
    }
  }

  dynamic "numa" {
    for_each = var.numa != null ? [var.numa] : []
    content {
      device    = numa.value.device
      cpus      = numa.value.cpu.cpus
      memory    = numa.value.memory
      hostnodes = try(numa.value.hostnodes, null)
      policy    = try(numa.value.policy, "preferred")
    }
  }

  dynamic "network_device" {
    for_each = var.network_devices != null && length(var.network_devices) > 0 ? var.network_devices : []
    content {
      bridge       = try(network_device.value.bridge, "vmbr0")
      disconnected = try(network_device.value.disconnected, false)
      enabled      = try(network_device.value.enabled, true)
      firewall     = try(network_device.value.firewall, false)
      mac_address  = try(network_device.value.mac_address, null)
      model        = try(network_device.value.model, "virtio")
      mtu          = try(network_device.value.mtu, null)
      queues       = try(network_device.value.queues, null)
      rate_limit   = try(network_device.value.rate_limit, null)
      vlan_id      = try(network_device.value.vlan_id, null)
      trunks       = try(network_device.value.trunks, null)
    }
  }

  dynamic "rng" {
    for_each = var.rng != null ? [var.rng] : []
    content {
      source    = try(rng.value.source, "/dev/urandom")
      max_bytes = try(rng.value.max_bytes, 1024)
      period    = try(rng.value.period, 1000)
    }
  }

  dynamic "serial_device" {
    for_each = var.serial_devices != null && length(var.serial_devices) > 0 ? var.serial_devices : []
    content {
      device = try(serial_device.value.device, "socket")
    }
  }

  dynamic "smbios" {
    for_each = var.smbios != null ? [var.smbios] : []
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
    for_each = var.startup != null ? [var.startup] : []
    content {
      order      = startup.value.order
      up_delay   = try(startup.value.up_delay, 0)
      down_delay = try(startup.value.down_delay, 0)
    }
  }

  dynamic "tpm_state" {
    for_each = var.tpm_state != null ? [var.tpm_state] : []
    content {
      datastore_id = try(tpm_state.value.datastore_id, "local-lvm")
      version      = try(tpm_state.value.version, "v2.0")
    }
  }

  dynamic "vga" {
    for_each = var.vga != null ? [var.vga] : []
    content {
      memory    = try(vga.value.memory, 16)
      type      = try(vga.value.type, "std")
      clipboard = try(vga.value.clipboard, null)
    }
  }

  dynamic "virtiofs" {
    for_each = var.virtiofs != null && length(var.virtiofs) > 0 ? var.virtiofs : []
    content {
      mapping      = virtiofs.value.mapping
      cache        = try(virtiofs.value.cache, null)
      direct_io    = try(virtiofs.value.direct_io, null)
      expose_acl   = try(virtiofs.value.expose_acl, null)
      expose_xattr = try(virtiofs.value.expose_xattr, null)
    }
  }
}
