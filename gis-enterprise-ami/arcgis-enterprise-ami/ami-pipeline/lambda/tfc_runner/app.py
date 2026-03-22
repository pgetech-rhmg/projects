"""
Lambda function to trigger Terraform Cloud workspace runs.
In dry_run mode, launches test EC2 instances using the built AMIs
and writes sandbox state to SSM for downstream config/test steps.
"""
import json
import os
import requests
from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.utilities.typing import LambdaContext
from aws import SecretsManagerClient, STSClient, EC2Client, SSMClient

logger = Logger()
tracer = Tracer()


@tracer.capture_method
def launch_test_instances(ami_builds: list, ec2_client: EC2Client,
                          ssm_client: SSMClient) -> dict:
    """
    Launch small EC2 instances from the built AMIs for testing.
    Writes instance info to the sandbox_state SSM parameter so
    downstream config_manager steps can target them.
    """
    subnet_id = os.environ['TEST_SUBNET_ID']
    security_group_id = os.environ['TEST_SECURITY_GROUP_ID']
    instance_type = os.environ.get('TEST_INSTANCE_TYPE', 't3.small')
    instance_profile_arn = os.environ['TEST_INSTANCE_PROFILE_ARN']
    environment = os.environ.get('ENVIRONMENT', 'dev')
    sandbox_state_param = os.environ.get('SANDBOX_STATE_PARAMETER', '/ami_factory/sandbox_state')

    instances = []

    for build in ami_builds:
        component = build.get('component', '')
        ami_id = build.get('ami_id', '')

        if not component or not ami_id:
            logger.warning("Skipping build with missing data", build=build)
            continue

        logger.info("Launching test instance",
                    component=component, ami_id=ami_id,
                    instance_type=instance_type)

        tags = [
            {'Key': 'Name', 'Value': f'ami-factory-test-{component}-{environment}'},
            {'Key': 'Component', 'Value': component},
            {'Key': 'Environment', 'Value': environment},
            {'Key': 'ManagedBy', 'Value': 'ami-factory-dry-run'},
        ]

        instance_id = ec2_client.run_instances(
            ami_id=ami_id,
            instance_type=instance_type,
            subnet_id=subnet_id,
            security_group_id=security_group_id,
            iam_instance_profile=instance_profile_arn,
            tags=tags
        )

        logger.info("Instance launched", instance_id=instance_id, component=component)
        instances.append({
            'instance_id': instance_id,
            'component': component
        })

    # Write sandbox state to SSM so config_manager can find the instances
    sandbox_state = json.dumps({'instances': instances})
    ssm_client.put_parameter(
        name=sandbox_state_param,
        value=sandbox_state,
        description='Test instances launched by dry-run mode'
    )

    logger.info("Sandbox state written to SSM",
                parameter=sandbox_state_param,
                instance_count=len(instances))

    return {
        'instances': instances,
        'sandbox_state_parameter': sandbox_state_param,
        'dry_run': True
    }


@tracer.capture_method
def trigger_workspace_run(tfc_url: str, workspace_path: str, token: str, tfc_variables: list | None = None) -> dict:
    """Trigger a Terraform Cloud workspace run"""
    headers = {
        'Authorization': f'Bearer {token}',
        'Content-Type': 'application/vnd.api+json'
    }

    org, workspace = workspace_path.split('/')
    logger.info("Triggering TFC workspace", org=org, workspace=workspace)

    workspace_url = f"{tfc_url}/api/v2/organizations/{org}/workspaces/{workspace}"
    response = requests.get(workspace_url, headers=headers, timeout=30)
    response.raise_for_status()
    workspace_id = response.json()['data']['id']

    logger.info("Retrieved workspace ID", workspace_id=workspace_id)

    run_url = f"{tfc_url}/api/v2/runs"
    payload = {
        'data': {
            'type': 'runs',
            'attributes': {
                'message': 'Triggered by AMI Factory pipeline',
                **({'variables': tfc_variables} if tfc_variables else {})
            },
            'relationships': {
                'workspace': {
                    'data': {
                        'type': 'workspaces',
                        'id': workspace_id
                    }
                }
            }
        }
    }

    response = requests.post(run_url, headers=headers, json=payload, timeout=30)
    response.raise_for_status()

    run_data = response.json()['data']
    return {
        'run_id': run_data['id'],
        'status': run_data['attributes']['status'],
        'dry_run': False
    }


@logger.inject_lambda_context
@tracer.capture_lambda_handler
def handler(event: dict, context: LambdaContext) -> dict:
    """
    In production mode: triggers a Terraform Cloud workspace run.
    In dry_run mode: launches test EC2 instances from the built AMIs
    and writes sandbox state to SSM.

    Expected event format:
    {
        "workspace_path": "org/workspace-name",
        "ami_builds": [...]  // passed from step function build_results
    }
    """
    dry_run = os.environ.get('DRY_RUN', 'false').lower() == 'true'

    logger.info("TFC runner invoked", dry_run=dry_run)

    ami_builds = event.get('ami_builds', [])

    if dry_run:
        if not ami_builds:
            logger.error("No ami_builds provided for dry run mode")
            raise ValueError("ami_builds required in dry_run mode")

        ec2_client = EC2Client()
        ssm_client = SSMClient()

        result = launch_test_instances(ami_builds, ec2_client, ssm_client)

        return {
            'statusCode': 200,
            **result
        }
    else:
        tfc_url = os.environ['TFC_URL']
        workspace_path = event['workspace_path']
        role_arn = os.environ['TFC_API_ACCESS_ROLE_ARN']
        secret_id = os.environ['TFC_API_TOKEN_SECRET']

        # sts_client = STSClient()
        # assumed_session = sts_client.get_session_with_assumed_role(
        #     role_arn=role_arn,
        #     session_name='tfc-runner-lambda'
        # )

        # logger.info("Assumed cross-account role")

        # secrets_client = SecretsManagerClient(session=assumed_session)
        secrets_client = SecretsManagerClient()

        # Parse the JSON string and extract the specific key
        secret_value = secrets_client.get_secret(secret_id)
        secret_dict = json.loads(secret_value)
        token = secret_dict['APIKey'] 
        logger.info("Retrieved TFC API token")

        # 2. Build Run-Specific Variables
        # These override terraform.tfvars for THIS RUN ONLY.
        tfc_variables = []
        for build in ami_builds:
            var_key = f"{build['component']}_ami"
            tfc_variables.append({
                "key": var_key,
                "value": f"\"{build['ami_id']}\"", # Must be an HCL literal string
                "category": "terraform"
            })

        result = trigger_workspace_run(tfc_url, workspace_path, token, tfc_variables)

        logger.info("TFC run completed",
                    run_id=result['run_id'],
                    status=result['status'])

        return {
            'statusCode': 200,
            'run_id': result['run_id'],
            'status': result['status'],
            'dry_run': False
        }
