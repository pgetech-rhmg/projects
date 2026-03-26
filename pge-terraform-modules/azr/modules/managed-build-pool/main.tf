/*
 * # Azure Managed Build Pool module
 * Terraform module which creates self-hosted Azure DevOps build agents using VMSS in Azure.
 * This module provisions a complete build infrastructure with VNet, Subnet, NSG, and VMSS.
*/

#
# Filename    : azr/modules/managed-build-pool/main.tf
# Date        : 11 Mar 2026
# Author      : PGE
# Description : Azure Managed Build Pool module for self-hosted ADO agents
#

# Module      : Managed Build Pool
# Description : This terraform module creates a self-hosted build pool using Azure VMSS.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "~> 1.0"
    }
  }
}

# Create Virtual Network for build agents
# NOTE: address_space is now configurable from YAML (ado.network.vnet_address_space)
resource "azurerm_virtual_network" "ado_vnet" {
  name                = "vnet-${var.partner_name}-agents"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Create Subnet for build agents
# NOTE: address_prefix is now configurable from YAML (ado.network.subnet_address_prefix)
resource "azurerm_subnet" "ado_agents" {
  name                 = "subnet-buildagents-${var.partner_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.ado_vnet.name
  address_prefixes     = [var.subnet_address_prefix]
}

# Create Network Security Group for agents
# NOTE: Security rules are now configurable via security_rules variable
resource "azurerm_network_security_group" "ado_nsg" {
  name                = "nsg-buildagents-${var.partner_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }

  tags = var.tags
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "ado_nsg_assoc" {
  subnet_id                 = azurerm_subnet.ado_agents.id
  network_security_group_id = azurerm_network_security_group.ado_nsg.id
}

# Generate SSH keys for Linux agents
resource "tls_private_key" "build_agents" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create Linux Virtual Machine Scale Set for build agents
resource "azurerm_linux_virtual_machine_scale_set" "build_agents" {
  count               = var.build_agent_image == "Ubuntu-22.04" ? 1 : 0
  name                = "vmss-${var.partner_name}-agents"
  location            = var.location
  resource_group_name = var.resource_group_name
  upgrade_mode        = "Automatic"

  sku = var.build_agent_sku

  instances = var.build_agent_instances

  # Use Managed Identity for secure authentication
  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.build_agents.public_key_openssh
  }

  network_interface {
    name    = "nic-${var.partner_name}-agents"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = azurerm_subnet.ado_agents.id
    }
  }

  # Install ADO build agent via custom data script
  # Pass configuration variables to the script via environment
  custom_data = base64encode(join("", [
    "#!/bin/bash\n",
    "export ADO_URL='${var.ado_url}'\n",
    "export ADO_PAT_TOKEN='${var.ado_pat_token}'\n",
    "export POOL_NAME='ado-${var.partner_name}-pool'\n",
    "export AGENT_PREFIX='${var.partner_name}'\n",
    "export MANAGED_IDENTITY_ID='${var.managed_identity_id}'\n",
    file("${path.module}/scripts/install-build-agent.sh")
  ]))

  tags = merge(
    var.tags,
    {
      "purpose" = "build-agents"
      "partner" = var.partner_name
    }
  )
}

# Create ADO Agent Pool
resource "azuredevops_agent_pool" "pool" {
  name = "ado-${var.partner_name}-pool"
}
