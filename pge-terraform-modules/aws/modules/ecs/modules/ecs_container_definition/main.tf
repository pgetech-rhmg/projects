/*
* # AWS ECS module
* Terraform module which creates SAF2.0 ECS in AWS.
*/
#
#  Filename    : aws/modules/ecs/modules/ecs_container_definition/main.tf
#  Date        : 21 July 2022
#  Author      : TCS
#  Description : ECS container definitions resource creation
#

# Module      : ecs module
# Description : This terraform module creates a ecs.


terraform {
  required_version = ">= 1.3.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {

  # Sort secrets so terraform will not try to recreate on each plan/apply
  secrets_keys        = var.map_secrets != null ? keys(var.map_secrets) : var.secrets != null ? [for m in var.secrets : lookup(m, "name")] : []
  secrets_values      = var.map_secrets != null ? values(var.map_secrets) : var.secrets != null ? [for m in var.secrets : lookup(m, "valueFrom")] : []
  secrets_as_map      = zipmap(local.secrets_keys, local.secrets_values)
  sorted_secrets_keys = sort(local.secrets_keys)

  sorted_secrets_vars = [
    for key in local.sorted_secrets_keys :
    {
      name      = key
      valueFrom = lookup(local.secrets_as_map, key)
    }
  ]
  final_secrets_vars = length(local.sorted_secrets_vars) > 0 ? local.sorted_secrets_vars : null


  container_definition = {
    name                   = var.container_name
    image                  = var.container_image
    repositoryCredentials  = var.repository_Credentials
    portMappings           = var.port_mappings
    memory                 = var.container_memory
    cpu                    = var.container_cpu
    essential              = var.essential
    entryPoint             = var.entrypoint
    command                = var.command
    workingDirectory       = var.working_directory
    readonlyRootFilesystem = var.readonly_root_filesystem
    mountPoints            = var.mount_points
    dnsServers             = var.dns_servers
    dnsSearchDomains       = var.dns_search_domains
    ulimits                = var.ulimits
    links                  = var.links
    volumesFrom            = var.volumes_from
    dependsOn              = var.container_depends_on
    privileged             = var.privileged
    portMappings           = var.port_mappings
    healthCheck            = var.healthcheck
    firelensConfiguration  = var.firelens_configuration
    healthCheck            = var.healthcheck
    linuxParameters        = var.linux_parameters
    memoryReservation      = var.container_memory_reservation
    environment            = var.environment
    environmentFiles       = var.environment_files
    dockerLabels           = var.docker_labels
    startTimeout           = var.start_timeout
    stopTimeout            = var.stop_timeout
    systemControls         = var.system_controls
    extraHosts             = var.extra_hosts
    hostname               = var.hostname
    disableNetworking      = var.disable_networking
    interactive            = var.interactive
    pseudoTerminal         = var.pseudo_terminal
    dockerSecurityOptions  = var.docker_security_options
    resourceRequirements   = var.resource_requirements
    logConfiguration       = var.log_configuration
    secrets                = local.final_secrets_vars
    user                   = var.firelens_configuration != null ? "0" : var.user
  }
  container_definitions_without_null = {
    for k, v in local.container_definition :
    k => v
    if v != null
  }
  json_map = jsonencode(merge(local.container_definitions_without_null, var.container_definition))
}


locals {
  # wiz container definition
  wiz_container_definition = var.create_wiz_container ? {
    name                     = var.wiz_container_name
    image                    = var.wiz_container_image
    repositoryCredentials    = var.wiz_repository_Credentials
    container_memory         = var.wiz_container_memory
    container_cpu            = var.wiz_container_cpu
    privileged               = var.wiz_privileged
    volumesFrom              = var.wiz_volumes_from
    linuxParameters          = var.wiz_linux_parameters
    firelensConfiguration    = var.wiz_firelens_configuration
    mountPoints              = var.wiz_mount_points
    readonlyRootFilesystem   = var.wiz_readonly_root_filesystem
    user                     = var.firelens_configuration != null ? "0" : var.wiz_user
    command                  = var.command
    memoryReservation        = var.wiz_container_memory_reservation
    essential                = var.wiz_essential
    readonly_root_filesystem = var.readonly_root_filesystem
    environment              = var.wiz_environment
    log_configuration        = var.wiz_log_configuration
    port_mappings            = var.wiz_port_mappings
    } : {
    name                     = null
    image                    = null
    repositoryCredentials    = null
    container_memory         = null
    container_cpu            = null
    privileged               = null
    volumesFrom              = null
    linuxParameters          = null
    firelensConfiguration    = null
    mountPoints              = null
    readonlyRootFilesystem   = null
    user                     = null
    command                  = null
    memoryReservation        = null
    essential                = null
    readonly_root_filesystem = null
    environment              = null
    log_configuration        = null
    port_mappings            = null
  }

  wiz_container_definitions_without_null = {
    for k, v in local.wiz_container_definition :
    k => v
    if v != null
  }

  wiz_json_map = jsonencode(merge(local.wiz_container_definitions_without_null, var.container_definition))
}




