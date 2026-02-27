locals {
  website_root = abspath("${path.root}/${var.app_name}/${var.app_path}")

  all_files = fileset(local.website_root, "**")

  default_content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    json = "application/json"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
    txt  = "text/plain"
    map  = "application/json"
  }

  content_types = merge(
    local.default_content_types,
    var.content_type_overrides
  )
}

resource "aws_s3_object" "website_files" {
  for_each = local.all_files

  bucket = var.bucket_name
  key    = each.key

  source = "${local.website_root}/${each.key}"
  etag   = filemd5("${local.website_root}/${each.key}")

  content_type = lookup(
    local.content_types,
    lower(split(".", each.key)[length(split(".", each.key)) - 1]),
    "binary/octet-stream"
  )

  cache_control = var.cache_control
}

