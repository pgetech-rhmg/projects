{
  "Comment": "AMI Factory Build Pipeline",
  "StartAt": "BuildAMIs",
  "States": {
    "BuildAMIs": {
      "Type": "Map",
      "ItemsPath": "$.components",
      "MaxConcurrency": 4,
      "ItemProcessor": {
        "ProcessorConfig": {
          "Mode": "INLINE"
        },
        "StartAt": "ConstructPipelineArn",
        "States": {
          "ConstructPipelineArn": {
            "Type": "Pass",
            "Parameters": {
              "component.$": "$",
              "pipeline_arn.$": "States.Format('arn:aws:imagebuilder:${aws_region}:${account_id}:image-pipeline/ami-factory-{}-${environment}', $)"
            },
            "Next": "StartImagePipeline"
          },
          "StartImagePipeline": {
            "Type": "Task",
            "Resource": "arn:aws:states:::aws-sdk:imagebuilder:startImagePipelineExecution",
            "Parameters": {
              "ImagePipelineArn.$": "$.pipeline_arn",
              "ClientToken.$": "States.UUID()"
            },
            "ResultPath": "$.execution",
            "Next": "WaitForBuild"
          },
          "WaitForBuild": {
            "Type": "Wait",
            "Seconds": 60,
            "Next": "CheckBuildStatus"
          },
          "CheckBuildStatus": {
            "Type": "Task",
            "Resource": "arn:aws:states:::aws-sdk:imagebuilder:getImage",
            "Parameters": {
              "ImageBuildVersionArn.$": "$.execution.ImageBuildVersionArn"
            },
            "ResultPath": "$.build_status",
            "Next": "IsBuildComplete"
          },
          "IsBuildComplete": {
            "Type": "Choice",
            "Choices": [
              {
                "Variable": "$.build_status.Image.State.Status",
                "StringEquals": "AVAILABLE",
                "Next": "BuildSuccess"
              },
              {
                "Variable": "$.build_status.Image.State.Status",
                "StringEquals": "FAILED",
                "Next": "BuildFailed"
              }
            ],
            "Default": "WaitForBuild"
          },
          "BuildSuccess": {
            "Type": "Pass",
            "Parameters": {
              "component.$": "$.component",
              "ami_id.$": "$.build_status.Image.OutputResources.Amis[0].Image",
              "ami_name.$": "$.build_status.Image.OutputResources.Amis[0].Name",
              "region.$": "$.build_status.Image.OutputResources.Amis[0].Region"
            },
            "End": true
          },
          "BuildFailed": {
            "Type": "Fail",
            "Error": "BuildFailed",
            "Cause": "Image build failed"
          }
        }
      },
      "ResultPath": "$.build_results",
      "Next": "WriteAMIsToSSM"
    },
    "WriteAMIsToSSM": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${ami_writer_lambda_arn}",
        "Payload": {
          "ami_builds.$": "$.build_results"
        }
      },
      "ResultPath": "$.ami_write_result",
      "Next": "DeleteSandboxStateParameter"
    },
    "DeleteSandboxStateParameter": {
      "Type": "Task",
      "Resource": "arn:aws:states:::aws-sdk:ssm:deleteParameter",
      "Parameters": {
        "Name": "/ami_factory/sandbox_state"
      },
      "ResultPath": null,
      "Catch": [
        {
          "ErrorEquals": ["Ssm.ParameterNotFoundException"],
          "ResultPath": "$.delete_error",
          "Next": "RunTerraformCloud"
        }
      ],
      "Next": "RunTerraformCloud"
    },
    "RunTerraformCloud": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${tfc_runner_lambda_arn}",
        "Payload": {
          "workspace_path": "${tfc_workspace_path}",
          "ami_builds.$": "$.build_results"
        }
      },
      "ResultPath": "$.tfc_result",
      "Next": "WaitForConfigReady"
    },
    "WaitForConfigReady": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${config_manager_lambda_arn}",
        "Payload": {
          "action": "is_config_apply_ready",
          "run_id.$": "$.tfc_result.Payload.run_id"
        }
      },
      "ResultPath": "$.ready_check",
      "Next": "IsConfigReady"
    },
    "IsConfigReady": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.ready_check.Payload.ready",
          "BooleanEquals": true,
          "Next": "RunConfigDoc"
        }
      ],
      "Default": "WaitBeforeRetryReady"
    },
    "WaitBeforeRetryReady": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "WaitForConfigReady"
    },
    "RunConfigDoc": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${config_manager_lambda_arn}",
        "Payload": {
          "action": "run_doc",
          "doc_name_prefix": "ConfigDoc"
        }
      },
      "ResultPath": "$.config_run",
      "Next": "WaitForConfigComplete"
    },
    "WaitForConfigComplete": {
      "Type": "Wait",
      "Seconds": 30,
      "Next": "CheckConfigStatus"
    },
    "CheckConfigStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${config_manager_lambda_arn}",
        "Payload": {
          "action": "get_command_status",
          "doc_name_prefix": "ConfigDoc"
        }
      },
      "ResultPath": "$.config_status",
      "Next": "IsConfigComplete"
    },
    "IsConfigComplete": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.config_status.Payload.all_complete",
          "BooleanEquals": true,
          "Next": "CheckConfigSuccess"
        }
      ],
      "Default": "WaitBeforeRetryConfig"
    },
    "CheckConfigSuccess": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.config_status.Payload.all_success",
          "BooleanEquals": false,
          "Next": "ConfigFailed"
        }
      ],
      "Default": "RunTestDoc"
    },
    "WaitBeforeRetryConfig": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "CheckConfigStatus"
    },
    "ConfigFailed": {
      "Type": "Fail",
      "Error": "ConfigFailed",
      "Cause": "Configuration apply failed"
    },
    "RunTestDoc": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${config_manager_lambda_arn}",
        "Payload": {
          "action": "run_doc",
          "doc_name_prefix": "TestDoc"
        }
      },
      "ResultPath": "$.test_run",
      "Next": "WaitForTestComplete"
    },
    "WaitForTestComplete": {
      "Type": "Wait",
      "Seconds": 30,
      "Next": "CheckTestStatus"
    },
    "CheckTestStatus": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "${config_manager_lambda_arn}",
        "Payload": {
          "action": "get_command_status",
          "doc_name_prefix": "TestDoc"
        }
      },
      "ResultPath": "$.test_status",
      "Next": "IsTestComplete"
    },
    "IsTestComplete": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.test_status.Payload.all_complete",
          "BooleanEquals": true,
          "Next": "CheckTestSuccess"
        }
      ],
      "Default": "WaitBeforeRetryTest"
    },
    "CheckTestSuccess": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.test_status.Payload.all_success",
          "BooleanEquals": false,
          "Next": "TestFailed"
        }
      ],
      "Default": "PipelineSuccess"
    },
    "WaitBeforeRetryTest": {
      "Type": "Wait",
      "Seconds": 120,
      "Next": "CheckTestStatus"
    },
    "TestFailed": {
      "Type": "Fail",
      "Error": "TestFailed",
      "Cause": "Testing failed"
    },
    "PipelineSuccess": {
      "Type": "Succeed"
    }
  }
}