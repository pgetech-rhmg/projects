# AMI AUTOMATION Lambda (with catalog maintenance + dedup + TFC trigger)

import boto3  # type: ignore
import requests
import os
import json
import time
import datetime

# ---------- AWS Clients ----------
ec2_client = boto3.client("ec2")
ssm_client = boto3.client("ssm")
secrets_client = boto3.client("secretsmanager")
sts_client = boto3.client("sts")
asg_client = boto3.client("autoscaling")
dynamodb = boto3.client("dynamodb")

# ---------- Config ----------
REQUEST_TIMEOUT = 10
DEDUP_TABLE = os.environ.get("DEDUP_TABLE")
CATALOG_PARAM = os.environ.get("CATALOG_PARAM", "/app/nonbluegreen/ami_catalog")

# NEW: Automation control flags
ENABLE_AMI_AUTOMATION = os.environ.get("ENABLE_AMI_AUTOMATION", "false").lower() == "true"
AUTO_APPLY_AMI_UPDATES = os.environ.get("AUTO_APPLY_AMI_UPDATES", "false").lower() == "true"

PARAMETER_PATHS = {
    "/app/migration_testing/latest_ami": ["test-bluegreen", "golden-ami-v2", "ami-golden-3", "golden-ami-v1", "ami-atcv-v4", "atcv-v5", "test-atcv-bg-6", "atcv-ami-testing", "atcv-ami-testing-2", "atcv-ami-testing-3", "atcv-ami-testing-4", "atcv-ami-testing-5", "atcv-ami-test-5"],
    "/ami/linux/golden": ["pge-base-linux-ami-"],
    "/ami/rhellinux/golden": ["pge-base-rhellinux"],
    "/ami/linux/al2023/golden": ["pge-base-linux-al2023-ami-"],
}

# ---------- Helpers ----------
def get_tfc_api_token():
    try:
        val = secrets_client.get_secret_value(SecretId="TFC_API_TOKEN").get("SecretString")
        return val.strip() if val else None
    except Exception as e:
        print(f"Error retrieving secret: {e}")
        return None

def get_current_aws_account():
    try:
        return sts_client.get_caller_identity()["Account"]
    except Exception as e:
        print(f"Error fetching AWS Account ID: {e}")
        return None

def get_latest_ami(parameter_path):
    try:
        return ssm_client.get_parameter(Name=parameter_path)["Parameter"]["Value"]
    except Exception as e:
        print(f"Error fetching AMI from SSM: {e}")
        return None

def seen_event(event_id: str) -> bool:
    if not DEDUP_TABLE or not event_id:
        return False
    try:
        dynamodb.put_item(
            TableName=DEDUP_TABLE,
            Item={"pk": {"S": f"evt#{event_id}"}, "ts": {"N": str(int(time.time()))}},
            ConditionExpression="attribute_not_exists(pk)",
        )
        return False
    except dynamodb.exceptions.ConditionalCheckFailedException:
        return True
    except Exception as e:
        print(f"Dedup error: {e}")
        return False

# ---------- SSM JSON helpers + catalog maintenance ----------
def _get_param_json(name: str):
    try:
        resp = ssm_client.get_parameter(Name=name)
        val = (resp.get("Parameter") or {}).get("Value", "")
        return json.loads(val) if val else []
    except ssm_client.exceptions.ParameterNotFound:
        return []
    except Exception as e:
        print(f"Failed reading {name}: {e}")
        return []

def _put_param_json(name: str, value_obj: object) -> bool:
    try:
        ssm_client.put_parameter(
            Name=name,
            Value=json.dumps(value_obj, separators=(",", ":")),
            Overwrite=True,
            Type="String",
            Description="Non Blue/Green AMI version catalog (managed by Lambda)",
        )
        return True
    except Exception as e:
        print(f"Failed writing {name}: {e}")
        return False

def append_to_ami_catalog_if_needed(latest_ami: str):
    if not latest_ami:
        return

    catalog = _get_param_json(CATALOG_PARAM)

    # Do nothing if latest AMI already recorded
    if catalog and catalog[-1].get("ami_id") == latest_ami:
        print(f"Catalog already up to date with {latest_ami} at v{catalog[-1].get('version')}")
        return

    # Add new entry
    next_version = max((int(e.get("version", 0)) for e in catalog), default=0) + 1
    ts = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"
    entry = {"version": next_version, "ami_id": latest_ami, "ts": ts}
    catalog.append(entry)

    # Keep only the last 4 entries
    MAX_ENTRIES = 4
    if len(catalog) > MAX_ENTRIES:
        catalog = catalog[-MAX_ENTRIES:]
        print(f"Pruned catalog to last {MAX_ENTRIES} entries")

    # Save back to SSM
    if _put_param_json(CATALOG_PARAM, catalog):
        print(f"Catalog updated: v{next_version} -> {latest_ami}")
    else:
        print("WARN: failed to update ami_catalog")


# ---------- EC2 Discovery ----------
def get_matching_workspace_ids_by_ami_name_keywords(keywords, latest_ami):
    workspace_ids = set()
    try:
        paginator = ec2_client.get_paginator("describe_instances")
        page_it = paginator.paginate(
            Filters=[
                {"Name": "instance-state-name", "Values": ["running"]},
                {"Name": "tag-key", "Values": ["tfc_wsid"]},
            ]
        )
        instances, image_ids = [], set()
        for page in page_it:
            for res in page.get("Reservations", []):
                for inst in res.get("Instances", []):
                    instances.append(inst)
                    if "ImageId" in inst:
                        image_ids.add(inst["ImageId"])

        images = {}
        if image_ids:
            for img in ec2_client.describe_images(ImageIds=list(image_ids)).get("Images", []):
                images[img["ImageId"]] = img.get("Name", "").lower()

        for inst in instances:
            instance_id = inst["InstanceId"]
            image_id = inst.get("ImageId")
            ami_name = images.get(image_id, "")
            tags = {t["Key"]: t["Value"] for t in inst.get("Tags", [])}
            wsid = tags.get("tfc_wsid")
            # NEW: skip non-Terraform-Cloud deployments
            if not wsid:
                print(f"EC2 {instance_id} has no tfc_wsid tag. Skipping.")
                continue

            if not wsid.startswith("ws-"):
                print(
                    f"EC2 {instance_id} has tfc_wsid='{wsid}' "
                    f"(not Terraform Cloud workspace). Likely deployed via CLI. Skipping."
                )
                continue

            if not any(k in ami_name for k in keywords):
                print(f"EC2 {instance_id} skipped - AMI '{ami_name}' does not match")
                continue

            if image_id != latest_ami:
                print(f"EC2 {instance_id} in workspace {wsid} is using old AMI '{ami_name}'")
                if wsid:
                    workspace_ids.add(wsid)
            else:
                print(f"EC2 {instance_id} already using latest AMI '{ami_name}'")
    except Exception as e:
        print(f"Error collecting EC2s: {e}")
    return list(workspace_ids)

# ---------- TFC ----------
def get_workspace(api_token, ws_id):
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/vnd.api+json",
    }
    url = f"https://app.terraform.io/api/v2/workspaces/{ws_id}"
    try:
        resp = requests.get(url, headers=headers, timeout=REQUEST_TIMEOUT)
        if resp.status_code != 200:
            print(f"Failed to fetch workspace {ws_id}: {resp.text}")
            return None
        return resp.json().get("data")
    except Exception as e:
        print(f"TFC get workspace error: {e}")
        return None

def filter_workspaces_by_account(api_token, workspace_ids, aws_account_id):
    matched = []
    for wsid in workspace_ids:
        ws = get_workspace(api_token, wsid)
        if not ws:
            continue
        tags = ws["attributes"].get("tag-names", [])
        account = ws["attributes"].get("account-id", "UNKNOWN")
        if account == "UNKNOWN":
            for t in tags:
                if t.startswith("account:aws-"):
                    account = t.split("account:aws-")[1]
                    break
        if account == aws_account_id:
            matched.append(wsid)
    print(f"Matched Workspaces: {matched}")
    return matched

def trigger_tf_run(api_token, workspace_id, auto_apply=False):
    headers = {
        "Authorization": f"Bearer {api_token}",
        "Content-Type": "application/vnd.api+json",
    }
    payload = {
        "data": {
            "attributes": {
                "message": "AMI update - Triggering Terraform plan",
                "is-destroy": False,
                "auto-apply": auto_apply,
            },
            "relationships": {
                "workspace": {"data": {"type": "workspaces", "id": workspace_id}}
            },
        }
    }
    try:
        resp = requests.post(
            "https://app.terraform.io/api/v2/runs",
            headers=headers,
            json=payload,
            timeout=REQUEST_TIMEOUT,
        )
        print(f"Triggered Terraform Run for {workspace_id}: {resp.status_code}")
        if resp.status_code in (200, 201):
            try:
                run_id = resp.json()["data"]["id"]
                print(f"TFC run_id: {run_id}")
            except Exception:
                pass
        else:
            print(f"TFC run error: {resp.text}")
    except Exception as e:
        print(f"Error triggering Terraform Run: {e}")

# ---------- Handler ----------
def lambda_handler(event, context):
    try:
        eid = event.get("id")
        if seen_event(eid):
            print(f"Duplicate event {eid}, skipping")
            return {"statusCode": 200, "body": "Duplicate"}
        
        # NEW: Global kill-switch
        if not ENABLE_AMI_AUTOMATION:
            print("AMI automation disabled. Exiting.")
            return {"statusCode": 200, "body": "AMI automation disabled"}

        parameter_name = event["detail"]["requestParameters"]["name"]
        print(f"Triggered by parameter: {parameter_name}")

        os_keywords = PARAMETER_PATHS.get(parameter_name, [])
        if not os_keywords:
            print(f"No matching keywords found for parameter: {parameter_name}")
            return {"statusCode": 200, "body": "No action for this parameter"}

        latest_ami = get_latest_ami(parameter_name)
        if not latest_ami:
            return {"statusCode": 500, "body": "Failed to read latest AMI"}

        print(f"Latest AMI from parameter {parameter_name}: {latest_ami}")

        # Maintain AMI catalog automatically
        append_to_ami_catalog_if_needed(latest_ami)

        # Find impacted workspaces & trigger plans
        workspace_ids = get_matching_workspace_ids_by_ami_name_keywords(os_keywords, latest_ami)
        if not workspace_ids:
            print("No outdated EC2s found.")
            return {"statusCode": 200, "body": "No matching EC2s"}

        api_token = get_tfc_api_token()
        if not api_token:
            return {"statusCode": 500, "body": "Missing TFC API token"}

        aws_account_id = get_current_aws_account()
        if not aws_account_id:
            return {"statusCode": 500, "body": "Unable to determine AWS account"}

        matching_workspaces = filter_workspaces_by_account(api_token, workspace_ids, aws_account_id)
        if not matching_workspaces:
            print("No workspaces matched this account.")
            return {"statusCode": 200, "body": "No workspaces matched this account"}

        for ws_id in matching_workspaces:
            trigger_tf_run(api_token, ws_id, AUTO_APPLY_AMI_UPDATES)

        return {"statusCode": 200, "body": "Terraform plan runs triggered."}

    except Exception as e:
        print(f"Error in handler: {e}")
        return {"statusCode": 500, "body": str(e)}