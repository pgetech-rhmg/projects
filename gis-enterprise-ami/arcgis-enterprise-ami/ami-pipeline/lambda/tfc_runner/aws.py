"""
AWS SDK wrapper for Secrets Manager, STS, EC2, and SSM operations
"""
import json
import boto3
from botocore.exceptions import ClientError


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


class EC2Client:
    """Wrapper for EC2 operations"""
    
    def __init__(self, session=None):
        self.client = session.client('ec2') if session else boto3.client('ec2')
    
    def run_instances(self, ami_id: str, instance_type: str, subnet_id: str,
                      security_group_id: str, iam_instance_profile: str,
                      tags: list[dict]) -> str:
        """Launch a single EC2 instance and return its instance ID"""
        try:
            response = self.client.run_instances(
                ImageId=ami_id,
                InstanceType=instance_type,
                MinCount=1,
                MaxCount=1,
                SubnetId=subnet_id,
                SecurityGroupIds=[security_group_id],
                IamInstanceProfile={'Arn': iam_instance_profile},
                TagSpecifications=[{
                    'ResourceType': 'instance',
                    'Tags': tags
                }]
            )
            return response['Instances'][0]['InstanceId']
        except ClientError as e:
            raise RuntimeError(f"Failed to launch instance with AMI {ami_id}: {e}") from e


class SSMClient:
    """Wrapper for SSM Parameter Store operations"""
    
    def __init__(self, session=None):
        self.client = session.client('ssm') if session else boto3.client('ssm')
    
    def put_parameter(self, name: str, value: str, description: str = "",
                      overwrite: bool = True) -> int:
        """Put a parameter and return its version"""
        try:
            response = self.client.put_parameter(
                Name=name,
                Value=value,
                Type='String',
                Description=description,
                Overwrite=overwrite
            )
            return response['Version']
        except ClientError as e:
            raise RuntimeError(f"Failed to put parameter {name}: {e}") from e
