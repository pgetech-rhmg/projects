#
# Filename    : modules/lm-tags/outputs.tf
# Date        : 28 Feb 2025
# Author      : Sean Fairchild (s3ff@pge.com)
# Description : This terraform module applies mandatory tags to Locate & Mark the resources.
#
output "tags" {
  value = module.tags.tags
}

