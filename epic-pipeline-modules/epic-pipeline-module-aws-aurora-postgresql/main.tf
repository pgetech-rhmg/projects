resource "aws_db_subnet_group" "this" {
  name       = local.subnet_name
  subnet_ids = var.subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "this" {
  name        = local.sg_name
  description = "Aurora PostgreSQL security group for ${var.app_name} (${var.environment})."
  vpc_id      = var.vpc_id
  tags        = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "from_sg" {
  for_each = toset(var.ingress_security_group_ids)

  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = var.port
  to_port                      = var.port
  description                  = "Aurora ingress from SG ${each.value}"
}

resource "aws_vpc_security_group_ingress_rule" "from_cidr" {
  for_each = toset(var.ingress_cidr_blocks)

  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value
  ip_protocol       = "tcp"
  from_port         = var.port
  to_port           = var.port
  description       = "Aurora ingress from CIDR ${each.value}"
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = local.parameter_name
  family      = var.family
  description = "Aurora PostgreSQL cluster parameters for ${var.app_name} (${var.environment})."

  dynamic "parameter" {
    for_each = var.cluster_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, null)
    }
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  name        = local.instance_pg
  family      = var.family
  description = "Aurora PostgreSQL instance parameters for ${var.app_name} (${var.environment})."

  dynamic "parameter" {
    for_each = var.instance_parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = try(parameter.value.apply_method, null)
    }
  }

  tags = var.tags
}

resource "aws_rds_cluster" "this" {
  cluster_identifier = local.cluster_name
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  engine_mode        = var.engine_mode
  database_name      = var.database_name
  port               = var.port

  master_username               = var.master_username
  master_password               = local.manage_master_password ? null : var.master_password
  manage_master_user_password   = local.manage_master_password ? true : null
  master_user_secret_kms_key_id = local.manage_master_password ? var.master_user_secret_kms_key_id : null

  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = [aws_security_group.this.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = var.preferred_backup_window
  preferred_maintenance_window = var.preferred_maintenance_window

  deletion_protection         = var.deletion_protection
  skip_final_snapshot         = var.skip_final_snapshot
  final_snapshot_identifier   = var.final_snapshot_identifier
  apply_immediately           = var.apply_immediately
  allow_major_version_upgrade = var.allow_major_version_upgrade

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = local.use_serverless_v2 ? [var.serverlessv2_scaling_configuration] : []
    content {
      min_capacity = try(serverlessv2_scaling_configuration.value.min_capacity, null)
      max_capacity = try(serverlessv2_scaling_configuration.value.max_capacity, null)
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = local.manage_master_password ? var.master_password == null : var.master_password != null
      error_message = "Provide master_password OR set manage_master_user_password=true (mutually exclusive)."
    }

    precondition {
      condition     = var.publicly_accessible == false
      error_message = "publicly_accessible must remain false per SAF (private subnets only)."
    }

    precondition {
      condition     = var.storage_encrypted == true
      error_message = "storage_encrypted must remain true per SAF Item #1."
    }

    precondition {
      condition = !(
        contains(["Confidential", "Restricted", "Privileged"], try(var.tags["DataClassification"], "")) &&
        (var.kms_key_id == null || length(trimspace(var.kms_key_id)) == 0)
      )
      error_message = "kms_key_id (CMK) is mandatory per SAF Item #2 when DataClassification is Confidential, Restricted, or Privileged."
    }

    precondition {
      condition     = anytrue([for p in var.cluster_parameters : try(p.name, "") == "rds.force_ssl" && try(p.value, "") == "1"])
      error_message = "cluster_parameters must include rds.force_ssl=1 per SAF Item #3."
    }

    precondition {
      condition     = var.backup_retention_period >= 15
      error_message = "backup_retention_period must be at least 15 days per SAF Item #7."
    }
  }
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${local.cluster_name}-${count.index == 0 ? "writer" : "reader-${count.index}"}"
  cluster_identifier = aws_rds_cluster.this.id
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
  instance_class     = var.instance_class

  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_parameter_group_name = aws_db_parameter_group.this.name

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval > 0 ? var.monitoring_role_arn : null

  publicly_accessible        = var.publicly_accessible
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.publicly_accessible == false
      error_message = "publicly_accessible must remain false per SAF Item #21."
    }

    precondition {
      condition     = var.monitoring_interval == 0 || (var.monitoring_role_arn != null && length(trimspace(var.monitoring_role_arn)) > 0)
      error_message = "monitoring_role_arn is required when monitoring_interval > 0 (Enhanced Monitoring per SAF Item #28)."
    }
  }
}
