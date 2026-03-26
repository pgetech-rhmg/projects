#
# Filename    : azr/modules/network/main.tf
# Date        : 12 Mar 2026
# Author      : PGE
# Description : Azure network module creating VNet, subnets, NSGs, and related resources
#
# Module      : Network
# Description : This terraform module provisions a virtual network with standard
#               subnets, network security groups, and transit routing for
#               partner deployments. It supports Infoblox-calculated CIDRs,
#               YAML fallback, and SAF2.0 compliant tagging via workspace-info.

# VNet configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}

# ============================================================================
# Workspace Info & Module Tags
# ============================================================================

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

locals {
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

locals {
  # ========================================
  # CIDR HANDLING
  # ========================================
  # CIDR comes from Infoblox deployment script.
  # The deployment script returns pre-calculated subnet CIDRs.
  # 
  # IMPORTANT: When deployment script is being updated, its outputs are
  # "known after apply". We need fallback for both null AND empty string.
  # coalesce() only handles null, not empty strings!
  # ========================================

  # Placeholder CIDR - used when real CIDR is null or empty
  placeholder_cidr = "10.255.0.0/22"

  # Use real CIDR if not null AND not empty, otherwise placeholder
  # NOTE: coalesce() doesn't work for empty strings - must use conditional
  effective_cidr = (
    var.calculated_vnet_address_space != null && var.calculated_vnet_address_space != ""
    ? var.calculated_vnet_address_space
    : local.placeholder_cidr
  )

  # Final address space for VNet - NEVER empty due to fallback
  vnet_address_space = [local.effective_cidr]

  # Flag to detect if we have a valid CIDR from Infoblox
  has_valid_cidr = var.calculated_vnet_address_space != null && var.calculated_vnet_address_space != ""

  vnet_config = {
    name          = try(var.partner_config.network.vnet_name, try(var.partner_config.network.vnet.name, "vnet-${var.partner_name}-001"))
    address_space = local.vnet_address_space
  }

  # ========================================
  # STATIC SUBNET NAMES - defined statically for for_each compatibility
  # Address prefixes come from Infoblox CIDR at apply time
  # ========================================
  static_subnet_names = ["compute-subnet", "privateendpoint-subnet", "ado-agents-subnet"]

  # Static subnet configurations (names and settings are known at plan time)
  static_subnet_configs = {
    "compute-subnet" = {
      index = 0
      service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.Web",
        "Microsoft.Storage"
      ]
      delegation_name                   = "ase-delegation"
      delegation_service_name           = "Microsoft.Web/hostingEnvironments"
      private_endpoint_network_policies = ""
    }
    "privateendpoint-subnet" = {
      index = 1
      service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.Storage",
        "Microsoft.Sql",
        "Microsoft.AzureCosmosDB"
      ]
      delegation_name                   = ""
      delegation_service_name           = ""
      private_endpoint_network_policies = "Disabled"
    }
    "ado-agents-subnet" = {
      index = 2
      service_endpoints = [
        "Microsoft.KeyVault",
        "Microsoft.Storage"
      ]
      delegation_name                   = "devops-pool-delegation"
      delegation_service_name           = "Microsoft.DevOpsInfrastructure/pools"
      private_endpoint_network_policies = ""
    }
  }

  # Use calculated subnets from Infoblox if available, otherwise fallback to YAML
  subnets_from_yaml = try(var.partner_config.network.subnets, [])

  # Check if calculated subnets were provided (now with flattened structure)
  has_calculated_subnets = var.calculated_subnets != null && try(length(var.calculated_subnets), 0) > 0

  # Use calculated subnets directly - they now have consistent flat structure
  # Fields: name, address_prefix, service_endpoints, delegation_name, delegation_service_name, private_endpoint_network_policies
  subnets_calculated = local.has_calculated_subnets ? var.calculated_subnets : []

  # Build a map of subnet name to address_prefix from calculated subnets
  # Use placeholder if address_prefix is null OR empty string
  # NOTE: coalesce() only handles null, not empty strings - use conditional
  placeholder_subnet_prefixes = {
    "compute-subnet"         = "10.255.0.0/24"
    "privateendpoint-subnet" = "10.255.1.0/24"
    "ado-agents-subnet"      = "10.255.2.0/24"
  }

  calculated_prefixes = {
    for subnet in local.subnets_calculated :
    subnet.name => (
      subnet.address_prefix != null && subnet.address_prefix != ""
      ? subnet.address_prefix
      : try(local.placeholder_subnet_prefixes[subnet.name], "10.255.0.0/24")
    )
  }

  # Final subnet list for outputs and other uses
  subnets = length(local.subnets_calculated) > 0 ? local.subnets_calculated : (
    length(local.subnets_from_yaml) > 0 ? local.subnets_from_yaml : [
      {
        name                              = "compute-subnet"
        address_prefix                    = "10.9.1.0/24"
        service_endpoints                 = []
        delegation_name                   = ""
        delegation_service_name           = ""
        private_endpoint_network_policies = ""
      }
    ]
  )

  # DNS servers from YAML configuration
  # Partners specify their DNS servers in the YAML manifest
  dns_servers = try(var.partner_config.network.dns_servers, [])

  # Private DNS zone configuration - NOT USED (DNS zones disabled per client request)
  # Keeping for backward compatibility with existing YAML configs
  private_dns_zone = try(var.partner_config.network.private_dns_zone, null)

  # Create ordered subnet list for sequential creation
  # This prevents Azure 409 "AnotherOperationInProgress" errors
  subnet_keys = [for subnet in local.subnets : subnet.name]
}

# Create VNet using azapi_resource to ensure subscription routing
resource "azapi_resource" "vnet" {
  type      = "Microsoft.Network/virtualNetworks@2024-01-01"
  name      = local.vnet_config.name
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  body = {
    properties = {
      addressSpace = {
        addressPrefixes = local.vnet_config.address_space
      }
      dhcpOptions = length(local.dns_servers) > 0 ? {
        dnsServers = local.dns_servers
      } : null
    }
  }

  tags = local.module_tags

  lifecycle {
    ignore_changes = [
      body
    ]
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

# Wait for VNet to be fully initialized before creating subnets
# This prevents Azure 409 "AnotherOperationInProgress" errors on subnet operations
resource "time_sleep" "vnet_ready" {
  depends_on      = [azapi_resource.vnet]
  create_duration = "5s"
}

# Create subnets sequentially - each depends on the previous one
# This prevents Azure 409 "AnotherOperationInProgress" errors from concurrent VNet operations
resource "azapi_resource" "subnet_0" {
  # No count - we always create compute-subnet

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = "compute-subnet"
  parent_id = azapi_resource.vnet.id

  body = {
    properties = {
      # Address prefix from calculated subnets (known at apply time) - this is OK!
      addressPrefix = try(local.calculated_prefixes["compute-subnet"], local.subnets[0].address_prefix)
      networkSecurityGroup = {
        id = azapi_resource.subnet_nsg["compute-subnet"].id
      }
      # Associate route table with compute-subnet for transit via Hub-Palo
      routeTable = {
        id = azapi_resource.transit_route_table.id
      }
      # Required by Azure Policy - all subnets must be private only
      privateEndpointNetworkPolicies = "Disabled"
      defaultOutboundAccess          = false
      serviceEndpoints = [for endpoint in local.static_subnet_configs["compute-subnet"].service_endpoints : {
        service = endpoint
      }]

      delegations = local.static_subnet_configs["compute-subnet"].delegation_name != "" ? [{
        name = local.static_subnet_configs["compute-subnet"].delegation_name
        properties = {
          serviceName = local.static_subnet_configs["compute-subnet"].delegation_service_name
        }
      }] : []
    }
  }

  # CRITICAL: Ignore changes to address prefix after initial creation
  lifecycle {
    ignore_changes = all
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  depends_on = [azapi_resource.subnet_nsg, time_sleep.vnet_ready, azapi_resource.transit_route_table]
}

resource "azapi_resource" "subnet_1" {
  # No count - we always create privateendpoint-subnet

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = "privateendpoint-subnet"
  parent_id = azapi_resource.vnet.id

  body = {
    properties = {
      # Address prefix from calculated subnets (known at apply time) - this is OK!
      addressPrefix = try(local.calculated_prefixes["privateendpoint-subnet"], local.subnets[1].address_prefix)
      networkSecurityGroup = {
        id = azapi_resource.subnet_nsg["privateendpoint-subnet"].id
      }
      # Route table for transit via Hub-Palo firewall
      routeTable = {
        id = azapi_resource.transit_route_table.id
      }
      # Required by Azure Policy - all subnets must be private only
      privateEndpointNetworkPolicies = "Disabled"
      defaultOutboundAccess          = false
      serviceEndpoints = [for endpoint in local.static_subnet_configs["privateendpoint-subnet"].service_endpoints : {
        service = endpoint
      }]

      # No delegations for private endpoint subnet
      delegations = []
    }
  }

  # CRITICAL: Ignore changes to address prefix after initial creation
  lifecycle {
    ignore_changes = all
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  # Sequential: subnet_1 depends on subnet_0 completion
  depends_on = [azapi_resource.subnet_nsg, azapi_resource.subnet_0, azapi_resource.transit_route_table]
}

resource "azapi_resource" "subnet_2" {
  # No count - we always create ado-agents-subnet

  type      = "Microsoft.Network/virtualNetworks/subnets@2024-01-01"
  name      = "ado-agents-subnet"
  parent_id = azapi_resource.vnet.id

  body = {
    properties = {
      # Address prefix from calculated subnets (known at apply time) - this is OK!
      addressPrefix = try(local.calculated_prefixes["ado-agents-subnet"], local.subnets[2].address_prefix)
      # NO NSG for ado-agents-subnet - Azure Managed DevOps Pools handle their own security
      # Route table for transit via Hub-Palo firewall (same as compute-subnet)
      routeTable = {
        id = azapi_resource.transit_route_table.id
      }
      # Required by Azure Policy - all subnets must be private only
      privateEndpointNetworkPolicies = "Disabled"
      defaultOutboundAccess          = false
      serviceEndpoints = [for endpoint in local.static_subnet_configs["ado-agents-subnet"].service_endpoints : {
        service = endpoint
      }]

      delegations = local.static_subnet_configs["ado-agents-subnet"].delegation_name != "" ? [{
        name = local.static_subnet_configs["ado-agents-subnet"].delegation_name
        properties = {
          serviceName = local.static_subnet_configs["ado-agents-subnet"].delegation_service_name
        }
      }] : []
    }
  }

  # CRITICAL: Ignore changes to address prefix after initial creation
  lifecycle {
    ignore_changes = all
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  # Sequential: subnet_2 depends on subnet_1 completion
  depends_on = [azapi_resource.subnet_nsg, azapi_resource.subnet_1, azapi_resource.transit_route_table]
}

# Create NSGs for subnets using azapi_resource
# Note: Only compute-subnet and privateendpoint-subnet get NSGs
# ado-agents-subnet does NOT get an NSG - Azure Managed DevOps Pools manage their own security
resource "azapi_resource" "subnet_nsg" {
  for_each = {
    for k, v in local.static_subnet_configs : k => v
    if k != "ado-agents-subnet"
  }

  type      = "Microsoft.Network/networkSecurityGroups@2024-01-01"
  name      = "nsg-${each.key}"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  body = {
    properties = {
      securityRules = []
    }
  }

  tags = local.module_tags

  lifecycle {
    ignore_changes = [body]
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}

# ============================================================================
# ROUTE TABLE (UDR) FOR TRANSIT VIA HUB-PALO FIREWALL
# ============================================================================
# All traffic from compute-subnet routes through the Hub Palo Alto firewall
# for centralized inspection and security enforcement.
#
# Default route 0.0.0.0/0 -> Hub-Palo firewall (Virtual Appliance)
# Next hop IP: 10.94.252.100 (Hub-Palo firewall internal IP)

resource "azapi_resource" "transit_route_table" {
  type      = "Microsoft.Network/routeTables@2024-01-01"
  name      = "rt-${var.partner_name}-transit"
  location  = var.location
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  body = {
    properties = {
      disableBgpRoutePropagation = true
      routes = [
        {
          name = "default-to-hub-palo"
          properties = {
            addressPrefix    = "0.0.0.0/0"
            nextHopType      = "VirtualAppliance"
            nextHopIpAddress = var.hub_firewall_ip
          }
        }
      ]
    }
  }

  tags = local.module_tags

  lifecycle {
    ignore_changes = [body]
  }

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }
}
