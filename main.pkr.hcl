variable "proxmox_node" {
}
variable "proxmox_username" {
}
variable "proxmox_password" {
}
variable "vm_username" {
}
variable "vm_authorized_key" {
}
variable "vm_password_sha" {
}
variable "vm_id" {
}
variable "vm_name" {
}
variable "vm_memory" {
}
variable "vm_cores" {
}
variable "vm_disk_size" {
}
variable "proxmox_url" {
  default = "https://192.168.1.12:8006/api2/json"
}
variable "os_type" {
  default = "l26"
}
variable "os_iso" {
  default = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
}
variable "os_iso_checksum" {
  default = "sha256:c3514bf0056180d09376462a7a1b4f213c1d6e8ea67fae5c25099c6fd3d8274b"
}
variable "ssh_private_key_file" {
  default = "~/.ssh/proxmox-gitlab"
}
variable "ssh_username" {
  default = "gitlab"
}
variable "ssh_timeout" {
  default = "30m"
}
locals {
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/http/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/http/user-data",
      {
        vm_username       = var.vm_username
        vm_password       = var.vm_password_sha
        vm_authorized_key = var.vm_authorized_key
      }
    )
  }
  boot_command = [
    "c<wait><wait><wait>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\" <enter>",
    "<enter><wait>",
    "initrd /casper/initrd<wait>",
    "<enter><wait>",
    "boot<wait>",
    "<enter>",
    "<wait><wait><wait><wait><wait>",
  ]
}

source "proxmox-iso" "ubuntu2404" {
  proxmox_url              = var.proxmox_url
  node                     = var.proxmox_node
  username                 = var.proxmox_username
  password                 = var.proxmox_password
  vm_name                  = var.vm_name
  vm_id                    = var.vm_id
  insecure_skip_tls_verify = true
  memory                   = var.vm_memory
  cores                    = var.vm_cores
  scsi_controller          = "virtio-scsi-pci"
  os                       = var.os_type
  disks {
    disk_size    = var.vm_disk_size
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  boot_iso {
    type         = "scsi"
    iso_file     = var.os_iso
    iso_checksum = var.os_iso_checksum
    unmount      = true
  }
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  #cloud_init              = true
  #cloud_init_storage_pool = "local-lvm"
  http_content         = local.data_source_content
  ssh_username         = var.ssh_username
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = var.ssh_timeout
  boot_command         = local.boot_command
  boot_wait            = "10s"
}
build {
  sources = ["source.proxmox-iso.ubuntu2404"]
  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
    user          = var.vm_username
    extra_arguments = [
      "-vvv"
    ]
  }
}
