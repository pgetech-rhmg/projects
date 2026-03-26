/*
 * # AWS DocumentDB Global cluster with read replica example
*/
#
#  Filename    : aws/modules/documentdb/examples/global_cluster_with_read_replica/main.tf
#  Date        : 05 August 2022
#  Author      : TCS
#  Description : The terraform example creates a global cluster with read replica


locals {
  region = var.aws_region_sec
  kms_custom_policy = templatefile(
    "${path.module}/kms_policy.json",
    {
      account_num = data.aws_caller_identity.current.account_id
      role_name   = var.aws_role
    }
  )
  name = "${var.name}-${random_string.name.result}"
}


#To use encryption with this example module please refer 
 #https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules
 #uncomment the following lines to create kms key

 module "kms_key_primary" {
   providers = {
     aws = aws.primary
   }
   source      = "app.terraform.io/pgetech/kms/aws"
   version     = "0.1.0"
   name        = "alias/kms${local.name}"
   description = "CMK for encrypting Redshift"
   tags        = merge(module.tags.tags, var.optional_tags)
   aws_role    = var.aws_role
   policy      = local.kms_custom_policy
   kms_role    = var.kms_role
 }


 module "kms_key_secondary" {
   providers = {
     aws = aws.secondary
   }
   source      = "app.terraform.io/pgetech/kms/aws"
   version     = "0.1.0"
   name        = "alias/kms${local.name}"
   description = "CMK for encrypting Redshift"
   tags        = merge(module.tags.tags, var.optional_tags)
   aws_role    = var.aws_role
   policy      = local.kms_custom_policy
   kms_role    = var.kms_role
 }

#The resource random_string generates a random permutation of alphanumeric characters and optionally special characters
resource "random_string" "name" {
  length  = 8
  upper   = false
  special = false
}

resource "random_password" "cluster_password" {
  length      = 16
  special     = false
  min_numeric = 1
}

resource "random_password" "cluster_username" {
  length      = 16
  special     = false
  min_numeric = 1
}

module "tags" {
  source  = "app.terraform.io/pgetech/tags/aws"
  version = "0.1.2"

  AppID              = var.AppID
  Environment        = var.Environment
  DataClassification = var.DataClassification
  CRIS               = var.CRIS
  Notify             = var.Notify
  Owner              = var.Owner
  Compliance         = var.Compliance
  Order              = var.Order
}

# #########################################
# # Supporting Resources
# #########################################

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "vpc_id" {
  name = var.ssm_parameter_vpc_id
}

data "aws_ssm_parameter" "subnet_id1" {
  name = var.ssm_parameter_subnet_id1
}

data "aws_ssm_parameter" "subnet_id2" {
  name = var.ssm_parameter_subnet_id2
}

data "aws_ssm_parameter" "subnet_id3" {
  name = var.ssm_parameter_subnet_id3
}

data "aws_subnet" "docdb_1" {
  id = data.aws_ssm_parameter.subnet_id1.value
}

data "aws_subnet" "docdb_2" {
  id = data.aws_ssm_parameter.subnet_id2.value
}

########################################################################################
#Global cluster creation for new cluster
#########################################################################################

module "global_cluster" {
  source = "../../modules/global_cluster"

  global_cluster_identifier = local.name
  engine_version            = var.engine_version
  timeouts                  = var.timeouts
}

#########################################################################################

# There is a limitation to creating an encrypted cross-region replica with Terraform. You must specify 
# an existing KMS key for the database, otherwise you will get an error about not specifying a kmsKeyId.
# In other words, you must create KMS keys first and specify them when using this example.

module "docdb_cluster_primary" {
  source = "../../"
  providers = {
    aws = aws.primary
  }

  cluster_apply_immediately         = var.cluster_apply_immediately
  cluster_identifier                = "primary-${local.name}"
  cluster_master_username           = "aws${random_password.cluster_username.result}"
  cluster_master_password           = random_password.cluster_password.result
  cluster_kms_key_id                = module.kms_key_primary.key_arn
  cluster_engine_version            = var.engine_version
  cluster_vpc_security_group_ids    = [module.primary_security_group_docdb.sg_id]
  cluster_skip_final_snapshot       = var.cluster_skip_final_snapshot
  db_subnet_group_name              = module.subnet_group_primary.docdb_subnet_group_id
  db_cluster_parameter_group_name   = module.cluster_parameter_group_primary.documentdb_cluster_parameter_group_id
  cluster_global_cluster_identifier = module.global_cluster.id
  cluster_timeouts                  = var.cluster_timeouts
  tags                              = merge(module.tags.tags, var.optional_tags)
}

module "cluster_parameter_group_primary" {
  source = "../../modules/cluster_parameter_group"

  providers = {
    aws = aws.primary
  }

  docdb_cluster_parameter_group_family = var.docdb_cluster_parameter_group_family
  docdb_cluster_parameter_group_name   = "primary-${local.name}"
  parameter                            = var.parameter
  tags                                 = merge(module.tags.tags, var.optional_tags)
}

module "cluster_instance_primary" {
  source = "../../modules/cluster_instance"

  providers = {
    aws = aws.primary
  }

  apply_immediately  = var.cluster_apply_immediately
  cluster_identifier = module.docdb_cluster_primary.docdb_cluster_id
  instance_class     = var.cluster_instance_instance_class
  tags               = merge(module.tags.tags, var.optional_tags)
}

module "subnet_group_primary" {
  source = "../../modules/subnet_group"

  providers = {
    aws = aws.primary
  }

  subnet_group_name       = "primary-${local.name}"
  subnet_group_subnet_ids = [data.aws_ssm_parameter.subnet_id1.value, data.aws_ssm_parameter.subnet_id2.value, data.aws_ssm_parameter.subnet_id3.value]
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "primary_security_group_docdb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"

  providers = {
    aws = aws.primary
  }

  name   = "primary-${local.name}"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

#############################################################################################

module "docdb_cluster_secondary" {
  source     = "../../"
  depends_on = [time_sleep.primary_wait]

  providers = {
    aws = aws.secondary
  }

  cluster_apply_immediately         = var.cluster_apply_immediately
  cluster_identifier                = "secondary-${local.name}"
  cluster_kms_key_id                = module.kms_key_secondary.key_arn
  cluster_engine_version            = var.engine_version
  cluster_vpc_security_group_ids    = [module.secondary_security_group_docdb.sg_id]
  cluster_skip_final_snapshot       = var.cluster_skip_final_snapshot
  db_subnet_group_name              = module.subnet_group_secondary.docdb_subnet_group_id
  db_cluster_parameter_group_name   = module.cluster_parameter_group_secondary.documentdb_cluster_parameter_group_id
  cluster_global_cluster_identifier = module.global_cluster.id
  cluster_timeouts                  = var.cluster_timeouts
  tags                              = merge(module.tags.tags, var.optional_tags)
}

module "cluster_parameter_group_secondary" {
  source = "../../modules/cluster_parameter_group"

  providers = {
    aws = aws.secondary
  }

  docdb_cluster_parameter_group_family = var.docdb_cluster_parameter_group_family
  docdb_cluster_parameter_group_name   = "secondary-${local.name}"
  parameter                            = var.parameter
  tags                                 = merge(module.tags.tags, var.optional_tags)
}

module "cluster_instance_secondary" {
  source = "../../modules/cluster_instance"

  providers = {
    aws = aws.secondary
  }

  apply_immediately  = var.cluster_apply_immediately
  cluster_identifier = module.docdb_cluster_secondary.docdb_cluster_id
  instance_class     = var.cluster_instance_instance_class
  tags               = merge(module.tags.tags, var.optional_tags)
}

module "subnet_group_secondary" {
  source = "../../modules/subnet_group"

  providers = {
    aws = aws.secondary
  }

  subnet_group_name       = "secondary-${local.name}"
  subnet_group_subnet_ids = module.vpc.private_subnets
  tags                    = merge(module.tags.tags, var.optional_tags)
}

module "secondary_security_group_docdb" {
  source  = "app.terraform.io/pgetech/security-group/aws"
  version = "0.1.1"
  providers = {
    aws = aws.secondary
  }

  name   = "secondary-${local.name}"
  vpc_id = module.vpc.vpc_id
  cidr_ingress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE Ingress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE Ingress rules"
  }]
  cidr_egress_rules = [{
    from             = 80,
    to               = 80,
    protocol         = "tcp",
    cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    description      = "CCOE egress rules"
    },
    {
      from             = 443,
      to               = 443,
      protocol         = "tcp",
      cidr_blocks      = [data.aws_subnet.docdb_1.cidr_block, data.aws_subnet.docdb_2.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      description      = "CCOE egress rules"
  }]
  tags = merge(module.tags.tags, var.optional_tags)
}

##############################################################################################

# Time sleep is used to wait for 05 mins after cluster resource creation, this is needed for the cluster to succesfully initialize
resource "time_sleep" "primary_wait" {
  depends_on      = [module.docdb_cluster_primary]
  create_duration = var.time_sleep_duration
}

# We are using this public vpc module to create a vpc and subnets in the region us-east-1 for the  global cluster
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.15.0"
  providers = {
    aws = aws.secondary
  }

  name               = "global-cluster-test-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["${local.region}a", "${local.region}b", "${local.region}c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_ipv6        = false
  enable_nat_gateway = false
  single_nat_gateway = false
  public_subnet_tags = merge(module.tags.tags, var.optional_tags)
  vpc_tags           = merge(module.tags.tags, var.optional_tags)
  tags               = merge(module.tags.tags, var.optional_tags)
}






#########################################################################################
# Global cluster creation for existing cluster
# commenting code block- global cluster for existing cluster
# for purpose of example creating global cluster with new cluster
##########################################################################################

# module "global_cluster_for_existing_cluster" {
#   source                       = "../../modules/global_cluster"
#   global_cluster_identifier    = local.name
#   source_db_cluster_identifier = var.source_db_cluster_identifier
#   timeouts                     = var.timeouts

# }