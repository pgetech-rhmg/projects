#####################################################
# Creating Patch Baseline and patch-group 
#####################################################

module "ssm-patch-manager-baseline" {
  source = "../../modules/patch-manager-baseline"

  ssm_patch_baseline_name           = var.ssm_patch_baseline_name
  operating_system                  = var.operating_system
  approved_patches_compliance_level = var.approved_patches_compliance_level
  patch_baseline_approval_rules     = var.patch_baseline_approval_rules
  set_default_patch_baseline        = var.set_default_patch_baseline

  patch_groups = var.patch_group_names

  tags = merge(module.tags.tags, local.optional_tags)

}