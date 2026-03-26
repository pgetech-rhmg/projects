module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

### SSM Document

variable "ssm_document_name" {
  type        = string
  description = "SSM document name"
}

variable "ssm_document_type" {
  type        = string
  description = "The type of the document. Valid document types include: Automation, Command, Package, Policy, and Session"
  default     = "Command"
}

variable "ssm_document_format" {
  type        = string
  description = "The format of the document. Valid document types include: JSON and YAML"
  default     = "JSON"
  validation {
    condition = anytrue([
      var.ssm_document_format == "JSON",
    var.ssm_document_format == "YAML"])
    error_message = "Valid values for ssm_document_format are JSON and YAML."
  }
}

variable "ssm_document_content" {
  type        = string
  description = "The JSON or YAML content of the document."
}

variable "ssm_document_version_name" {
  type        = string
  description = "A field specifying the version of the artifact you are creating with the document."
  default     = null
}

variable "ssm_document_attachments_source" {
  description = "One or more configuration blocks describing attachments sources to a version of a document."
  type = list(object({
    key : string
    values : list(string)
    name : string
  }))
  default = []
}

variable "ssm_document_permissions" {
  description = "Additional Permissions to attach to the document. The permissions attribute specifies how you want to share the document."
  type        = map(string)
  default     = {}
}

variable "ssm_document_target_type" {
  description = "The target type which defines the kinds of resources the document can run on. For example, /AWS::EC2::Instance."
  type        = string
  default     = null
}
