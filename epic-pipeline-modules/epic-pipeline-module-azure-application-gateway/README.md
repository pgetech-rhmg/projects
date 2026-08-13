# EPIC Azure Application Gateway Module

## Overview

`epic-pipeline-module-azure-application-gateway` provisions an Azure Application Gateway (v2) as a reusable building block for EPIC-managed Azure infrastructure.

It fronts one or more backends — for example routing `/` to a static-website storage account and `/api/*` to a Container App — with health probes, path-based routing, TLS, and rewrite rules. The gateway's structural pieces (pools, listeners, settings, probes, path maps, routing rules, rewrite sets) are exposed as typed variables driven by dynamic blocks, so the module stays reusable without hardcoding any one app's topology.

---

## Resources Created

- `azurerm_application_gateway`

The subnet and public IP are **inputs** — provision them with the `azure-network` module and pass their IDs in.

---

## Inputs

### Required

| Name | Type | Description |
|------|------|-------------|
| `resource_group_name` | `string` | Resource group name. |
| `azure_region` | `string` | Azure region. |
| `gateway_name` | `string` | Name of the Application Gateway. |
| `tags` | `map(string)` | Resource tags. |
| `subnet_id` | `string` | Dedicated Application Gateway subnet ID. |
| `public_ip_id` | `string` | Standard/Static public IP ID. |

### Optional (structural — see `variables.tf` for full object shapes)

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `sku_name` / `sku_tier` | `string` | `Standard_v2` | `Standard_v2` or `WAF_v2`. |
| `capacity` | `number` | `1` | Fixed instance count (ignored when `autoscale` set). |
| `autoscale` | `object` | `null` | `{ min_capacity, max_capacity }`. |
| `frontend_ports` | `list(object)` | `[]` | Named frontend ports. |
| `backend_address_pools` | `list(object)` | `[]` | Pools by FQDN and/or IP. |
| `probes` | `list(object)` | `[]` | Health probes. |
| `backend_http_settings` | `list(object)` | `[]` | Backend HTTP settings. |
| `http_listeners` | `list(object)` | `[]` | Listeners (HTTP/HTTPS). |
| `ssl_certificates` | `list(object)` | `[]` | Key Vault-sourced TLS certs. |
| `url_path_maps` | `list(object)` | `[]` | Path-based routing maps. |
| `request_routing_rules` | `list(object)` | `[]` | Routing rules (Basic or PathBasedRouting). |
| `rewrite_rule_sets` | `list(object)` | `[]` | Rewrite sets (prefix strip, CORS headers). Each rule takes optional `conditions` — required when the `url.path` uses a capture variable like `{var_uri_path_1}`. |
| `ssl_policy` | `object` | TLS 1.2 min | Gateway TLS policy. |

---

## Outputs

| Name | Description |
|------|-------------|
| `gateway_id` | Resource ID of the gateway. |
| `gateway_name` | Name of the gateway. |
| `backend_address_pool_ids` | Map of pool name => ID. |

---

## Usage in a Terraform Project

Path-based routing — `/` to a static site, `/api/*` to a container app with an `/api` prefix strip:

```hcl
module "app_gateway" {
  source = "git::https://github.com/pgetech/epic-pipeline-module-azure-application-gateway.git?ref=main"

  resource_group_name = "rg-my-app-dev"
  azure_region        = "westus2"
  gateway_name        = "my-app-appgw"
  subnet_id           = module.network.subnet_ids["appgw-subnet"]
  public_ip_id        = module.network.public_ip_ids["appgw-pip"]

  frontend_ports = [{ name = "http-port", port = 80 }]

  backend_address_pools = [
    { name = "frontend-pool", fqdns = [replace(replace(module.storage.primary_blob_endpoint, "https://", ""), "/", "")] },
    { name = "backend-pool",  fqdns = [module.container_app.ingress_fqdn] },
  ]

  probes = [
    { name = "frontend-health-probe", protocol = "Https", path = "/" },
    { name = "backend-health-probe",  protocol = "Https", path = "/v1/healthcheck" },
  ]

  backend_http_settings = [
    { name = "frontend-http-settings", port = 443, protocol = "Https", probe_name = "frontend-health-probe" },
    { name = "backend-http-settings",  port = 443, protocol = "Https", probe_name = "backend-health-probe" },
  ]

  http_listeners = [{ name = "http-listener", frontend_port_name = "http-port", protocol = "Http" }]

  url_path_maps = [{
    name                               = "path-map"
    default_backend_address_pool_name  = "frontend-pool"
    default_backend_http_settings_name = "frontend-http-settings"
    path_rules = [{
      name                       = "api-rule"
      paths                      = ["/api/*"]
      backend_address_pool_name  = "backend-pool"
      backend_http_settings_name = "backend-http-settings"
      rewrite_rule_set_name      = "api-rewrite"
    }]
  }]

  request_routing_rules = [{
    name               = "routing-rule"
    rule_type          = "PathBasedRouting"
    http_listener_name = "http-listener"
    priority           = 100
    url_path_map_name  = "path-map"
  }]

  rewrite_rule_sets = [{
    name = "api-rewrite"
    rewrite_rules = [{
      name          = "strip-api-prefix"
      rule_sequence = 100
      # The condition DEFINES the {var_uri_path_1} capture the url below uses.
      # Without it, the capture variable is undefined and the gateway CREATE fails.
      conditions = [{ variable = "var_uri_path", pattern = "/api/(.*)" }]
      url        = { path = "/{var_uri_path_1}", reroute = false }
    }]
  }]

  tags = module.tags.tags
}
```

---

## Versions

| Requirement | Version |
|-------------|---------|
| Terraform | `>= 1.5.0` |
| `hashicorp/azurerm` | `~> 4.0` |

---

## Notes

- **HTTPS is the target state.** The example uses an HTTP :80 listener to match the source workload's current state, but the SECURITY-03 control intent is HTTPS-only. Add an `ssl_certificate` (Key Vault-sourced) + an HTTPS listener, and a redirect rule from :80, before production. The `ssl_policy` default already pins a minimum of TLS 1.2 for backend/frontend TLS.
- **Cross-resource wiring.** The backend pool for a Container App takes its `ingress_fqdn`; the frontend pool for a static site takes the storage `primary_web_host` (strip scheme/trailing slash from the web endpoint). These create references across modules — expose them as outputs and pass them in; do not embed resource addresses.
- **Rewrite `url` component names** (`{var_uri_path_1}` etc.) are Application Gateway server variables — see the Azure rewrite documentation. A capture variable like `{var_uri_path_1}` only exists when a `conditions` entry with a capturing `pattern` (e.g. `/api/(.*)`) defines it; supply the condition on the same rewrite rule or the gateway CREATE fails on the undefined variable. CORS response headers can be added via `response_headers` on a rewrite rule.
- WAF is not enabled by default. Set `sku_name`/`sku_tier` to `WAF_v2` and add a WAF policy for internet-facing gateways handling sensitive data.
