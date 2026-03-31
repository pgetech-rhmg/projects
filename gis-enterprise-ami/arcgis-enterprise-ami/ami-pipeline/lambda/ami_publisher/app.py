"""
Lambda function to publish AMIs by applying environment label to LATEST version
"""
import os
import boto3
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws import SSMClient

logger = Logger()
tracer = Tracer()
codepipeline = boto3.client('codepipeline')


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event: dict, context: LambdaContext) -> dict:
    """
    Publish AMIs by applying environment label to LATEST version
    
    Expected event format from CodePipeline:
    {
        "CodePipeline.job": {
            "id": "job-id",
            "data": {
                "actionConfiguration": {
                    "configuration": {
                        "UserParameters": "{\"components\": [\"webadapter\", \"portal\", \"datastore\", \"server\"]}"
                    }
                }
            }
        }
    }
    """
    env_name = os.environ['ENVIRONMENT_NAME']
    
    # Extract job ID if invoked by CodePipeline
    job_id = None
    user_parameters = {}
    
    if 'CodePipeline.job' in event:
        job_id = event['CodePipeline.job']['id']
        job_data = event['CodePipeline.job']['data']
        
        # Parse user parameters if provided
        import json
        user_params_str = job_data.get('actionConfiguration', {}).get('configuration', {}).get('UserParameters', '{}')
        try:
            user_parameters = json.loads(user_params_str)
        except json.JSONDecodeError:
            logger.warning("Failed to parse UserParameters", user_params=user_params_str)
    
    components = user_parameters.get('components', event.get('components', ['webadapter', 'portal', 'datastore', 'server']))
    
    logger.info("Publishing AMIs", environment=env_name, component_count=len(components), job_id=job_id)
    
    try:
        ssm_client = SSMClient()
        results = []
        
        for component in components:
            parameter_name = f"/ami_factory/{component}/ami"
            
            logger.info("Processing component", component=component, parameter_name=parameter_name)
            
            # Get parameter history to find LATEST version
            history = ssm_client.get_parameter_history(parameter_name)
            
            latest_version = None
            for param in history:
                if 'Labels' in param and 'LATEST' in param['Labels']:
                    latest_version = param['Version']
                    ami_id = param['Value']
                    break
            
            if not latest_version:
                logger.warning("No LATEST version found", parameter_name=parameter_name)
                continue
            
            logger.info("Found LATEST version", 
                       version=latest_version, 
                       ami_id=ami_id)
            
            # Apply environment label to the same version
            ssm_client.label_parameter_version(
                name=parameter_name,
                version=latest_version,
                labels=[env_name]
            )
            
            logger.info("Applied environment label", 
                       label=env_name, 
                       version=latest_version)
            
            results.append({
                'component': component,
                'parameter_name': parameter_name,
                'version': latest_version,
                'ami_id': ami_id,
                'label': env_name
            })
        
        logger.info("Successfully published AMIs", result_count=len(results))
        
        response = {
            'statusCode': 200,
            'results': results
        }
        
        # Notify CodePipeline of success if job_id exists
        if job_id:
            codepipeline.put_job_success_result(jobId=job_id)
            logger.info("Notified CodePipeline of success", job_id=job_id)
        
        return response
        
    except Exception as e:
        logger.exception("Failed to publish AMIs", error=str(e))
        
        # Notify CodePipeline of failure if job_id exists
        if job_id:
            codepipeline.put_job_failure_result(
                jobId=job_id,
                failureDetails={
                    'type': 'JobFailed',
                    'message': str(e)
                }
            )
            logger.info("Notified CodePipeline of failure", job_id=job_id)
        
        raise
