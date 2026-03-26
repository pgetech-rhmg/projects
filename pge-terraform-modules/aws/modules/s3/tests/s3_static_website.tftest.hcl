run "s3_static_website" {
  command = apply

  module {
    source = "./examples/s3_static_website"
  }
}

variables {
  aws_region         = "us-west-2"
  account_num        = "750713712981"
  aws_role           = "CloudAdmin"
  kms_role           = "CloudAdmin"
  custom_bucket_name = "ccoe-statics3-bucket-test"
  website = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = [{
      condition = {
        key_prefix_equals = "docs/"
      },
      redirect = {
        replace_key_prefix_with = "documents/"
      }
      }, {
      condition = {
        http_error_code_returned_equals = 404
        key_prefix_equals               = "archive/"
      },
      redirect = {
        host_name          = "archive.myhost.com"
        http_redirect_code = 301
        protocol           = "https"
        replace_key_with   = "not_found.html"
      }
    }]
  }
  kms_name           = "s3_static_bucket_kms"
  kms_description    = "ccoe-s3-static-bucket-kms"
  AppID              = "1001"
  Environment        = "Dev"
  DataClassification = "Internal"
  CRIS               = "Low"
  Notify             = ["abc1@pge.com", "def2@pge.com", "ghi3@pge.com"]
  Owner              = ["abc1", "def2", "ghi3"]
  Compliance         = ["None"]
  Order              = 8115205
}
