run "domain_saml_options" {
  command = apply

  module {
    source = "./examples/domain_saml_options"
  }
}

variables {
  account_num = "750713712981"
  aws_region  = "us-west-2"
  aws_role    = "CloudAdmin"
  saml_options = [{ domain_search = true,
    "saml_enabled" = true,
    "idp"          = [{ entity_id = "https://www.example.com" }],
  }]
  metadata_content_file = "saml-metadata.xml"
  domain_name           = "pgeos-test"
}
