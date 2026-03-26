import json
import os
import boto3
from botocore.exceptions import ClientError
ssm_client = boto3.client('ssm')
ec2_client = boto3.client('ec2')
cfn_client = boto3.client('cloudformation')
dynamodb = boto3.resource('dynamodb')
def lambda_handler(event, context):
    print("Received event: " + json.dumps(event, indent=2))
    target_accounts_table = os.environ['TARGET_ACCOUNTS_TABLE']
    stackset_name = os.environ['STACKSET_ACCOUNT_SETUP']
    kms_alias = os.environ['KMS_ALIAS']
    encrypted_ami_store = os.environ['ENCRYPTED_AMI_STORE']
    beta_ami_store = os.environ['BETA_AMI_STORE']
    try:
        # Get the values from the event payload
        ami_id = event['AmiId']
        prev_ami_id = event['PrevAmiId']
        print ("Create an encrypted copy of the AMI " + ami_id)
        response = ec2_client.copy_image (
        Encrypted=True,
        KmsKeyId=kms_alias,
        Name='encrypted-copy-of-' + ami_id,
        SourceImageId=ami_id,
        SourceRegion='us-west-2'
        )
        encrypted_ami_id = response['ImageId']
        print ("encrypted_ami_id: " + encrypted_ami_id)
        response = ssm_client.put_parameter(
        Name=encrypted_ami_store,
        Value=encrypted_ami_id,
        Type='String',
        Overwrite=True
        )

        print ("Share beta AMI " + ami_id + " with all accounts listed in the dynamoDB table " + target_accounts_table )
        table = dynamodb.Table(target_accounts_table)
        response = table.scan()
        accounts = response['Items']
        non_prod_account_list=[]
        region_list=[]
        for account in accounts:
            if 'AccountStatus' in account:
                acct_status = account['AccountStatus']
            else:
                acct_status = 'ACTIVE'
            if acct_status == 'ACTIVE':
                acct_id = account['AccountId']
                if 'Environment' in account:
                    env = account['Environment']
                else:
                    env = '-'
                print (acct_id)
                ec2_client.modify_image_attribute(
                ImageId = ami_id,
                Attribute = 'LaunchPermission',
                OperationType = 'add',
                LaunchPermission = {
                    'Add' : [{ 'UserId': acct_id }]
                }
                )
                # check the first 4 chars of the environment.  If not production, append to the non_prod account list if exist in stackset
                if env[0:4].lower() != 'prod':
                    try:
                        response = cfn_client.describe_stack_instance(
                        StackSetName=stackset_name,
                        StackInstanceAccount=acct_id,
                        StackInstanceRegion='us-west-2'
                        )
                        non_prod_account_list.append(acct_id)
                    except ClientError as e:
                        if e.response['Error']['Code'] == 'StackInstanceNotFoundException':
                            print ('stackset instance ' + acct_id + ' not found')
                        else:
                            print (e)
        region_list.append('us-west-2')
        print ("update stackset " + stackset_name + " non-prod instances with new ami value " + ami_id )
        print("NonProd accounts: " + ", ".join(non_prod_account_list))
        response = cfn_client.update_stack_instances(
        StackSetName=stackset_name,
        Accounts=non_prod_account_list,
        Regions=region_list,
        ParameterOverrides=[
            { 'ParameterKey': 'pAmiId', 'ParameterValue': ami_id }, 
            { 'ParameterKey': 'pPreviousAmiId', 'ParameterValue': prev_ami_id }
        ],
        OperationPreferences={ 'FailureToleranceCount': 40, 'MaxConcurrentCount': 10 }
        )
        return { 'OperationId': response['OperationId'] }
    except Exception as e:
        print ("Distributor Lambda function failed")
        print(e)
        raise e