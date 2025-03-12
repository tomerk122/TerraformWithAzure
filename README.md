# TerraformWithAzure

This project uses Terraform to provision Azure infrastructure, including a virtual machine with proper networking.

## Infrastructure Components

The terraform configuration (`tomer.tf`) creates:

- Azure Resource Group in East US
- Virtual Network with a subnet (10.0.0.0/16)
- Network Security Group with SSH access (port 22)
- Public IP address
- Network Interface with security group association
- Ubuntu 18.04 Linux VM (Standard_B1s size)

## Prerequisites

- Terraform installed
- Azure CLI installed and authenticated
- SSH key pair (default: `~/.ssh/azure_key`)

## Getting Started

1. Clone this repository
2. Generate an SSH key pair if you don't have one:
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_key -C azureuser
   ```
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Preview the infrastructure changes:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Connecting to the VM

After successful deployment, you can connect to your VM using:

```bash
ssh -i ~/.ssh/azure_key azureuser@<VM_PUBLIC_IP>
```

## Clean Up

To destroy all resources created by this configuration:

```bash
terraform destroy
```

## Security Notes

- The default configuration opens SSH access from any IP address
- User credentials and SSH keys should be properly secured
- The subscription ID is exposed in the configuration file