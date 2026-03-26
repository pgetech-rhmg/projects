import json
import boto3
import os

def lambda_handler(event, context):
    # Parameters
    sns = boto3.client('sns')
    #reading environment variables
    Environment = os.environ['environment']
    aws_region = os.environ['aws_region']
    Topic_Arn = os.environ['Topic_Arn']

    contents = json.loads(event['Records'][0]['Sns']['Message'])
    print(contents)
    if  contents['detail']['state'] != "SUCCEEDED": 
        message = "Application Name: {0}\nPipeline Build Status: {1}\nExecution ID: {2}\nDescription:\n\tPhase Type: {3}\n\tPhase Status: {4}\n\tPhase Context: {5}\n ".format(
            contents['detail']['pipeline'],
            contents['detail']['state'],
            contents['detail']['execution-id'],
            contents['additionalAttributes']['failedStage'],
            contents['detail']['state'],
            contents['additionalAttributes']['failedActions'][0]['additionalInformation']
        )
        print(message)
    else:
        message = "Application Name: {0}\nPipeline Build Status: {1}\nExecution ID: {2}\n ".format(
            contents['detail']['pipeline'],
            contents['detail']['state'],
            contents['detail']['execution-id']
        )
        print(message)

    url= "https://{0}.console.aws.amazon.com/codesuite/codepipeline/pipelines/".format(aws_region) + contents['detail']['pipeline'] + "/view?region={0}".format(aws_region)
    print(url)
    emailmessage = message + url
    revert = sns.publish(
        TopicArn=Topic_Arn,
        Message=str(emailmessage),
        Subject= Environment+" - "+contents['detail']['pipeline']+"  Pipeline Status is "+contents['detail']['state'],
        MessageStructure='str'
    )
    print(revert)
    return {
     "result": revert,
        "StatusCode": 200
    }
