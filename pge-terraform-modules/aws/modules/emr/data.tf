
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "aws_emr_release_labels" "this" {

  dynamic "filters" {
    for_each = var.release_label_filters

    content {
      application = try(filters.value.application, null)
      prefix      = try(filters.value.prefix, null)
    }
  }
}
