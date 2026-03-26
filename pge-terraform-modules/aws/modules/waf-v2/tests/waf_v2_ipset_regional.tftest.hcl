run "waf_v2_ipset_regional" {
  command = apply

  module {
    source = "./examples/waf_v2_ipset_regional"
  }
}

variables {
  aws_region                      = "us-west-2"
  account_num                     = "750713712981"
  aws_role                        = "CloudAdmin"
  AppID                           = "1001"
  Environment                     = "Dev"
  DataClassification              = "Internal"
  CRIS                            = "Low"
  Notify                          = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                           = ["abc1", "def2", "ghi3"]
  Compliance                      = ["None"]
  optional_tags                   = { service = "waf-v2" }
  Order                           = 8115205
  name                            = "example"
  wafv2_ip_set_description        = "Waf ipset testing"
  wafv2_ip_set_ip_address_version = "IPV4"
  wafv2_ip_set_addresses          = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}
