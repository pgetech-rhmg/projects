
import boto3 
from botocore.exceptions import ClientError
cfn_client = boto3.client('cloudformation')
def update_stackset(event, context):   
    try:
       stackset_name = event['stackset_name']
       golden_ami_id = event['beta_ami_id']
       prev_ami_id = event['current_ami_id']
       print ("update stackset " + stackset_name + " with golden AMI ID " + golden_ami_id)
       response = cfn_client.update_stack_set(
        StackSetName=stackset_name,
        UsePreviousTemplate=True,
        Capabilities=['CAPABILITY_NAMED_IAM'],
        Parameters=[{ 'ParameterKey': 'pAmiId', 'ParameterValue': golden_ami_id },
        { 'ParameterKey': 'pPreviousAmiId', 'ParameterValue': prev_ami_id }
        ],
        OperationPreferences={ 'FailureToleranceCount': 40, 'MaxConcurrentCount': 4 }
        )
       return { 'OperationId': response['OperationId'] }
    except ClientError as e:
        print(e.response['Error']['Message'])
        raise e