# # Build requests layer
# resource "null_resource" "build_requests_layer" {
#   triggers = {
#     requirements = filemd5("${path.module}/lambda_layers/requests/requirements.txt")
#   }

#   provisioner "local-exec" {
#     command     = "chmod +x ./build.sh && ./build.sh"
#     working_dir = "${path.module}/lambda_layers/requests"
#   }
# }

# # Requests Lambda Layer managed by PGE lambda module
# module "requests_layer" {
#   source  = "app.terraform.io/pgetech/lambda/aws//modules/lambda_layer_version_local"
#   version = "0.1.3"

#   layer_version_layer_name               = "ami-factory-requests-${var.environment}"
#   layer_version_compatible_runtimes      = ["python3.13", "python3.12", "python3.11"]
#   layer_version_compatible_architectures = "x86_64"
#   layer_version_description              = "Requests library for Lambda functions"
#   local_zip_source_directory             = "${path.module}/lambda_layers/requests/python"

#   # The module requires a principal value; don't expose publicly by default.
#   layer_version_permission_principal = var.account_num

#   depends_on = [null_resource.build_requests_layer]
# }
