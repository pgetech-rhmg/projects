"""
AWS SDK wrapper for SSM and EC2 operations
"""
import boto3
from botocore.exceptions import ClientError


class SSMClient:
    """Wrapper for SSM operations"""
    
    def __init__(self, session=None):
        self.client = session.client('ssm') if session else boto3.client('ssm')
    
    def get_parameter(self, name):
        """Get parameter value from SSM"""
        try:
            response = self.client.get_parameter(Name=name)
            return response['Parameter']['Value']
        except ClientError as e:
            print(f"Error getting parameter {name}: {e}")
            raise
    
    def send_command(self, instance_ids, document_name, parameters=None):
        """Send SSM command to instances"""
        try:
            kwargs = {
                'InstanceIds': instance_ids,
                'DocumentName': document_name
            }
            if parameters:
                kwargs['Parameters'] = parameters
            
            response = self.client.send_command(**kwargs)
            return response['Command']['CommandId']
        except ClientError as e:
            print(f"Error sending command {document_name}: {e}")
            raise
    
    def get_command_invocation_status(self, instance_id, document_name):
        """Get status of most recent command invocation"""
        try:
            # List recent command invocations for this instance and document
            response = self.client.list_command_invocations(
                InstanceId=instance_id,
                Filters=[
                    {
                        'key': 'DocumentName',
                        'value': document_name
                    }
                ],
                MaxResults=1
            )
            
            if not response['CommandInvocations']:
                return {'Status': 'NotFound'}
            
            invocation = response['CommandInvocations'][0]
            return {
                'Status': invocation['Status'],
                'CommandId': invocation['CommandId']
            }
        except ClientError as e:
            print(f"Error getting command status for {instance_id}: {e}")
            raise


class EC2Client:
    """Wrapper for EC2 operations"""
    
    def __init__(self, session=None):
        self.client = session.client('ec2') if session else boto3.client('ec2')
    
    def describe_instances(self, Filters=None):
        """Wrapper for boto3 describe_instances [MISSING METHOD ADDED]"""
        try:
            return self.client.describe_instances(Filters=Filters or [])
        except ClientError as e:
            print(f"Error describing instances: {e}")
            raise

    def describe_instance_status(self, instance_ids):
        """Get instance status for given instance IDs"""
        try:
            ids = [instance_ids] if isinstance(instance_ids, str) else instance_ids
            
            response = self.client.describe_instance_status(
                InstanceIds=ids,
                IncludeAllInstances=True
            )
            return response['InstanceStatuses']
        except ClientError as e:
            print(f"Error describing instance status: {e}")
            raise

class SecretsManagerClient:
    """Wrapper for Secrets Manager operations"""
    
    def __init__(self, session=None):
        self.client = session.client('secretsmanager') if session else boto3.client('secretsmanager')
    
    def get_secret(self, secret_id: str) -> str:
        """Get secret value from Secrets Manager"""
        try:
            response = self.client.get_secret_value(SecretId=secret_id)
            if 'SecretString' in response:
                return response['SecretString']
            else:
                return response['SecretBinary']
        except ClientError as e:
            raise RuntimeError(f"Failed to get secret {secret_id}: {e}") from e


class STSClient:
    """Wrapper for STS operations"""
    
    def __init__(self, session=None):
        self.client = session.client('sts') if session else boto3.client('sts')
    
    def assume_role(self, role_arn: str, session_name: str) -> dict:
        """Assume an IAM role and return credentials"""
        try:
            response = self.client.assume_role(
                RoleArn=role_arn,
                RoleSessionName=session_name
            )
            return response['Credentials']
        except ClientError as e:
            raise RuntimeError(f"Failed to assume role {role_arn}: {e}") from e
    
    def get_session_with_assumed_role(self, role_arn: str, session_name: str) -> boto3.Session:
        """Assume a role and return a boto3 session with the assumed credentials"""
        credentials = self.assume_role(role_arn, session_name)
        return boto3.Session(
            aws_access_key_id=credentials['AccessKeyId'],
            aws_secret_access_key=credentials['SecretAccessKey'],
            aws_session_token=credentials['SessionToken']
        )
