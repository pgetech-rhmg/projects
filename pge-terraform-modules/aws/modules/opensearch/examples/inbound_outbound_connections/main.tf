module "outbound_connection" {
  source = "../../modules/outbound_connection"

  for_each         = var.outbound_connection_enabled
  local_domain     = var.local_domain
  remote_domain    = var.remote_domain
  connection_alias = var.connection_alias
}

module "inbound_connection_accepter" {
  source = "../../modules/inbound_connection_accepter"

  for_each      = var.inbound_connection_enabled
  connection_id = module.outbound_connection.outbound_connection_id
}