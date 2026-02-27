############################################
# Locals
############################################

locals {
  enable_https = try(var.security.certificate_arn, null) != null && trimspace(try(var.security.certificate_arn, "")) != ""
  alb_scheme = try(var.security.public, false) ? "internet-facing" : "internal"
  associate_public_ip = try(var.network.associate_public_ip, false)
  allowed_ingress_cidrs = length(try(var.network.allowed_ingress_cidrs, [])) > 0 ? var.network.allowed_ingress_cidrs : (length(try(var.network.private_subnet_cidrs, [])) > 0 ? var.network.private_subnet_cidrs : ["0.0.0.0/0"])

  scaling = {
    min_size      = try(var.scaling.min_size, 1)
    max_size      = try(var.scaling.max_size, 2)
    instance_type = try(var.scaling.instance_type, "t3.medium")
  }
}
