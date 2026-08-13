variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "gateway_name" {
  type        = string
  description = "Name of the Application Gateway"
}

variable "tags" {
  type        = map(string)
  description = "Resource tags"
}

variable "subnet_id" {
  type        = string
  description = "Resource ID of the dedicated Application Gateway subnet"
}

variable "public_ip_id" {
  type        = string
  description = "Resource ID of the Standard/Static public IP fronting the gateway"
}

##############################################################################
# SKU / scaling
##############################################################################

variable "sku_name" {
  type        = string
  description = "Application Gateway SKU name"
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_name)
    error_message = "sku_name must be one of: Standard_v2, WAF_v2 (v1 SKUs are retired)."
  }
}

variable "sku_tier" {
  type        = string
  description = "Application Gateway SKU tier"
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard_v2", "WAF_v2"], var.sku_tier)
    error_message = "sku_tier must be one of: Standard_v2, WAF_v2."
  }
}

variable "capacity" {
  type        = number
  description = "Fixed instance count (used when autoscale is null)"
  default     = 1
}

variable "autoscale" {
  type = object({
    min_capacity = number
    max_capacity = number
  })
  description = "Autoscale bounds. When set, overrides the fixed capacity."
  default     = null
}

##############################################################################
# Routing building blocks
##############################################################################

variable "frontend_ports" {
  type = list(object({
    name = string
    port = number
  }))
  description = "Frontend ports exposed by the gateway"
  default     = []
}

variable "backend_address_pools" {
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
  description = "Backend address pools (FQDNs and/or IPs)"
  default     = []
}

variable "probes" {
  type = list(object({
    name                                      = string
    protocol                                  = string
    path                                      = string
    interval                                  = optional(number, 30)
    timeout                                   = optional(number, 30)
    unhealthy_threshold                       = optional(number, 3)
    pick_host_name_from_backend_http_settings = optional(bool, true)
  }))
  description = "Health probes"
  default     = []
}

variable "backend_http_settings" {
  type = list(object({
    name                                = string
    cookie_based_affinity               = optional(string, "Disabled")
    port                                = number
    protocol                            = string
    request_timeout                     = optional(number, 30)
    pick_host_name_from_backend_address = optional(bool, true)
    probe_name                          = optional(string)
  }))
  description = "Backend HTTP settings"
  default     = []
}

variable "http_listeners" {
  type = list(object({
    name                 = string
    frontend_port_name   = string
    protocol             = string
    ssl_certificate_name = optional(string)
  }))
  description = "HTTP/HTTPS listeners"
  default     = []
}

variable "ssl_certificates" {
  type = list(object({
    name                = string
    key_vault_secret_id = string
  }))
  description = "TLS certificates sourced from Key Vault (for HTTPS listeners)"
  default     = []
}

variable "url_path_maps" {
  type = list(object({
    name                               = string
    default_backend_address_pool_name  = string
    default_backend_http_settings_name = string
    default_rewrite_rule_set_name      = optional(string)
    path_rules = list(object({
      name                       = string
      paths                      = list(string)
      backend_address_pool_name  = string
      backend_http_settings_name = string
      rewrite_rule_set_name      = optional(string)
    }))
  }))
  description = "URL path maps for path-based routing"
  default     = []
}

variable "request_routing_rules" {
  type = list(object({
    name                       = string
    rule_type                  = string
    http_listener_name         = string
    priority                   = number
    backend_address_pool_name  = optional(string)
    backend_http_settings_name = optional(string)
    url_path_map_name          = optional(string)
  }))
  description = "Request routing rules. Use rule_type PathBasedRouting with url_path_map_name, or Basic with a pool + settings."
  default     = []
}

variable "rewrite_rule_sets" {
  type = list(object({
    name = string
    rewrite_rules = list(object({
      name          = string
      rule_sequence = number
      # Match conditions. REQUIRED when a `url.path` references a capture server
      # variable like `{var_uri_path_1}` — that variable only exists if a
      # condition with a capturing `pattern` defines it. Omitting the condition
      # is the classic cause of a gateway CREATE failing on an undefined
      # capture variable.
      conditions = optional(list(object({
        variable    = string
        pattern     = string
        ignore_case = optional(bool, true)
        negate      = optional(bool, false)
      })), [])
      url = optional(object({
        path       = optional(string)
        components = optional(string)
        reroute    = optional(bool, false)
      }))
      response_headers = optional(list(object({
        header_name  = string
        header_value = string
      })), [])
    }))
  }))
  description = "Rewrite rule sets (e.g. strip an /api prefix, add CORS response headers)"
  default     = []
}

variable "ssl_policy" {
  type = object({
    policy_type          = optional(string, "Predefined")
    policy_name          = optional(string, "AppGwSslPolicy20220101")
    min_protocol_version = optional(string, "TLSv1_2")
  })
  description = "TLS policy for the gateway. Defaults enforce a minimum of TLS 1.2 (SECURITY-03 control intent)."
  default     = {}
}
