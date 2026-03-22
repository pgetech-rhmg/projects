"""
AWS SDK wrapper for SSM operations
"""
import boto3
from botocore.exceptions import ClientError


class SSMClient:
    """Wrapper for SSM operations"""
    
    def __init__(self, session=None):
        self.client = session.client('ssm') if session else boto3.client('ssm')
    
    def get_parameter_history(self, name):
        """Get parameter history to find version with LATEST label"""
        try:
            response = self.client.get_parameter_history(
                Name=name,
                WithDecryption=False
            )
            return response['Parameters']
        except ClientError as e:
            print(f"Error getting parameter history for {name}: {e}")
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
