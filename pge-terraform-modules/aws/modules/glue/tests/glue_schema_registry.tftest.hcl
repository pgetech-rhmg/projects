run "glue_schema_registry" {
  command = apply

  module {
    source = "./examples/glue_schema_registry"
  }
}

variables {
  aws_region             = "us-west-2"
  account_num            = "056672152820"
  aws_role               = "CloudAdmin"
  AppID                  = "1001"
  Environment            = "Dev"
  DataClassification     = "Internal"
  CRIS                   = "Low"
  Notify                 = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner                  = ["abc1", "def2", "ghi3"]
  Compliance             = ["None"]
  Order                  = 8115205
  optional_tags          = { service = "glue" }
  name                   = "example"
  glue_schema_name       = "Test-iac-3"
  glue_data_format       = "AVRO"
  glue_compatibility     = "NONE"
  glue_schema_definition = "{\"type\": \"record\", \"name\": \"r1\", \"fields\": [ {\"name\": \"f1\", \"type\": \"int\"}, {\"name\": \"f2\", \"type\": \"string\"} ]}"
}
