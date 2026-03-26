
#### Cluster Locals ########
locals {
  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Order              = var.Order
  Compliance         = var.Compliance

}

#### Tags module ########
module "tags" {
  source             = "app.terraform.io/pgetech/tags/aws"
  version            = "0.1.2"
  AppID              = local.AppID
  Environment        = local.Environment
  DataClassification = local.DataClassification
  CRIS               = local.CRIS
  Notify             = local.Notify
  Owner              = local.Owner
  Compliance         = local.Compliance
  Order              = local.Order
}

module "vpc-sec-cidr" {
  source                    = "../../"
  parameter_sec_vpc_cidr    = var.parameter_sec_vpc_cidr
  create_vpc_sec_cidr       = true
  parameter_transit_gateway = var.parameter_transit_gateway
  parameter_vpc_id_name     = var.parameter_vpc_id_name
  subnet_a_cidr               = var.subnet_a_cidr
  subnet_b_cidr               = var.subnet_b_cidr
  subnet_c_cidr               = var.subnet_c_cidr
  subnet_a_name              = var.subnet_a_name
  subnet_b_name              = var.subnet_b_name
  subnet_c_name              = var.subnet_c_name
  parameter_subnet_ida = var.parameter_subnet_ida
  parameter_subnet_idb = var.parameter_subnet_idb
  parameter_subnet_idc= var.parameter_subnet_idc
  tags                      = module.tags.tags
}