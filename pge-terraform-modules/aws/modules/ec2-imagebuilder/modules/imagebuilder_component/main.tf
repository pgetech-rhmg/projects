
#locals{
#   data = (templatefile(var.component_file,{}))
#}

resource "aws_imagebuilder_component" "this" {
  for_each = var.component_data

  name               = "${var.component_name_prefix}-${each.key}"
  version            = var.component_version
  change_description = var.change_description
  #data = var.data_uri == null ? local.data : null
  description           = var.description
  kms_key_id            = var.component_kms_key_id
  platform              = var.component_platform
  supported_os_versions = var.supported_os_versions
  #determine whether its a file or URI and assign accordingly
  uri = (
    #If it starts with "s3://", treat it as an s3 URI
    startswith(each.value, "s3://") ? each.value : null
  )

  data = (
    #If its a file path, treat it as a local file
    !startswith(each.value, "s3://") ? (fileexists(each.value) ? templatefile(each.value, {}) : null) : null
  )
  tags = merge(
    var.tags,
    { Name : each.key }
  )
  lifecycle {
    create_before_destroy = true
  }
}