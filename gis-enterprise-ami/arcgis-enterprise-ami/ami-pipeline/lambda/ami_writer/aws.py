"""
AWS SDK wrapper for SSM operations
"""
import boto3
from botocore.exceptions import ClientError


class SSMClient:
    """Wrapper for SSM operations with error handling"""
    
    def __init__(self, session=None):
        self.client = session.client('ssm') if session else boto3.client('ssm')
    
    def put_parameter(self, name, value, description, overwrite=True):
        """
        Put a parameter in SSM Parameter Store
        
        Returns: parameter version number
        """
        try:
            response = self.client.put_parameter(
                Name=name,
                Value=value,
                Description=description,
                Type='String',
                Overwrite=overwrite
            )
            return response['Version']
        except ClientError as e:
            print(f"Error putting parameter {name}: {e}")
            raise
    
    def label_parameter_version(self, name, version, labels):
        """
        Apply labels to a parameter version
        SSM automatically moves labels from other versions when applied
        """
        try:
            self.client.label_parameter_version(
                Name=name,
                ParameterVersion=version,
                Labels=labels
            )
        except ClientError as e:
            print(f"Error labeling parameter {name} version {version}: {e}")
            raise
