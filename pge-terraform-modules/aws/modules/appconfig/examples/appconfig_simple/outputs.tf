output "appconfig_outputs" {
  value = { for k, v in module.appconfig_simple : k => v }
}