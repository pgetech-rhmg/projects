# Verify that the Terraform Cloud build concluded successfully before continuing with any further pipeline steps.

module "codebuild_tfc_iam_role" {
  count         = local.tfc_check ? 1 : 0
  source        = "app.terraform.io/pgetech/iam/aws//modules/iam_role"
  version       = "0.0.8"
  name          = "${var.project_name}-tfc-${var.branch}"
  aws_service   = ["codebuild.amazonaws.com"]
  tags          = var.tags
  inline_policy = [file("${path.module}/codebuild_iam_policies/codebuild_step_1_tfc.json")]
}

module "codebuild_tfc" {
  count                           = local.tfc_check ? 1 : 0
  source                          = "app.terraform.io/pgetech/codebuild/aws//modules/codebuild_project"
  version                         = "0.0.10"
  codebuild_project_name          = "codebuild_tfc_${var.project_name}-${var.branch}"
  codebuild_project_build_timeout = 15
  artifact_type                   = "CODEPIPELINE"
  source_type                     = "CODEPIPELINE"
  environment_image               = var.codebuild_image
  environment_type                = "LINUX_CONTAINER"
  concurrent_build_limit          = 1
  codebuild_project_role          = module.codebuild_tfc_iam_role[0].arn
  codebuild_sc_token              = var.github_secret
  compute_type                    = "BUILD_GENERAL1_LARGE"
  tags                            = var.tags
  vpc_id                          = data.aws_vpc.mrad_vpc.id
  source_buildspec = yamlencode({
    version : 0.2,
    phases : {
      build : {
        commands : [
          file("${path.module}/codebuild_buildspec/buildspec_tfc.sh"),
        ]
      }
    }
  })
  subnet_ids = [
    data.aws_subnet.private1.id,
    data.aws_subnet.private2.id,
    data.aws_subnet.private3.id
  ]
  security_group_ids = [module.security_group.sg_id]
  codebuild_resource_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.id}:root"
      },
      "Action" : [
        "codebuild:BatchGetProjects",
        "codebuild:BatchGetBuilds",
        "codebuild:ListBuildsForProject"
      ],
      "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.id}:project/codebuild_tfc_${var.project_name}-${var.branch}"
    }]
  })
  encryption_key = local.kms_key_arn

  environment_variables = [
    {
      name  = "TFC_TOKEN"
      value = var.tfc_token_secret_name
      type  = "SECRETS_MANAGER"
    },
    {
      name  = "TFC_WS"
      value = terraform.workspace
      type  = "PLAINTEXT"
    },
  ]
}
