{
    "schemaVersion": "0.3",
    "description": "SSM Automation Document to update a parameter in Parameter store",
    "assumeRole":"${AutomationAssumeRole}",
    "mainSteps":[
        {
            "name": "GetBetaAmiId",
            "action": "aws:executeAwsApi",
            "timeoutSeconds": 60,
            "onFailure": "Abort",
            "inputs":{
                "Service": "ssm",
                "Api": "GetParameter",
                "Name": "${beta_ami_parameter_store}",
                "WithDecryption": true
            },
            "outputs":[
                {
                    "Name": "BetaAmiId",
                    "Selector": "$.Parameter.Value",
                    "Type": "String"
                }
            ]
        },
        {
            "name": "checkBetaAmiId",
            "action":"aws:branch",
            "inputs":{
                "Choices":[
                    {
                        "Variable": "{{ GetBetaAmiId.BetaAmiId }}",
                        "StartsWith": "ami-",
                        "NextStep": "AmiApprovalStep"
                    }
                ],
                "Default": "BetaAmiNotFound"
                
            },
            "isEnd": true
        },
        {
            "name": "BetaAmiNotFound",
            "action": "aws:sleep",
            "inputs":{
                "Duration": "PT1S"
            },
            "isEnd": true
        },
            {
                "name": "AmiApprovalStep",
                "action":"aws:approve",
                "onFailure": "Abort",
                "inputs":{
                    "NotificationArn": "${approver_topic_arn}",
                    "Message": "PG&E Golden Linux AMI {{ GetBetaAmiId.BetaAmiId }} NonProd release approval requested",
                    "MinRequiredApprovals":1,
                    "Approvers": ${approver_arns}
                }
            },
            {
                 "name": "GetcurrentAmiId",
            "action": "aws:executeAwsApi",
            "timeoutSeconds": 60,
            "onFailure": "Abort",
            "inputs":{
                "Service": "ssm",
                "Api": "GetParameter",
                "Name": "${prev_ami_parameter_store}",
                "WithDecryption": true
            },
                  "outputs":[
        {
                        "Name": "CurrentAmiId",
                        "Selector": "$.Parameter.Value",
                        "Type": "String"
        }
                    ]

        },
        {
            "name": "UpdateStackSetWithNewAmi",
            "action":"aws:invokeLambdaFunction",
            "maxAttempts":3,
            "onFailure":"Abort",
            "inputs":{
                "FunctionName": "${update_stackset_function_name}",
                    "Payload":"{\"AmiId\": \"{{ GetBetaAmiId.BetaAmiId }}\" , \"PrevAmiId\": \"{{ GetcurrentAmiId.CurrentAmiId }}\"}"
                },
                "outputs":[
        {
                        "Name": "OperationId",
                        "Selector": "$.OperationId",
                        "Type": "String"
        }
                    ]
            },
        {
            "name": "WaitUntilStackSetFinished",
            "action": "aws:waitForAwsResourceProperty",
            "timeoutSeconds": 1200,
            "inputs":{
                "Service": "cloudformation",
                "Api": "DescribeStackSetOperation",
                "StackSetName": "${stack_set_name}",
                "OperationId": "{{UpdateStackSetWithNewAmi.OperationId}}",
                "PropertySelector": "StackSetOperation.Status",
                "DesiredValues":["SUCCEEDED"
                ]
            }
        },
        {
            "name": "EmailNotification",
            "action": "aws:executeScript",
            "onFailure": "Abort",
            "inputs":{
                "Runtime": "python3.8",
                "Handler": "email_notification_prod",
                "InputPayload":{
                    "ami_parameter_store": "${ami_parameter_store}",
                    "beta_ami_id": "{{ GetBetaAmiId.BetaAmiId }}",
                    "sender": "${sender}",
                    "recipient": "${recipient}",
                    "environment": "${environment}"
                    
                },
                "Script": "${email_notification_script}"
            }
        },
        {
            "name": "UpdatenonProdAMIId",
            "action": "aws:executeAwsApi",
            "timeoutSeconds": 60,
            "onFailure": "Abort",
            "inputs":{
                "Service": "ssm",
                "Api": "PutParameter",
                "Name": "${nonprod_ami_parameter_store}",
                "Value": "{{ GetBetaAmiId.BetaAmiId }}",
                "Overwrite": true
        }
        }
    ]
}

      