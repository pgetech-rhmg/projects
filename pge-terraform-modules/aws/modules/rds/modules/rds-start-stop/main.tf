/*
 * # RDS start/stop

*/
#
#  Filename    : modules/rds/modules/rds-start-stop/main.tf
#  Date        : 26/8/2024
#  Author      : PGE
#  Description : RDS start/stop main file.
#  Notes       : This module automatically starts/stop RDS instances based on the tags associated with RDS cluster/instance. 
#This uses lambda and cloudwatch resources to perform this action





terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

#########################################
# RDS Auto Start Lambda Function
#########################################
module "lambda_function_rds_auto_start" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = "${var.rds_auto_control_service_name}-lambda-fn-start"
  role          = var.iam_role_start_stop
  handler       = "start.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  source_code = {
    source_dir = "${path.module}/lambda-function-rds-auto-start"
  }

  vpc_config_security_group_ids = var.vpc_config_security_group_ids
  vpc_config_subnet_ids         = var.vpc_config_subnet_ids
  tags                          = var.tags
}

#########################################
# RDS Auto Stop Lambda Function
#########################################
module "lambda_function_rds_auto_stop" {
  source  = "app.terraform.io/pgetech/lambda/aws"
  version = "0.1.3"

  function_name = "${var.rds_auto_control_service_name}-lambda-fn-stop"
  role          = var.iam_role_start_stop
  handler       = "stop.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  source_code = {
    source_dir = "${path.module}/lambda-function-rds-auto-stop"
  }

  vpc_config_security_group_ids = var.vpc_config_security_group_ids
  vpc_config_subnet_ids         = var.vpc_config_subnet_ids
  tags                          = var.tags
}


#################################################
# EventBridge to trigger Lambda Function Start
#################################################

resource "aws_cloudwatch_event_rule" "schedule-start" {
  name                = "${var.rds_auto_control_service_name}-schedule-start"
  description         = "Schedule for Lambda Function"
  schedule_expression = var.schedule_rds_auto_start
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "schedule_lambda_start" {
  rule      = aws_cloudwatch_event_rule.schedule-start.name
  target_id = "processing_lambda"
  arn       = module.lambda_function_rds_auto_start.lambda_arn
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda_auto_start" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function_rds_auto_start.lambda_arn
  principal     = "events.amazonaws.com"
}

#################################################
# EventBridge to trigger Lambda Function Stop
#################################################

resource "aws_cloudwatch_event_rule" "schedule-stop" {
  name                = "${var.rds_auto_control_service_name}-schedule-stop"
  description         = "Schedule for Lambda Function"
  schedule_expression = var.schedule_rds_auto_stop
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "schedule_lambda_stop" {
  rule      = aws_cloudwatch_event_rule.schedule-stop.name
  target_id = "processing_lambda"
  arn       = module.lambda_function_rds_auto_stop.lambda_arn
}


resource "aws_lambda_permission" "allow_events_bridge_to_run_lambda_auto_stop" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function_rds_auto_stop.lambda_arn
  principal     = "events.amazonaws.com"
}