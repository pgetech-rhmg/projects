module "validate_tags" {
  source  = "app.terraform.io/pgetech/validate-pge-tags/aws"
  version = "0.1.2"
  tags    = var.tags
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
}

## Patch Baseline

variable "ssm_patch_baseline_name" {
  type        = string
  description = "The name of the patch baseline"
}

variable "ssm_patch_baseline_description" {
  type        = string
  description = "The description of the patch baseline."
  default     = "This is PGE patch-manager baseline"
}

variable "operating_system" {
  description = "Defines the operating system the patch baseline applies to. Supported operating systems include WINDOWS, AMAZON_LINUX, AMAZON_LINUX_2, SUSE, UBUNTU, CENTOS, and REDHAT_ENTERPRISE_LINUX. The Default value is WINDOWS."
  type        = string
  default     = "AMAZON_LINUX_2"
}

variable "approved_patches" {
  description = "A list of explicitly approved patches for the baseline"
  type        = list(string)
  default     = []
}

variable "rejected_patches" {
  description = "A list of rejected patches"
  type        = list(string)
  default     = []
}

variable "rejected_patches_action" {
  description = "The action for Patch Manager to take on patches included in the rejected_patches list. Valid values are ALLOW_AS_DEPENDENCY and BLOCK"
  type        = string
  default     = null
  validation {
    condition = anytrue([
      var.rejected_patches_action == null,
      var.rejected_patches_action == "ALLOW_AS_DEPENDENCY",
    var.rejected_patches_action == "BLOCK"])
    error_message = "Valid values for rejected_patches_action are ALLOW_AS_DEPENDENCY and BLOCK."
  }
}

variable "approved_patches_compliance_level" {
  type        = string
  description = "Defines the compliance level for approved patches. This means that if an approved patch is reported as missing, this is the severity of the compliance violation. Valid compliance levels include the following: CRITICAL, HIGH, MEDIUM, LOW, INFORMATIONAL, UNSPECIFIED. The default value is UNSPECIFIED."
  default     = "UNSPECIFIED"
}

variable "patch_baseline_approval_rules" {
  description = "A set of rules used to include patches in the baseline. Up to 10 approval rules can be specified. Each `approval_rule` block requires the fields documented below."
  type        = list(any)
  default     = []
}

variable "patch_baseline_global_filter" {
  description = "A set of global filters used to exclude patches from the baseline. Up to 4 global filters can be specified using Key/Value pairs. Valid Keys are PRODUCT, CLASSIFICATION, MSRC_SEVERITY, and PATCH_ID"
  type = list(object({
    key : string
    values : list(string)
  }))
  default = []
}

variable "set_default_patch_baseline" {
  description = "whether to set this baseline as a Default Patch Baseline"
  type        = bool
  default     = false
}

variable "patch_groups" {
  description = "The targets to register with the maintenance window. In other words, the instances to run commands on when the maintenance window runs. You can specify targets using instance IDs, resource group names, or tags that have been applied to instances."
  type        = list(string)
  default     = []
}