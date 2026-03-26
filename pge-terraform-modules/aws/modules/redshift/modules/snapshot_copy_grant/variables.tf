#Variables for tags
variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.1"
  tags    = var.tags
}

#Variables for sanpshot_grant_copy
variable "snapshot_copy_grant_name" {
  description = "A friendly name for identifying the grant."
  type        = string
}

variable "kms_key_id" {
  description = "The unique identifier for the customer master key (CMK) that the grant applies to. Specify the key ID or the Amazon Resource Name (ARN) of the CMK. To specify a CMK in a different AWS account, you must use the key ARN. If not specified, the default key is used."
  type        = string
}