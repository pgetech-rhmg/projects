"""
Lambda function to write AMI IDs to SSM parameters with LATEST label
"""
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws import SSMClient

logger = Logger()
tracer = Tracer()


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event: dict, context: LambdaContext) -> dict:
    """
    Writes AMI IDs to SSM parameters and applies LATEST label
    
    Expected event format:
    {
        "ami_builds": [
            {"component": "webadapter", "ami_id": "ami-12345"},
            {"component": "portal", "ami_id": "ami-67890"}
        ]
    }
    """
    ssm_client = SSMClient()
    results = []
    
    ami_builds = event.get('ami_builds', [])
    logger.info("Processing AMI builds", ami_build_count=len(ami_builds))
    
    for build in ami_builds:
        component = build.get('component')
        ami_id = build.get('ami_id')
        
        if not component or not ami_id:
            logger.warning("Skipping build with missing component or ami_id", build=build)
            continue
        
        parameter_name = f"/ami_factory/{component}/ami"
        
        logger.info("Writing AMI to SSM", 
                   component=component, 
                   ami_id=ami_id, 
                   parameter_name=parameter_name)
        
        # Put parameter
        version = ssm_client.put_parameter(
            name=parameter_name,
            value=ami_id,
            description=f"AMI ID for {component}",
            overwrite=True
        )
        
        logger.info("Parameter written", version=version)
        
        # Apply LATEST label
        ssm_client.label_parameter_version(
            name=parameter_name,
            version=version,
            labels=["LATEST"]
        )
        
        logger.info("Applied LATEST label", version=version)
        
        results.append({
            "component": component,
            "ami_id": ami_id,
            "parameter_name": parameter_name,
            "version": version
        })
    
    logger.info("Successfully processed all AMI builds", result_count=len(results))
    
    return {
        "statusCode": 200,
        "results": results
    }
