# final stage, responsible for processing and uploading data to Neptune
resource "aws_codebuild_project" "process_and_upload_seed" {
  name          = "${var.prefix}-process-and-upload-seed-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = var.build_timeout

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    # using largest compute for this stage
    # due to the large amount of data being processed
    # reduces pipeline run time by ~50%
    compute_type = "BUILD_GENERAL1_XLARGE"

    # no MRAD-specific requirements for these stages, so we use a generic image:
    image = "aws/codebuild/standard:7.0"
    type  = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "STACK_INDEX"
      type  = "PLAINTEXT"
      value = "0"
    }

    environment_variable {
      name  = "SUFFIX"
      type  = "PLAINTEXT"
      value = local.suffix
    }

    environment_variable {
      name  = "DB_S3_ROLE_ARN"
      type  = "PLAINTEXT"
      value = data.aws_iam_role.neptune.arn
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }

    environment_variable {
      name  = "SOURCE_BRANCH"
      type  = "PLAINTEXT"
      value = local.repo_branch
    }

    environment_variable {
      name  = "NODE_ENV"
      type  = "PLAINTEXT"
      value = lower(local.node_env)
    }

    environment_variable {
      name  = "PREFIX"
      type  = "PLAINTEXT"
      value = var.prefix
    }

  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-processupload.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

# first stage after source: gets last sequence ID from couchbase
resource "aws_codebuild_project" "resetdb_seqid" {
  name          = "${var.prefix}-resetdb-seqid-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      type  = "PLAINTEXT"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "AWS_REGION"
      type  = "PLAINTEXT"
      value = data.aws_region.current.name
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-identify.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

# doctype stages each download a different document type from couchbase
resource "aws_codebuild_project" "doctype_gc_read" {
  name          = "${var.prefix}-doctype_gc_read-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-gc-read"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_tc_read" {
  name          = "${var.prefix}-doctype_tc_read-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-tc-read"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_survey_patrol" {
  name          = "${var.prefix}-doctype_survey_patrol-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-survey-patrol"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype-gascompliancedates" {
  name          = "${var.prefix}-doctype-gascompliancedates-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-gascompliancedates"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype-engage-team" {
  name          = "${var.prefix}-doctype-engage-team-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-engage-team"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_e280" {
  name          = "${var.prefix}-doctype_workorder_e280-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-e280"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_n280" {
  name          = "${var.prefix}-doctype_workorder_n280-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-n280"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_obs4" {
  name          = "${var.prefix}-doctype_workorder_obs4-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-obs4"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_t280" {
  name          = "${var.prefix}-doctype_workorder_t280-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-t280"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_g280" {
  name          = "${var.prefix}-doctype_workorder_g280-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-g280"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_assignment" {
  name          = "${var.prefix}-doctype_assignment-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-assignment"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_survey_assignment" {
  name          = "${var.prefix}-doctype_survey_assignment-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-survey-assignment"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_oq" {
  name          = "${var.prefix}-doctype_oq-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-oq"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workcenter" {
  name          = "${var.prefix}-doctype_workcenter-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workcenter"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_route" {
  name          = "${var.prefix}-doctype_route-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-route"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_compliance" {
  name          = "${var.prefix}-doctype_compliance-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-compliance"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_surveyresult" {
  name          = "${var.prefix}-doctype_surveyresult-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-surveyresult"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_survey_result" {
  name          = "${var.prefix}-doctype_survey_result-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-survey-result"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_activity" {
  name          = "${var.prefix}-doctype_activity-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-activity"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_sg" {
  name          = "${var.prefix}-doctype_sg-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-sg"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_aoc" {
  name          = "${var.prefix}-doctype_aoc-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-aoc"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_activity_summary" {
  name          = "${var.prefix}-doctype_activity_summary-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-activity_summary"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_breadcrumb" {
  name          = "${var.prefix}-doctype_breadcrumb-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-breadcrumb"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-idsonly.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_maintplan" {
  name          = "${var.prefix}-doctype_maintplan-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-maintplan"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_funcloc" {
  name          = "${var.prefix}-doctype_funcloc-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-funcloc"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_divisionmwc" {
  name          = "${var.prefix}-doctype_divisionmwc-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-divisionmwc"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_aerial_indication" {
  name          = "${var.prefix}-doctype_aerial_indication-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-aerial-indication"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_aerial_survey" {
  name          = "${var.prefix}-doctype_aerial_survey-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-aerial-survey"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_electric_inspector_profile" {
  name          = "${var.prefix}-doctype_electric_inspector_profile-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-electric-inspector-profile"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_psps_event" {
  name          = "${var.prefix}-doctype_psps_event-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-psps-event"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_inspectchecklist_et" {
  name          = "${var.prefix}-doctype_inspectchecklist_et-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-inspectchecklist-et"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_inspectchecklist_ed" {
  name          = "${var.prefix}-doctype_inspectchecklist_ed-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-inspectchecklist-ed"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_lc" {
  name          = "${var.prefix}-doctype_lc-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-lc"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_corrective_assignment" {
  name          = "${var.prefix}-doctype_corrective_assignment-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-corrective-assignment"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_inspectchecklist_gtls" {
  name          = "${var.prefix}-doctype_inspectchecklist_gtls-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-inspectchecklist-gtls"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_inspectchecklist_gdls" {
  name          = "${var.prefix}-doctype_inspectchecklist_gdls-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-inspectchecklist-gdls"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_workorder_geometry" {
  name          = "${var.prefix}-doctype_workorder_geometry-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-workorder-geometry"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_amld" {
  name          = "${var.prefix}-doctype_amld-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-amld"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_engage_workorder" {
  name          = "${var.prefix}-doctype_engage_workorder-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-engage-workorder"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

resource "aws_codebuild_project" "doctype_engage_cmdb" {
  name          = "${var.prefix}-doctype-engage-cmdb-${lower(local.suffix)}"
  service_role  = data.aws_iam_role.build.arn
  build_timeout = 300

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/standard:7.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "ENVIRONMENT"
      type  = "PLAINTEXT"
      value = lower(local.environment_name)
    }

    environment_variable {
      name  = "CHANNEL"
      type  = "PLAINTEXT"
      value = "doctype-engage-cmdb"
    }

    environment_variable {
      name  = "SWAP_ENV"
      type  = "PLAINTEXT"
      value = local.swapenv
    }

    environment_variable {
      name  = "PIPELINE_BUCKET"
      type  = "PLAINTEXT"
      value = module.pipeline_bucket.id
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/pipeline-buildspecs/buildspec-breakup.yaml")
  }

  vpc_config {
    vpc_id = data.aws_vpc.mrad_vpc.id

    subnets = [
      data.aws_subnet.mrad1.id,
      data.aws_subnet.mrad2.id,
      data.aws_subnet.mrad3.id,
    ]

    security_group_ids = [
      data.aws_security_group.lambda_sgs.id,
    ]
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  tags = var.tags
}

