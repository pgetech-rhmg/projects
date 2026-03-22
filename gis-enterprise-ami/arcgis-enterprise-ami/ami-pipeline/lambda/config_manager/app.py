"""
Lambda function to manage configuration deployment and testing
"""
import json
import os
import requests
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws import SSMClient, EC2Client, SecretsManagerClient, STSClient

logger = Logger()
tracer = Tracer()


@tracer.capture_method
def get_instance_info(ec2_client: EC2Client) -> list:
    """Get instance info from Environment """

    machine_configs = [
        {"env_var": "WEBADAPTER_NAME_TAG", "role_key": "WebAdaptorRole", "comp": "arcgiswebadaptor"},
        {"env_var": "SERVER_NAME_TAG",      "role_key": "ServerRole", "comp": "arcgisserver"},
        {"env_var": "DATASTORE_NAME_TAG",   "role_key": "DatastoreRole", "comp": "arcgisdatastore"},
        {"env_var": "PORTAL_NAME_TAG",      "role_key": "PortalRole",  "comp": "arcgisportal"}
    ] 

    found_instances = []

    for config in machine_configs:
        machine_name = os.environ.get(config["env_var"])
        
        if not machine_name:
            return {"success": False, "error": f"Env var {config['env_var']} is missing"}

        filters = [
            {'Name': 'tag:Name', 'Values': [machine_name]},
            {'Name': f'tag:{config["role_key"]}', 'Values': ['Primary']},
            {'Name': 'tag:SoftwareComponent', 'Values': [config["comp"]]},
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]

        response = ec2_client.describe_instances(Filters=filters) 
        
        reservations = response.get('Reservations', [])
        if reservations and reservations[0].get('Instances'):
            instance_id = reservations[0]['Instances'][0]['InstanceId']
            logger.info("Found instance for component", component=config["comp"], instance_id=instance_id)
            # Return a dict so run_doc and get_command_status can find the 'component'
            found_instances.append({
                'instance_id': instance_id,
                'component': config['comp']
            })
        else:
            raise RuntimeError(f"No running instance found for {machine_name}")
        
    return found_instances

@tracer.capture_method
def is_config_apply_ready(ssm_client: SSMClient, ec2_client: EC2Client, tfc_url: str, run_id: str, token: str, dry_run: bool) -> bool:
    """
    Check if configuration apply is ready
    - All instances have OK status
    - Terraform Cloud run is complete and successful
    """
    # Check TFC run status first
    # Skip TFC check if it's a dry run
    if not dry_run:
        try:
            tfc_status = check_tfc_run_status(tfc_url, run_id, token)
            if not tfc_status['is_complete']:
                logger.info("TFC run not yet complete", status=tfc_status['status'])
                return False
            if not tfc_status['is_success']:
                logger.error("TFC run failed", status=tfc_status['status'])
                raise RuntimeError(f"Terraform Cloud run failed with status: {tfc_status['status']}")
        except Exception as e:
            if isinstance(e, RuntimeError): raise # Re-raise our specific failure
            logger.warning("Failed to check TFC run status", error=str(e))
            raise RuntimeError(f"Failed to check TFC run status: {str(e)}")
    else:
        logger.info("Dry run enabled: skipping TFC status check")
    
    # Check instances
    try:
        instance_info = get_instance_info(ec2_client)
        instance_ids = [inst['instance_id'] for inst in instance_info]
    except Exception as e:
        logger.warning("Instances not found or invalid", error=str(e))
        return False
    
    if not instance_ids:
        logger.warning("No instances found in sandbox state")
        return False
    
    logger.info("Checking instance status", instance_count=len(instance_ids))
    
    # Check instance status
    statuses = ec2_client.describe_instance_status(instance_ids)
    
    for status in statuses:
        instance_id = status['InstanceId']
        instance_state = status.get('InstanceState', {}).get('Name', 'unknown')
        instance_status = status.get('InstanceStatus', {}).get('Status')
        system_status = status.get('SystemStatus', {}).get('Status')
        
        logger.info("Instance status check", 
                   instance_id=instance_id,
                   instance_state=instance_state,
                   instance_status=instance_status,
                   system_status=system_status)
        
        if instance_state in ('terminated', 'shutting-down'):
            raise RuntimeError(
                f"Instance {instance_id} is {instance_state}. "
                "Cannot proceed with configuration."
            )
        
        if instance_status != 'ok' or system_status != 'ok':
            return False
    
    return True


@tracer.capture_method
def run_doc(ssm_client: SSMClient, ec2_client: EC2Client, doc_name_prefix: str) -> list:
    """Run SSM document against instances"""
    instance_info = get_instance_info(ec2_client)
    
    command_ids = []
    
    for info in instance_info:
        instance_id = info['instance_id']
        component = info['component']
        doc_name = f"{doc_name_prefix}-{component}"
        
        logger.info("Running SSM document", 
                   doc_name=doc_name,
                   instance_id=instance_id,
                   component=component)
        
        command_id = ssm_client.send_command(
            instance_ids=[instance_id],
            document_name=doc_name
        )
        
        command_ids.append({
            'instance_id': instance_id,
            'component': component,
            'command_id': command_id,
            'doc_name': doc_name
        })
    
    logger.info("SSM documents started", command_count=len(command_ids))
    return command_ids


@tracer.capture_method
def get_command_status(ssm_client: SSMClient, ec2_client: EC2Client, doc_name_prefix: str) -> dict:
    """Get status of SSM command invocations"""
    instance_info = get_instance_info(ec2_client)
    
    statuses = []
    all_complete = True
    all_success = True
    
    for info in instance_info:
        instance_id = info['instance_id']
        component = info['component']
        doc_name = f"{doc_name_prefix}-{component}"
        
        command_status = ssm_client.get_command_invocation_status(
            instance_id=instance_id,
            document_name=doc_name
        )
        
        logger.info("Command status", 
                   instance_id=instance_id,
                   component=component,
                   status=command_status['Status'])
        
        statuses.append({
            'instance_id': instance_id,
            'component': component,
            'status': command_status['Status'],
            'command_id': command_status.get('CommandId')
        })
        
        if command_status['Status'] not in ['Success', 'Failed', 'Cancelled', 'TimedOut']:
            all_complete = False
        
        if command_status['Status'] != 'Success':
            all_success = False
    
    return {
        'statuses': statuses,
        'all_complete': all_complete,
        'all_success': all_success
    }


@tracer.capture_method
def check_tfc_run_status(tfc_url: str, run_id: str, token: str) -> dict:
    """Check the status of a Terraform Cloud run"""
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/vnd.api+json'
    }

    run_url = f"{tfc_url}/api/v2/runs/{run_id}"
    response = requests.get(run_url, headers=headers, timeout=30)
    response.raise_for_status()

    run_data = response.json()['data']
    status = run_data['attributes']['status']

    logger.info("TFC run status checked", run_id=run_id, status=status)

    # Determine if complete and successful
    is_complete = status in ['applied', 'errored', 'canceled', 'force_canceled', 'discarded']
    is_success = status == 'applied'

    return {
        'run_id': run_id,
        'status': status,
        'is_complete': is_complete,
        'is_success': is_success
    }


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event: dict, context: LambdaContext) -> dict:
    """
    Main handler - dispatches to appropriate function based on action
    
    Expected event format:
    {
        "action": "is_config_apply_ready" | "run_doc" | "get_command_status",
        "doc_name_prefix": "ConfigDoc" (for run_doc and get_command_status)
    }

    """
    dry_run = os.environ.get('DRY_RUN', 'false').lower() == 'true'

    logger.info("TFC runner invoked", dry_run=dry_run)

    action = event['action']
    logger.info("Processing action", action=action)
    
    ssm_client = SSMClient()
    ec2_client = EC2Client()
    
    if action == 'is_config_apply_ready':
        run_id = event['run_id']
        tfc_url = os.environ['TFC_URL']
        role_arn = os.environ['TFC_API_ACCESS_ROLE_ARN']
        secret_id = os.environ['TFC_API_TOKEN_SECRET']
        arcgis_version = os.environ.get('ARCGIS_VERSION', '11.5')
        
        # sts_client = STSClient()
        # assumed_session = sts_client.get_session_with_assumed_role(
        #     role_arn=role_arn,
        #     session_name='config-manager-lambda'
        # )
        
        # logger.info("Assumed cross-account role")
        
        # secrets_client = SecretsManagerClient(session=assumed_session)
        secrets_client = SecretsManagerClient() # Use default session for Secrets Manager
        secret_value = secrets_client.get_secret(secret_id)
        secret_dict = json.loads(secret_value)
        token = secret_dict['APIKey']
        
        logger.info("Retrieved TFC API token")
        
        ready = is_config_apply_ready(ssm_client, ec2_client, tfc_url, run_id, token, dry_run)
        logger.info("Config apply ready check complete", ready=ready)
        return {
            'statusCode': 200,
            'ready': ready
        }
    
    elif action == 'run_doc':
        doc_name_prefix = event['doc_name_prefix']
        command_ids = run_doc(ssm_client, ec2_client, doc_name_prefix)
        return {
            'statusCode': 200,
            'command_ids': command_ids
        }
    
    elif action == 'get_command_status':
        doc_name_prefix = event['doc_name_prefix']
        status = get_command_status(ssm_client, ec2_client, doc_name_prefix)
        return {
            'statusCode': 200,
            **status
        }
    
    else:
        logger.error("Unknown action requested", action=action)
        raise ValueError(f"Unknown action: {action}")
