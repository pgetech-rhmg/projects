#
# Filename    : modules/utils/examples/main.tf
# Date        : 09 Mar 2023
# Author      : Balaji Venkataraman (b1v6@pge.com)
# Description : This terraform module to test utility sub modules
#

# providers
terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_num}:role/${var.aws_role}"
  }
}

# variables
variable "account_num" {
  type        = string
  description = "Target AWS account number, mandatory"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_role" {
  description = "AWS role to assume"
  type        = string
}

variable "workspace_name" {
  description = "workspace name"
  type        = string
  default     = null
}

variable "workspace_id" {
  description = "workspace id"
  type        = string
  default     = null
}

# module invocation
module "vpcid" {
  source = "../../modules/vpcid/"
}

module "linux_ami_id" {
  source = "../../modules/golden-ami/"
}

module "windows_ami_id" {
  source = "../../modules/golden-ami/"
  os     = "windows"
}

module "windows_security_groups" {
  source = "../../modules/windows-security-groups"
}

module "subnet1_id" {
  source = "../../modules/subnet"
}

module "subnet1_cidr" {
  source  = "../../modules/subnet"
  is_cidr = true
}

module "subnet2_id" {
  source     = "../../modules/subnet"
  subnet_num = 2
}

module "subnet2_cidr" {
  source     = "../../modules/subnet"
  subnet_num = 2
  is_cidr    = true
}

module "ssm_appid" {
  source = "../../modules/ssm"
}

module "ssm_nacl" {
  source = "../../modules/ssm"
  name   = "/vpc/privatenacl/id"
}

module "ssm_rtbl" {
  source = "../../modules/ssm"
  name   = "/vpc/privateroutetable/id"
}

module "ws" {
  source = "../../modules/workspace-info"
}

# output
output "vpcid" {
  value     = module.vpcid.vpc_id
  sensitive = true
}

output "linux_ami_id" {
  value     = module.linux_ami_id.ami_id
  sensitive = true
}

output "windows_ami_id" {
  value     = module.windows_ami_id.ami_id
  sensitive = true
}

output "windows_security_groups" {
  value     = module.windows_security_groups.win_sg_list
  sensitive = true
}

output "subnet1_id" {
  value     = module.subnet1_id.subnet_id_cidr
  sensitive = true
}

output "subnet1_cidr" {
  value     = module.subnet1_cidr.subnet_id_cidr
  sensitive = true
}

output "subnet2_id" {
  value     = module.subnet2_id.subnet_id_cidr
  sensitive = true
}

output "subnet2_cidr" {
  value     = module.subnet2_cidr.subnet_id_cidr
  sensitive = true
}

output "ssm_appid" {
  value     = module.ssm_appid.value
  sensitive = true
}

output "ssm_nacl" {
  value     = module.ssm_nacl.value
  sensitive = true
}

output "ssm_rtbl" {
  value     = module.ssm_rtbl.value
  sensitive = true
}

output "ws_name" {
  value     = module.ws.name
  sensitive = true
}

output "ws_id" {
  value     = module.ws.id
  sensitive = true
}

output "ws_all" {
  value     = module.ws.all
  sensitive = true
}
