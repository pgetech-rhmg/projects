# 3 main stages:
#   1. resource_diff_and_build_stacks
#   2. doctypes ran in parallel
#   3. process_and_upload_seed
#
# Note: no SonarQube or Artifactory stage because this is a seed pipeline,
# not a build pipeline
resource "aws_codepipeline" "engage_graph_pipeline" {
  name     = "${var.prefix}-graph-seed-${lower(local.suffix)}"
  role_arn = data.aws_iam_role.pipeline.arn

  artifact_store {
    location = module.pipeline_bucket.id
    type     = "S3"
    encryption_key {
      type = "KMS"
      id   = data.aws_kms_key.pipeline.id
    }
  }

  stage {
    name = "Source"
    action {
      name             = "SourceAction"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceOutput"]
      run_order        = 1
      configuration = {
        "Owner"                = "PGEDigitalCatalyst"
        "Repo"                 = "Engage-Graph"
        "PollForSourceChanges" = false
        "Branch"               = local.repo_branch
        "OAuthToken"           = data.aws_ssm_parameter.mrad_github_token.value
      }
    }
  }

  stage {
    name = "ResetDB-DownloadSeqID"

    action {
      name             = "ResetDB-DownloadSeqID"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["SourceOutput"]
      output_artifacts = ["StackNames"]
      run_order        = 1
      configuration = {
        "ProjectName" = aws_codebuild_project.resetdb_seqid.name
      }
    }
  }

  stage {
    name = "Download-Seed"

    action {
      name            = "downloadSeedDoctypeGcRead"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_gc_read.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeTcRead"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_tc_read.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeSurveyPatrol"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_survey_patrol.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeGasComplianceDates"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype-gascompliancedates.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeEngageTeam"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype-engage-team.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderE280"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_e280.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderN280"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_n280.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderObs4"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_obs4.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderT280"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_t280.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderG280"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_g280.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeAssignment"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_assignment.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeSurveyAssignment"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_survey_assignment.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeOq"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_oq.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkCenter"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workcenter.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeRoute"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_route.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeCompliance"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_compliance.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeSurveyresult"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_surveyresult.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeSurveyResult"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_survey_result.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeActivity"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_activity.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeSg"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_sg.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeAoc"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_aoc.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeActivitySummary"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_activity_summary.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeBreadcrumb"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_breadcrumb.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeMaintplan"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_maintplan.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeFuncloc"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_funcloc.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeDivisionmwc"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_divisionmwc.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeAerialIndication"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_aerial_indication.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeAerialSurvey"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_aerial_survey.name
        "PrimarySource" = "SourceOutput"
      }
    }


    action {
      name            = "downloadSeedDoctypeElectricInspectorProfile"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_electric_inspector_profile.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypePspsEvent"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_psps_event.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeInspectchecklistEt"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_inspectchecklist_et.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeInspectchecklistEd"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_inspectchecklist_ed.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeLc"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_lc.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeCorrectiveAssignment"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_corrective_assignment.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeInspectchecklistGtls"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_inspectchecklist_gtls.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeInspectchecklistGdls"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_inspectchecklist_gdls.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeWorkorderGeometry"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_workorder_geometry.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeEngageCmdb"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_engage_cmdb.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeAmld"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_amld.name
        "PrimarySource" = "SourceOutput"
      }
    }

    action {
      name            = "downloadSeedDoctypeEngageWorkorder"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.doctype_engage_workorder.name
        "PrimarySource" = "SourceOutput"
      }
    }
  }

  stage {
    name = "Process-Seed"

    action {
      name            = "process-seed-env-0"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts = ["SourceOutput", "StackNames"]
      run_order       = 1
      configuration = {
        "ProjectName"   = aws_codebuild_project.process_and_upload_seed.name
        "PrimarySource" = "SourceOutput"
      }
    }
  }

  tags = var.tags
}
