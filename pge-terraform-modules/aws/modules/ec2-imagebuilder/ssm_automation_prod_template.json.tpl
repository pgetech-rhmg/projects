{
  "schemaVersion": "0.3",
  "description": "Update the parameter store of the golden AMI for all accounts",
  "assumeRole": "${AutomationAssumeRole}",
  "mainSteps": [
    {
      "outputs": [
        {
          "Type": "String",
          "Name": "NonProdAmiId",
          "Selector": "$.Parameter.Value"
        }
      ],
      "inputs": {
        "Service": "ssm",
        "Api": "GetParameter",
        "WithDecryption": true,
        "Name": "${nonprod_ami_parameter_store}"
      },
      "name": "GetNonProdAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60,
      "onFailure": "Abort"
    },
    {
      "inputs": {
        "Choices": [
          {
            "Variable": "{{ GetNonProdAmiId.NonProdAmiId }}",
            "StartsWith": "ami-",
            "NextStep": "AmiApprovalStep"
          }
        ],
        "Default": "NonProdAmiNotReleased"
      },
      "name": "CheckNonProdAmiId",
      "action": "aws:branch",
      "isEnd": true
    },
    {
      "inputs": {
        "Duration": "PT1S"
      },
      "name": "NonProdAmiNotReleased",
      "action": "aws:sleep",
      "isEnd": true
    },
    {
      "inputs": {
        "Message": "PG&E Golden Linux AMI {{ GetNonProdAmiId.NonProdAmiId }} Production release approval requested",
        "NotificationArn": "${approver_topic_arn}",
        "MinRequiredApprovals": 1,
        "Approvers": ${approver_arns}
        
      },
      "name": "AmiApprovalStep",
      "action": "aws:approve",
      "onFailure": "Abort"
    },
    {
      "outputs": [
        {
          "Type": "String",
          "Name": "CurrentAmiId",
          "Selector": "$.Parameter.Value"
        }
      ],
      "inputs": {
        "Service": "ssm",
        "Api": "GetParameter",
        "WithDecryption": true,
        "Name": "${ami_parameter_store}"
      },
      "name": "GetCurrentAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60,
      "onFailure": "Abort"
    },
    {
      "outputs": [
        {
          "Type": "StringMap",
          "Name": "Payload",
          "Selector": "$.Payload"
        },
        {
          "Type": "String",
          "Name": "OperationId",
          "Selector": "$.Payload.OperationId"
        }
      ],
      "inputs": {
        "Script": "${prod_update_stackset_script_1}",
        "Runtime": "python3.7",
        "InputPayload": {
          "stackset_name": "${stack_set_name}",
          "current_ami_id": "{{ GetCurrentAmiId.CurrentAmiId }}",
          "beta_ami_id": "{{ GetNonProdAmiId.NonProdAmiId }}"
        },
        "Handler": "update_stackset"
      },
      "name": "UpdateStackSetWithNewAmi",
      "action": "aws:executeScript",
      "onFailure": "Abort"
    },
    {
      "inputs": {
        "PropertySelector": "$.StackSetOperation.Status",
        "DesiredValues": [
          "SUCCEEDED"
        ],
        "OperationId": "{{ UpdateStackSetWithNewAmi.OperationId }}",
        "Service": "cloudformation",
        "Api": "DescribeStackSetOperation",
        "StackSetName": "${stack_set_name}"
      },
      "name": "WaitUntilStackSetFinished",
      "action": "aws:waitForAwsResourceProperty",
      "timeoutSeconds": 1200
    },
    {
      "outputs": [
        {
          "Type": "StringMap",
          "Name": "Payload",
          "Selector": "$.Payload"
        },
        {
          "Type": "String",
          "Name": "OverridesAccounts",
          "Selector": "$.Payload.OverridesAccounts"
        }
      ],
      "inputs": {
        "Script": "${prod_update_stackset_script_2}",
        "Runtime": "python3.7",
        "InputPayload": {
          "stackset_name": "${stack_set_name}"
        },
        "Handler": "remove_param_overrides"
      },
      "name": "RemoveInstanceParamOverrides",
      "action": "aws:executeScript",
      "onFailure": "Abort"
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "{{ GetCurrentAmiId.CurrentAmiId }}",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${prev_ami_parameter_store}"
      },
      "name": "UpdatePrevAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "{{ GetNonProdAmiId.NonProdAmiId }}",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${ami_parameter_store}"
      },
      "name": "UpdateGoldenAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "outputs": [
        {
          "Type": "String",
          "Name": "BetaEncryptedAmiId",
          "Selector": "$.Parameter.Value"
        }
      ],
      "inputs": {
        "Service": "ssm",
        "Api": "GetParameter",
        "WithDecryption": true,
        "Name": "${encrypted_beta_ami_parameter_store}"
      },
      "name": "GetBetaEncryptedAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60,
      "onFailure": "Abort"
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "{{ GetBetaEncryptedAmiId.BetaEncryptedAmiId }}",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${encrypted_ami_parameter_store}"
      },
      "name": "UpdateGoldenEncryptedAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "none",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${beta_ami_parameter_store}"
      },
      "name": "UpdateBetaAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "none",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${nonprod_ami_parameter_store}"
      },
      "name": "UpdateNonProdAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "inputs": {
        "Overwrite": true,
        "Value": "none",
        "Service": "ssm",
        "Api": "PutParameter",
        "Name": "${encrypted_beta_ami_parameter_store}"
      },
      "name": "UpdateBetaEncryptedAmiId",
      "action": "aws:executeAwsApi",
      "timeoutSeconds": 60
    },
    {
      "inputs": {
        "Script": "${prod_update_stackset_script_3}",
        "Runtime": "python3.7",
        "InputPayload": {
          "ami_parameter_store": "${ami_parameter_store}",
          "beta_ami_id": "{{ GetNonProdAmiId.NonProdAmiId }}"
        },
        "Handler": "email_notification_prod"
      },
      "name": "PublishSnsProd",
      "action": "aws:executeScript",
      "onFailure": "Abort"
    }
  ]
}