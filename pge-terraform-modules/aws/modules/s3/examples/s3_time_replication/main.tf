/*
 * # AWS S3 module
 * Terraform module example which creates SAF2.0 S3 time replication resource in AWS
*/
#
# Filename    : module/s3/examples/s3_replication/main.tf
# Date        : 25 April 2022
# Author      : Sara Ahmad (s7aw@pge.com)
# Description : s3 creation main

locals {
  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
  AppID                   = var.AppID
  Environment             = var.Environment
  DataClassification      = var.DataClassification
  CRIS                    = var.CRIS
  Notify                  = var.Notify
  Owner                   = var.Owner
  Compliance              = var.Compliance
  Order                   = var.Order
  aws_role                = var.aws_role
  kms_role                = var.kms_role

}

data "aws_caller_identity" "current" {}

# To use encryption with this example please refer
# https://wiki.comp.pge.com/display/CCE/KMS+and+Terraform+Modules

module "kms_key" {
  source      = "app.terraform.io/pgetech/kms/aws"
  version     = "0.1.1"
  name        = var.kms_name
  description = var.kms_description
  tags        = module.tags.tags
  aws_role    = local.aws_role
  kms_role    = local.kms_role
}


module "iam_role" {
  source      = "app.terraform.io/pgetech/iam/aws"
  version     = "0.1.0"
  name        = var.iam_resource
  policy_arns = [module.iam_policy.arn]
  aws_service = ["s3.amazonaws.com"]
  tags        = module.tags.tags
}

module "iam_policy" {
  source  = "app.terraform.io/pgetech/iam/aws//modules/iam_policy"
  version = "0.1.0"
  name    = var.iam_resource
  tags    = module.tags.tags
  policy = [<<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
         "arn:aws:s3:::${local.source_bucket_name}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
         "s3:GetObjectVersionTagging"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${local.source_bucket_name}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags"
      ],
	  "Effect": "Allow",
            "Condition": {
                "StringLikeIfExists": {
                    "s3:x-amz-server-side-encryption": [
                        "aws:kms",
                        "AES256"
                    ],
                    "s3:x-amz-server-side-encryption-aws-kms-key-id": [
                        "${module.kms_key.key_arn}"
                    ]
                }
            },
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${local.source_bucket_name}/*"
    },
    {
       "Action": [
           "kms:Decrypt"
        ],
            "Effect": "Allow",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": "s3.${var.aws_region}.amazonaws.com",
                    "kms:EncryptionContext:aws:s3:arn": [
                        "arn:aws:s3:::${local.source_bucket_name}/*"
                    ]
                }
            },
            "Resource": [
                "${module.kms_key.key_arn}"
            ]
        },
        {
            "Action": [
                "kms:Encrypt"
            ],
            "Effect": "Allow",
            "Condition": {
                "StringLike": {
                    "kms:ViaService": "s3.${var.aws_region}.amazonaws.com",
                    "kms:EncryptionContext:aws:s3:arn": [
                        "arn:aws:s3:::${local.source_bucket_name}/*"
                    ]
                }
            },
            "Resource": [
                  "${module.kms_key.key_arn}"
            ]
        }  
    ]
}
POLICY
  ]

}


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

#########################################
# Create S3 bucket with pge policy
#########################################

module "source_s3" {
  source      = "../../"
  bucket_name = local.source_bucket_name
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  tags        = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology" })
  versioning  = var.versioning
}


module "source_s3_replication" {
  source      = "../../modules/s3_replication"
  bucket_name = module.source_s3.id
  replication_configuration = {
    role = module.iam_role.arn

    rules = [
      {
        id       = "kms-and-filter-replication"
        status   = true
        priority = 10

        delete_marker_replication = false

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "one"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"

          replica_kms_key_id = module.kms_key.key_arn
          account_id         = data.aws_caller_identity.current.account_id

          access_control_translation = {
            owner = "Destination"
          }

          replication_time = {
            status  = "Enabled"
            minutes = 15
          }

          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
      {
        id       = "replication-with-filter"
        priority = 20

        delete_marker_replication = false

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "two"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class      = "STANDARD"
          replica_kms_key_id = module.kms_key.key_arn
          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
      {
        id       = "replication-with-filter-priority"
        status   = "Enabled"
        priority = 30

        delete_marker_replication = true

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = ""
        }

        destination = {
          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class      = "STANDARD"
          replica_kms_key_id = module.kms_key.key_arn
          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
      {
        id     = "replication-without-filters"
        status = "Enabled"

        delete_marker_replication = true

        source_selection_criteria = {
          replica_modifications = {
            status = "Enabled"
          }
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        destination = {
          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class      = "STANDARD"
          replica_kms_key_id = module.kms_key.key_arn
          replication_time = {
            status  = "Enabled"
            minutes = 15
          }
          metrics = {
            status  = "Enabled"
            minutes = 15
          }
        }
      },
    ]
  }
  depends_on = [module.source_s3]
}

module "destination_s3" {
  source      = "../../"
  bucket_name = local.destination_bucket_name
  tags        = merge(module.tags.tags, { DRTier = "TIER 1 - Active / Active", Org = "Information Technology" })
  kms_key_arn = null # replace with module.kms_key.key_arn, after key creation
  versioning  = var.versioning
}


