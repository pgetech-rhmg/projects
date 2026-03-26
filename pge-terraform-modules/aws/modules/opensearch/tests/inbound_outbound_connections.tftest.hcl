run "inbound_outbound_connections" {
  command = apply

  module {
    source = "./examples/inbound_outbound_connections"
  }
}

variables {
  account_num      = "750713712981"
  aws_region       = "us-west-2"
  aws_role         = "CloudAdmin"
  local_domain     = "test"
  remote_domain    = "test1"
  connection_alias = "outbound_connection"
}
