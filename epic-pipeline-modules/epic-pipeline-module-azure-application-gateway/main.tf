resource "azurerm_application_gateway" "this" {
  name                = var.gateway_name
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.autoscale == null ? var.capacity : null
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale != null ? [var.autoscale] : []
    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = var.public_ip_id
  }

  dynamic "frontend_port" {
    for_each = { for p in var.frontend_ports : p.name => p }
    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = { for p in var.backend_address_pools : p.name => p }
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "probe" {
    for_each = { for p in var.probes : p.name => p }
    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
    }
  }

  dynamic "backend_http_settings" {
    for_each = { for s in var.backend_http_settings : s.name => s }
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
      probe_name                          = backend_http_settings.value.probe_name
    }
  }

  dynamic "http_listener" {
    for_each = { for l in var.http_listeners : l.name => l }
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = "frontend-ip-config"
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
    }
  }

  dynamic "ssl_certificate" {
    for_each = { for c in var.ssl_certificates : c.name => c }
    content {
      name                = ssl_certificate.value.name
      key_vault_secret_id = ssl_certificate.value.key_vault_secret_id
    }
  }

  dynamic "url_path_map" {
    for_each = { for m in var.url_path_maps : m.name => m }
    content {
      name                               = url_path_map.value.name
      default_backend_address_pool_name  = url_path_map.value.default_backend_address_pool_name
      default_backend_http_settings_name = url_path_map.value.default_backend_http_settings_name
      default_rewrite_rule_set_name      = url_path_map.value.default_rewrite_rule_set_name

      dynamic "path_rule" {
        for_each = { for r in url_path_map.value.path_rules : r.name => r }
        content {
          name                       = path_rule.value.name
          paths                      = path_rule.value.paths
          backend_address_pool_name  = path_rule.value.backend_address_pool_name
          backend_http_settings_name = path_rule.value.backend_http_settings_name
          rewrite_rule_set_name      = path_rule.value.rewrite_rule_set_name
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = { for r in var.request_routing_rules : r.name => r }
    content {
      name                       = request_routing_rule.value.name
      rule_type                  = request_routing_rule.value.rule_type
      http_listener_name         = request_routing_rule.value.http_listener_name
      priority                   = request_routing_rule.value.priority
      backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
      backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      url_path_map_name          = request_routing_rule.value.url_path_map_name
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = { for s in var.rewrite_rule_sets : s.name => s }
    content {
      name = rewrite_rule_set.value.name

      dynamic "rewrite_rule" {
        for_each = { for r in rewrite_rule_set.value.rewrite_rules : r.name => r }
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "url" {
            for_each = rewrite_rule.value.url != null ? [rewrite_rule.value.url] : []
            content {
              path       = url.value.path
              components = url.value.components
              reroute    = url.value.reroute
            }
          }

          dynamic "response_header_configuration" {
            for_each = { for h in rewrite_rule.value.response_headers : h.header_name => h }
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }
        }
      }
    }
  }

  ssl_policy {
    policy_type          = var.ssl_policy.policy_type
    policy_name          = var.ssl_policy.policy_name
    min_protocol_version = var.ssl_policy.min_protocol_version
  }

  tags = var.tags
}
