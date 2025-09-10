#  GitLab Hosted Infrastructure with Packer

This project automates the deployment of a self-hosted GitLab instance using HashiCorp Packer to create a Proxmox VM image, followed by Ansible provisioning to install and configure GitLab.

## 🏗️ Architecture

- **Packer**: Creates a Proxmox VM image from Ubuntu 24.04.3 Live Server ISO
- **Ansible**: Provisions the VM with GitLab installation and configuration
- **Proxmox**: Hypervisor platform for VM management
- **Ubuntu 24.04.3**: Base operating system

## 📁 Project Structure

```
gitlab-hosted/
├── main.pkr.hcl              # Main Packer configuration
├── packer.pkr.hcl            # Packer plugin requirements
├── sensitive.pkrvars.hcl     # Sensitive variables (gitignored)
├── ansible/                  # Ansible playbooks and roles
│   ├── playbook.yml         # Main playbook
│   └── roles/
│       └── gitlab/          # GitLab installation role
├── http/                     # Cloud-init configuration
│   ├── meta-data            # Instance metadata
│   └── user-data            # User data script
└── README.md                 # This file
```

## 🚀 Prerequisites

- **Packer** (>= 1.8.0)
- **Proxmox VE** (>= 7.0)
- **SSH Key Pair** for VM access
- **Ubuntu 24.04.3 ISO** uploaded to Proxmox storage

##  ⚙️ Configuration

### Required Variables

Create a `sensitive.pkrvars.hcl` file with the following variables:

```hcl
proxmox_node        = "your-proxmox-node"
proxmox_username    = "your-proxmox-username"
proxmox_password    = "your-proxmox-password"
vm_username         = "gitlab"
vm_authorized_key   = "your-ssh-public-key"
vm_password_sha     = "sha256-hash-of-password"
vm_id               = "1001"
vm_name             = "gitlab-server"
vm_memory           = "8192"
vm_cores            = "4"
vm_disk_size        = "100G"
```

### Optional Variables

- `proxmox_url`: Proxmox API endpoint (defaults to `https://192.168.1.12:8006/api2/json`)

## 🔧 Usage

### 1. Initialize Packer

```bash
packer init .
```

### 2. Validate Configuration

```bash
packer validate -var-file=sensitive.pkrvars.hcl .
```

### 3. Build Image

```bash
packer build -var-file=sensitive.pkrvars.hcl .
```

### 4. Deploy with Ansible

```bash
cd ansible
ansible-playbook -i inventory playbook.yml
```

## 🎯 Features

- **Automated VM Creation**: Packer automatically creates and configures the VM
- **Cloud-Init Integration**: Automated OS configuration during boot
- **SSH Key Authentication**: Secure access to the VM
- **Ansible Provisioning**: Automated GitLab installation and configuration
- **Proxmox Integration**: Native Proxmox VE support

## 🔒 Security Notes

- The `sensitive.pkrvars.hcl` file is gitignored to prevent committing sensitive data
- SSH key-based authentication is used for secure VM access
- TLS verification is disabled for Proxmox API (configure as needed for production)

## 📋 Requirements

- **VM Resources**: Minimum 8GB RAM, 4 CPU cores, 100GB disk
- **Network**: Bridge network access (vmbr0)
- **Storage**: Local LVM storage pool with sufficient space

## 🐛 Troubleshooting

### Common Issues

1. **SSH Connection Failed**: Verify SSH key path and permissions
2. **ISO Not Found**: Ensure Ubuntu ISO is uploaded to Proxmox storage
3. **Insufficient Resources**: Check VM resource allocation
4. **Network Issues**: Verify bridge configuration and network access

### Debug Mode

Enable verbose output by modifying the Ansible provisioner in `main.pkr.hcl`:

```hcl
extra_arguments = [
  "-vvv"
]
```

## 📚 Additional Resources

- [Packer Documentation](https://www.packer.io/docs)
- [Proxmox Packer Plugin](https://github.com/hashicorp/packer-plugin-proxmox)
- [GitLab Installation Guide](https://about.gitlab.com/install/)
- [Ubuntu Cloud-Init Documentation](https://cloudinit.readthedocs.io/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

