resource "aws_db_proxy" "this" {
  name                   = local.proxy_name
  engine_family          = var.engine_family
  role_arn               = var.role_arn
  vpc_subnet_ids         = var.vpc_subnet_ids
  vpc_security_group_ids = var.vpc_security_group_ids

  require_tls         = var.require_tls
  idle_client_timeout = var.idle_client_timeout
  debug_logging       = var.debug_logging

  dynamic "auth" {
    for_each = var.secret_arns
    content {
      auth_scheme               = "SECRETS"
      iam_auth                  = var.iam_auth
      client_password_auth_type = var.client_password_auth_type
      description               = var.auth_description
      username                  = var.username
      secret_arn                = auth.value
    }
  }

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.require_tls == true
      error_message = "require_tls must be true per SAF Item #3 (TLS is non-negotiable for proxy connections)."
    }

    precondition {
      condition     = var.iam_auth == "REQUIRED"
      error_message = "iam_auth must be REQUIRED per SAF Item #8 (IAM database authentication is the only supported client auth path)."
    }

    precondition {
      condition     = var.debug_logging == false
      error_message = "debug_logging must remain false per SAF Item #6 (enhanced logging captures full SQL statements; auto-disables after 24h regardless)."
    }

    precondition {
      condition     = length(var.secret_arns) >= 1
      error_message = "secret_arns must contain at least one Secrets Manager ARN holding the database credential."
    }
  }
}

resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name

  connection_pool_config {
    max_connections_percent      = try(var.connection_pool_config.max_connections_percent, 100)
    max_idle_connections_percent = try(var.connection_pool_config.max_idle_connections_percent, 50)
    connection_borrow_timeout    = try(var.connection_pool_config.connection_borrow_timeout, 120)
    init_query                   = try(var.connection_pool_config.init_query, null)
    session_pinning_filters      = try(var.connection_pool_config.session_pinning_filters, [])
  }
}

resource "aws_db_proxy_target" "this" {
  db_proxy_name          = aws_db_proxy.this.name
  target_group_name      = aws_db_proxy_default_target_group.this.name
  db_cluster_identifier  = local.has_target_db_cluster ? var.target_db_cluster_identifier : null
  db_instance_identifier = local.has_target_db_instance ? var.target_db_instance_identifier : null

  lifecycle {
    precondition {
      condition     = local.has_target_db_cluster != local.has_target_db_instance
      error_message = "Provide exactly one of target_db_cluster_identifier or target_db_instance_identifier."
    }
  }
}
