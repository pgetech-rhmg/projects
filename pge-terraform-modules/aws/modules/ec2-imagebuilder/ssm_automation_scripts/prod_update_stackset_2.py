
import boto3 
from botocore.exceptions import ClientError
cfn_client = boto3.client('cloudformation')
def remove_param_overrides(event, context):
    try:
       stackset_name = event['stackset_name']
       overrides_account_list = []
       overrides_region_list = []
       response = cfn_client.list_stack_instances( StackSetName=stackset_name )
       for stack_instance in response['Summaries']:
        account_id = stack_instance['Account']
        region = stack_instance['Region']
        response = cfn_client.describe_stack_instance(
            StackSetName=stackset_name,
            StackInstanceAccount=account_id,
            StackInstanceRegion=region
                        ) 
        # check to see if parameter overrides has value for this stackset instance
        param_overrides = response['StackInstance']['ParameterOverrides'] 
        if param_overrides:
         if ( account_id not in overrides_account_list ):
          overrides_account_list.append(account_id)
        if ( region not in overrides_region_list ):
          overrides_region_list.append(region)
        # remove parameter overrides for the listed accounts
        if overrides_account_list:
            response = cfn_client.update_stack_instances(
            StackSetName=stackset_name,
            Accounts=overrides_account_list,
            Regions=overrides_region_list,
            ParameterOverrides=[],
            OperationPreferences={ 'FailureToleranceCount': 4, 'MaxConcurrentCount': 40 }
            )
        return { 'OverridesAccounts': ", ".join(overrides_account_list)}
    except ClientError as e:
            print(e.response['Error']['Message'])
            raise e
            