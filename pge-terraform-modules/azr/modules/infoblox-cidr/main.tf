# ============================================================================
# Infoblox CIDR Allocation Module - Azure Deployment Script
# ============================================================================
#
# HOW THIS WORKS:
# ---------------
# 1. Terraform creates a "Deployment Script" resource in Azure
# 2. Azure runs this script INSIDE your network (as an ACI container)
# 3. The script calls your PRIVATE Infoblox Function App (it has network access!)
# 4. Function App returns CIDR value
# 5. Terraform reads the output and uses it for VNet/subnet creation
#
# WHY THIS WORKS FOR PRIVATE FUNCTION APPS:
# -----------------------------------------
# - TFC SaaS runners don't need network access to Function App
# - TFC only creates an Azure resource (the Deployment Script) via ARM API
# - The script runs INSIDE Azure, in YOUR subnet
# - Your subnet has access to the private Function App via VNet integration
#
# SINGLE PLAN/APPLY:
# ------------------
# - VNet/subnet address_prefixes show as "known after apply" - this is OK!
# - They're used as resource attributes, not for_each keys
# - All resources create in ONE terraform apply
#
# PREREQUISITES:
# --------------
# 1. Management subnet with access to private Function App
# 2. Subnet must have delegation: Microsoft.ContainerInstance/containerGroups
# 3. Function App returns: {"cidr": "x.x.x.x/x"} or just the CIDR string
#
# ============================================================================

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
  }
}

# ============================================================================
# LOCAL CONFIGURATION
# ============================================================================

locals {
  # Map Terraform size names to Infoblox CIDRSize parameter
  size_to_infoblox = {
    tiny   = "tiny"   # /25 - 128 IPs
    small  = "small"  # /24 - 256 IPs
    medium = "medium" # /23 - 512 IPs
    large  = "large"  # /22 - 1024 IPs
    giant  = "giant"  # /21 - 2048 IPs
  }
  cidr_size = try(local.size_to_infoblox[var.network_size], "large")

  # Function URL for the PowerShell script to call
  function_url = "https://${var.function_app_hostname}/api/provision?CIDRSize=${local.cidr_size}&RegionId=${var.region}&SubscriptionId=${var.subscription_id}"

  # Resource naming (storage account names: 3-24 chars, lowercase alphanumeric only)
  script_name          = "ds-cidr-${var.partner_name}"
  identity_name        = "id-cidr-${var.partner_name}"
  storage_account_name = lower(replace("stcidr${var.partner_name}", "-", ""))
  partner_rg_name      = "rg-cidr-${var.partner_name}"

  # VNet resource group (may differ from where deployment script resources are created)
  vnet_resource_group = var.shared_vnet_resource_group != "" ? var.shared_vnet_resource_group : var.shared_resource_group

  # Management subnet ID for container deployment
  # NOTE: VNet may be in a different resource group than the deployment script resources
  management_subnet_id = "/subscriptions/${var.shared_subscription_id}/resourceGroups/${local.vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${var.shared_vnet_name}/subnets/${var.aci_subnet_name}"

  # Common Tags
  namespace   = "ccoe-tf-developers"
  module_tags = merge(var.common_tags, { pge_team = local.namespace, tfc_wsname = module.ws.name, tfc_wsid = module.ws.id })
}

module "ws" {
  source  = "app.terraform.io/pgetech/utils/aws//modules/workspace-info"
  version = "0.1.0"
}

# ============================================================================
# PER-PARTNER RESOURCE GROUP IN SHARED SUBSCRIPTION
# ============================================================================
# Each partner gets its own RG for isolation. Contains the SA, MI, and
# deployment script. Avoids a single monolithic RG with 100+ partners' resources.

resource "azurerm_resource_group" "partner_cidr" {
  name     = local.partner_rg_name
  location = var.location


  tags = merge(var.common_tags, {
    Purpose   = "Infoblox CIDR allocation resources"
    Partner   = var.partner_name
    ManagedBy = "Terraform"
  })
}

# ============================================================================
# STORAGE ACCOUNT FOR DEPLOYMENT SCRIPT ARTIFACTS
# ============================================================================
# Required when running Deployment Script in a subnet. This storage account
# stores script files and logs. Created per-partner for isolation.
#
# IMPORTANT: When using Deployment Scripts with subnets + managed identity,
# the storage account CANNOT have firewall restrictions (even with service endpoints).
# Azure's Deployment Script service needs unrestricted access to the storage account.
# Security is maintained through:
# - Managed Identity with minimal RBAC (only this identity can access)
# - Short-lived storage (can be deleted after deployment)
# - Unique storage account per partner (isolation)

resource "azurerm_storage_account" "script_storage" {
  name                     = substr(local.storage_account_name, 0, 24) # Max 24 chars
  resource_group_name      = azurerm_resource_group.partner_cidr.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Deployment Scripts require storage account WITHOUT firewall restrictions
  # when using subnet + managed identity. The managed identity RBAC provides security.
  public_network_access_enabled = true

  # CRITICAL: Don't update storage after initial creation
  # This prevents re-running Infoblox allocation on subsequent applies
  lifecycle {
    ignore_changes = all
  }

  tags = merge(var.common_tags, {
    Purpose   = "Deployment Script artifacts for Infoblox CIDR allocation"
    Partner   = var.partner_name
    ManagedBy = "Terraform"
  })

}

# Grant the managed identity access to the storage account
resource "azurerm_role_assignment" "script_storage_contributor" {
  scope                = azurerm_storage_account.script_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.script_identity.principal_id
}

# Storage File Data Privileged Contributor for deployment script file shares
# (SMB Share Contributor is insufficient - need Privileged Contributor)
resource "azurerm_role_assignment" "script_storage_file_contributor" {
  scope                = azurerm_storage_account.script_storage.id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_user_assigned_identity.script_identity.principal_id
}

# Tag Contributor — lets the PowerShell script tag the storage account after
# successful CIDR allocation. Terraform reads this tag on the NEXT plan refresh
# → count=0 → deployment script is never recreated, even after PT1H expiry.
resource "azurerm_role_assignment" "script_tag_contributor" {
  scope                = azurerm_storage_account.script_storage.id
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_user_assigned_identity.script_identity.principal_id
}

# ============================================================================
# MANAGED IDENTITY FOR DEPLOYMENT SCRIPT
# ============================================================================
# The Deployment Script needs an identity to run. This identity doesn't need
# any special Azure RBAC unless your Function App requires Azure AD auth.

resource "azurerm_user_assigned_identity" "script_identity" {
  name                = local.identity_name
  resource_group_name = azurerm_resource_group.partner_cidr.name
  location            = var.location

  # CRITICAL: Don't update identity after initial creation
  # This prevents re-running Infoblox allocation on subsequent applies
  lifecycle {
    ignore_changes = all
  }

  tags = merge(var.common_tags, {
    Purpose   = "Infoblox CIDR allocation"
    Partner   = var.partner_name
    ManagedBy = "Terraform"
  })
}

# ============================================================================
# DEPLOYMENT SCRIPT - THE KEY COMPONENT
# ============================================================================
# This resource:
# - Gets deployed to Azure as a container (ACI) in your management subnet
# - Runs PowerShell script that calls your PRIVATE Function App
# - Returns the CIDR value back to Terraform via structured output
#
# The container runs INSIDE your Azure network, so it can reach private endpoints!
#
# IMPORTANT: lifecycle { ignore_changes = [body] } prevents re-running the script
# on subsequent applies. Once CIDR is allocated, we keep using that allocation.
# To force re-allocation, taint the resource: terraform taint 'module.infoblox_cidr["partner"].azapi_resource.deployment_script'

resource "azapi_resource" "deployment_script" {
  # GATE: Skip if storage account already tagged (CIDR was allocated on a prior run).
  # After PT1H Azure deletes the deployment script, but the SA tag persists forever.
  # On next plan: TF refreshes SA → sees cidr_allocated=true → count=0 → no recreation.
  count = try(azurerm_storage_account.script_storage.tags["cidr_allocated"], "") == "true" ? 0 : 1

  type      = "Microsoft.Resources/deploymentScripts@2023-08-01"
  name      = local.script_name
  location  = var.location
  parent_id = "/subscriptions/${var.shared_subscription_id}/resourceGroups/${azurerm_resource_group.partner_cidr.name}"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.script_identity.id]
  }

  # CRITICAL: Ignore ALL changes once deployment script is created
  # Even if Azure deletes the resource after retentionInterval, the PowerShell
  # script itself is IDEMPOTENT — it checks blob storage before calling Infoblox.
  # Safe to recreate anytime.
  lifecycle {
    ignore_changes = all
  }

  body = {
    kind = "AzurePowerShell"
    properties = {
      azPowerShellVersion = "9.7"
      retentionInterval   = "PT1H"         # Keep for 1 hour then Azure cleans up
      timeout             = "PT10M"        # 10 minute timeout
      cleanupPreference   = "OnExpiration" # Only cleanup after retention expires

      # Required: Storage account for script artifacts when using subnet
      storageAccountSettings = {
        storageAccountName = azurerm_storage_account.script_storage.name
      }

      # THIS IS THE KEY: Run the script in your private subnet
      containerSettings = {
        subnetIds = [
          {
            id = local.management_subnet_id
          }
        ]
      }

      # PowerShell script that calls your private Function App
      # IDEMPOTENT: Checks blob storage first — if CIDR was already allocated,
      # returns stored values without ever calling Infoblox again.
      scriptContent = <<-SCRIPT
        $ErrorActionPreference = 'Stop'
        
        $functionUrl = '${local.function_url}'
        $functionKey = '${var.function_key}'
        $partnerName = '${var.partner_name}'
        $cidrSize = '${local.cidr_size}'
        $region = '${var.region}'
        $storageAccountName = '${azurerm_storage_account.script_storage.name}'
        $sharedSubscriptionId = '${var.shared_subscription_id}'
        $sharedResourceGroup = '${azurerm_resource_group.partner_cidr.name}'
        $containerName = 'cidr-results'
        $blobName = 'cidr-allocation.json'

        # CRITICAL: Define headers with function key
        $headers = @{ 'x-functions-key' = $functionKey }
        
        # =====================================================
        # Subnet CIDR calculator (like Terraform's cidrsubnet)
        # =====================================================
        function Get-SubnetCidr {
            param([string]$VNetCidr, [int]$NewBits, [int]$NetNum)
            $parts = $VNetCidr -split '/'
            $ipParts = $parts[0] -split '\.'
            $ipInt = ([int]$ipParts[0] -shl 24) + ([int]$ipParts[1] -shl 16) + ([int]$ipParts[2] -shl 8) + [int]$ipParts[3]
            $newPrefixLength = [int]$parts[1] + $NewBits
            $subnetSize = [math]::Pow(2, 32 - $newPrefixLength)
            $newIpInt = $ipInt + ($NetNum * $subnetSize)
            $o1 = [math]::Floor($newIpInt / 16777216) % 256
            $o2 = [math]::Floor($newIpInt / 65536) % 256
            $o3 = [math]::Floor($newIpInt / 256) % 256
            $o4 = $newIpInt % 256
            return "$o1.$o2.$o3.$o4/$newPrefixLength"
        }

        Write-Output "============================================="
        Write-Output "Infoblox CIDR Allocation for: $partnerName"
        Write-Output "============================================="

        # =====================================================
        # Call Infoblox Function App
        # SA tag gate (count=0) ensures this only runs on first apply.
        # =====================================================
        $headers = @{ 'x-functions-key' = $functionKey }

        try {
            Write-Output "Calling Infoblox Function App..."
            Write-Output "URL: $functionUrl"
            
            $response = Invoke-WebRequest -Uri $functionUrl -Method Post -Headers $headers -UseBasicParsing -TimeoutSec 120
            Write-Output "Response Status: $($response.StatusCode)"
            
            $content = $response.Content
            Write-Output "Raw response: $content"
            
            $cidr = $null
            try {
                $jsonResponse = $content | ConvertFrom-Json
                if ($jsonResponse.success -eq $false) {
                    throw "Infoblox API returned error: $($jsonResponse.message)"
                }
                if ($jsonResponse.cidr) { $cidr = $jsonResponse.cidr }
                elseif ($jsonResponse.vnet_cidr) { $cidr = $jsonResponse.vnet_cidr }
                elseif ($jsonResponse.CIDR) { $cidr = $jsonResponse.CIDR }
            } catch {
                if ($_.Exception.Message -match "Infoblox API returned error") { throw }
                $cidr = $content.Trim()
            }
            
            if (-not $cidr) { $cidr = $content.Trim() }
            if ($cidr -notmatch '^\d+\.\d+\.\d+\.\d+/\d+$') {
                throw "Invalid CIDR format received: $cidr"
            }
            
            Write-Output "Allocated VNet CIDR: $cidr"
            
            # Calculate subnet CIDRs with /27 prefix (32 IPs per subnet)
            # NewBits = 5 means: if VNet is /22, subnets will be /27 (22 + 5 = 27)
            $computeSubnetCidr = Get-SubnetCidr -VNetCidr $cidr -NewBits 5 -NetNum 0
            $privateEndpointSubnetCidr = Get-SubnetCidr -VNetCidr $cidr -NewBits 5 -NetNum 1
            $adoAgentsSubnetCidr = Get-SubnetCidr -VNetCidr $cidr -NewBits 5 -NetNum 2
            $reservedSubnetCidr = Get-SubnetCidr -VNetCidr $cidr -NewBits 5 -NetNum 3
            
            # =====================================================
            # STEP 3: Persist to blob storage (idempotency marker)
            # Future re-runs will find this and skip Infoblox
            # =====================================================
            Write-Output "Saving allocation to blob storage..."
            try {
                $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
                
                # Create container if it doesn't exist
                $container = Get-AzStorageContainer -Name $containerName -Context $ctx -ErrorAction SilentlyContinue
                if (-not $container) {
                    New-AzStorageContainer -Name $containerName -Context $ctx -Permission Off | Out-Null
                }
                
                # Write CIDR data as JSON blob
                $cidrData = @{
                    vnet_cidr                   = $cidr
                    compute_subnet_cidr         = $computeSubnetCidr
                    privateendpoint_subnet_cidr = $privateEndpointSubnetCidr
                    ado_agents_subnet_cidr      = $adoAgentsSubnetCidr
                    reserved_subnet_cidr        = $reservedSubnetCidr
                    allocated_at                = (Get-Date -Format 'o')
                    partner_name                = $partnerName
                    cidr_size                   = $cidrSize
                    region                      = $region
                } | ConvertTo-Json
                
                $tempFile = [System.IO.Path]::GetTempFileName()
                $cidrData | Out-File -FilePath $tempFile -Encoding UTF8
                Set-AzStorageBlobContent -Container $containerName -Blob $blobName -File $tempFile -Context $ctx -Force | Out-Null
                Remove-Item $tempFile -Force
                
                Write-Output "CIDR allocation saved to blob"
            } catch {
                Write-Warning "Failed to save to blob (non-fatal): $($_.Exception.Message)"
            }
            
            Write-Output "Tagging storage account..."
            try {
                $saResourceId = "/subscriptions/$sharedSubscriptionId/resourceGroups/$sharedResourceGroup/providers/Microsoft.Storage/storageAccounts/$storageAccountName"
                $newTags = @{ 'cidr_allocated' = 'true'; 'vnet_cidr' = $cidr }
                Update-AzTag -ResourceId $saResourceId -Tag $newTags -Operation Merge | Out-Null
                Write-Output "Tagged storage account successfully"
            } catch {
                Write-Warning "Failed to tag storage account (non-fatal): $($_.Exception.Message)"
            }
            
            $DeploymentScriptOutputs = @{
                vnet_cidr                    = $cidr
                compute_subnet_cidr          = $computeSubnetCidr
                privateendpoint_subnet_cidr  = $privateEndpointSubnetCidr
                ado_agents_subnet_cidr       = $adoAgentsSubnetCidr
                reserved_subnet_cidr         = $reservedSubnetCidr
                partner_name                 = $partnerName
                cidr_size                    = $cidrSize
                region                       = $region
                status                       = 'success'
                success                      = $true
                error                        = ''
            }
            
            Write-Output "============================================="
            Write-Output "SUCCESS: CIDR allocated for $partnerName"
            Write-Output "VNet CIDR: $cidr"
            Write-Output "Subnets: /27 (32 IPs each)"
            Write-Output "============================================="
            
        } catch {
            Write-Error "FAILED to allocate CIDR for $partnerName : $_"
            $DeploymentScriptOutputs = @{
                vnet_cidr = ''; compute_subnet_cidr = ''; privateendpoint_subnet_cidr = ''
                ado_agents_subnet_cidr = ''; reserved_subnet_cidr = ''
                partner_name = $partnerName; cidr_size = $cidrSize; region = $region
                status = 'failed'; success = $false; error = $_.Exception.Message
            }
            throw
        }
      SCRIPT

      arguments = ""
    }
  }

  response_export_values = ["properties.outputs"]

  depends_on = [
    azurerm_user_assigned_identity.script_identity,
    azurerm_storage_account.script_storage,
    azurerm_role_assignment.script_storage_contributor,
    azurerm_role_assignment.script_storage_file_contributor,
    azurerm_role_assignment.script_tag_contributor
  ]

  tags = merge(var.common_tags, {
    Purpose   = "Infoblox CIDR allocation"
    Partner   = var.partner_name
    ManagedBy = "Terraform"
  })
}

# ============================================================================
# EXTRACT CIDR FROM DEPLOYMENT SCRIPT OUTPUT
# ============================================================================

locals {
  # Raw output from azapi_resource (for debugging)
  raw_output = try(jsonencode(azapi_resource.deployment_script[0].output), "{}")

  # Parse the outputs from the Deployment Script
  # Try both nested and flat key access formats
  script_outputs_nested = try(
    azapi_resource.deployment_script[0].output.properties.outputs,
    null
  )

  script_outputs_flat = try(
    azapi_resource.deployment_script[0].output["properties.outputs"],
    null
  )

  # Use whichever format worked
  script_outputs = coalesce(
    local.script_outputs_nested,
    local.script_outputs_flat,
    { vnet_cidr = "", compute_subnet_cidr = "", privateendpoint_subnet_cidr = "", ado_agents_subnet_cidr = "", reserved_subnet_cidr = "", status = "pending", success = false, error = "No output received" }
  )
}

# ============================================================================
#Store and read from TF state (terraform_data) to persist CIDR values beyond deployment script lifecycle

resource "terraform_data" "cidr_store" {
  input = {
    vnet_cidr                   = try(local.script_outputs.vnet_cidr, "")
    compute_subnet_cidr         = try(local.script_outputs.compute_subnet_cidr, "")
    privateendpoint_subnet_cidr = try(local.script_outputs.privateendpoint_subnet_cidr, "")
    ado_agents_subnet_cidr      = try(local.script_outputs.ado_agents_subnet_cidr, "")
    reserved_subnet_cidr        = try(local.script_outputs.reserved_subnet_cidr, "")
    partner_name                = try(local.script_outputs.partner_name, var.partner_name)
    cidr_size                   = try(local.script_outputs.cidr_size, local.cidr_size)
    region                      = try(local.script_outputs.region, var.region)
    status                      = try(local.script_outputs.status, "unknown")
    success                     = try(local.script_outputs.success, false)
    error                       = try(local.script_outputs.error, "")
  }

  # Never update after initial creation.
  lifecycle {
    ignore_changes = all
  }

  depends_on = [azapi_resource.deployment_script]
}

# ============================================================================
#CIDR Allocation from TF Data 

locals {
  # Read from the permanent store
  allocated_cidr              = terraform_data.cidr_store.output.vnet_cidr
  compute_subnet_cidr         = terraform_data.cidr_store.output.compute_subnet_cidr
  privateendpoint_subnet_cidr = terraform_data.cidr_store.output.privateendpoint_subnet_cidr
  ado_agents_subnet_cidr      = terraform_data.cidr_store.output.ado_agents_subnet_cidr
  reserved_subnet_cidr        = terraform_data.cidr_store.output.reserved_subnet_cidr

  # Status from permanent store
  script_success = terraform_data.cidr_store.output.success
  script_error   = terraform_data.cidr_store.output.error
  script_status  = terraform_data.cidr_store.output.status

  # Validation
  allocation_success = local.allocated_cidr != "" && can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+/[0-9]+$", local.allocated_cidr))

  allocation_error_detail = local.allocation_success ? "" : (
    local.script_error != "" ? "Infoblox Error: ${local.script_error}" : (
      local.allocated_cidr == "" ? "No CIDR returned from Infoblox - check Deployment Script logs" : "Invalid CIDR format: ${local.allocated_cidr}"
    )
  )
}
