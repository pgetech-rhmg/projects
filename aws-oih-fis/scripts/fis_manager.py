#!/usr/bin/env python3
"""
FIS Manager - Unified tool for OIH Fault Injection Service operations.

Day-to-day operations for teams running FIS chaos engineering experiments:
  - Run experiments with configurable duration
  - Monitor experiment status (one-shot or live follow)
  - Tag resources (EC2, EBS, Subnets) for targeting
  - Dry-run targeting checks
  - List recent experiments

Advanced/one-time operations (infrastructure):
  - CloudFormation stack deployment/updates
  - SSM document deployment
  - Disk activity script deployment
  - Old template cleanup

Usage:
  python fis_manager.py                     # Interactive menu
  python fis_manager.py run                 # Run an experiment
  python fis_manager.py status EXP-ID       # Check experiment status
  python fis_manager.py watch EXP-ID        # Follow experiment until done
  python fis_manager.py list                # List recent experiments
  python fis_manager.py --profile myprof run  # Use specific AWS profile
"""

import argparse
import base64
import json
import os
import re
import subprocess
import sys
import time

STACK_NAME_DEFAULT = "fis-plumbing"
SSM_DOCUMENT_NAME = "OIH-Discover-SQL-DAG-Primary"


class AWSError(Exception):
    """Friendly wrapper for AWS CLI failures."""
    pass

# Resolve paths relative to the repo root (one level up from scripts/)
REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CFN_TEMPLATE = os.path.join(REPO_ROOT, "cfn", "FIS_plumbing.yaml")
SSM_DOCUMENT_FILE = os.path.join(REPO_ROOT, "ssm-documents", "discover-sql-dag-primary.yaml")
DISK_ACTIVITY_SCRIPT = os.path.join(REPO_ROOT, "powershell", "disk_activity.ps1")

# Colors
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
CYAN = "\033[0;36m"
BOLD = "\033[1m"
DIM = "\033[2m"
NC = "\033[0m"

# Global profile — set by argparse, threaded through all AWS calls
AWS_PROFILE = None


# ---------------------------------------------------------------------------
# AWS CLI helper
# ---------------------------------------------------------------------------

def run_aws(args, capture=True, check=True):
    """Run an AWS CLI command, injecting --profile if set.

    Catches common failures and raises AWSError with a friendly message
    so that Python tracebacks never reach the user.
    """
    cmd = ["aws"]
    if AWS_PROFILE:
        cmd += ["--profile", AWS_PROFILE]
    cmd += args
    try:
        result = subprocess.run(cmd, capture_output=capture, text=True, check=check)
    except FileNotFoundError:
        raise AWSError(
            "The 'aws' CLI is not installed or not on your PATH.\n"
            "  Install it: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
        )
    except subprocess.CalledProcessError as e:
        stderr = (e.stderr or "").strip()
        # Surface the most common issues with plain-English hints
        if "ExpiredToken" in stderr or "InvalidIdentityToken" in stderr:
            raise AWSError(
                "Your AWS session has expired. Please refresh your credentials:\n"
                f"  aws sso login{' --profile ' + AWS_PROFILE if AWS_PROFILE else ''}"
            )
        if "NoCredentialProviders" in stderr or "Unable to locate credentials" in stderr:
            raise AWSError(
                "No AWS credentials found. Make sure you are logged in:\n"
                f"  aws sso login{' --profile ' + AWS_PROFILE if AWS_PROFILE else ''}\n"
                "  Or set AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY environment variables."
            )
        if "could not be found" in stderr and "profile" in stderr.lower():
            raise AWSError(
                f"AWS profile '{AWS_PROFILE}' not found.\n"
                "  Check your ~/.aws/config for available profiles."
            )
        # Generic — show the AWS error but no Python traceback
        service = args[0] if args else "aws"
        raise AWSError(f"AWS {service} command failed:\n  {stderr}")
    if capture:
        return result.stdout.strip()
    return None


def run_aws_json(args):
    """Run an AWS CLI command and parse JSON output."""
    raw = run_aws(args + ["--output", "json"])
    return json.loads(raw) if raw else None


def confirm(prompt, required="yes"):
    """Prompt user for confirmation (case-insensitive)."""
    try:
        response = input(f"{prompt} ({required}/no): ").strip()
    except EOFError:
        return False
    return response.upper() == required.upper()


def banner(title):
    print(f"\n{'='*56}")
    print(f"  {title}")
    print(f"{'='*56}\n")


def parse_duration(user_input):
    """Convert user-friendly duration to ISO 8601 (e.g., '5m' -> 'PT5M', '90s' -> 'PT90S').

    Accepts: '5m', '10m', '2h', '90s', '5', 'PT5M' (passthrough).
    Returns ISO 8601 duration string or None if invalid.
    """
    s = user_input.strip().upper()
    if s.startswith("PT"):
        return s  # already ISO 8601
    m = re.match(r'^(\d+)\s*([SMHD]?)$', s)
    if not m:
        return None
    value, unit = m.group(1), m.group(2)
    if not unit or unit == 'M':
        return f"PT{value}M"
    return f"PT{value}{unit}"


def format_iso_duration(iso):
    """Convert ISO 8601 duration to human-readable (e.g., 'PT5M' -> '5 minutes')."""
    if not iso:
        return "unknown"
    m = re.match(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$', iso.upper())
    if not m:
        return iso
    parts = []
    if m.group(1):
        parts.append(f"{m.group(1)}h")
    if m.group(2):
        parts.append(f"{m.group(2)}m")
    if m.group(3):
        parts.append(f"{m.group(3)}s")
    return " ".join(parts) if parts else iso


# ---------------------------------------------------------------------------
# Experiment Status & Monitoring
# ---------------------------------------------------------------------------

def get_experiment_status(experiment_id):
    """Get experiment details as a dict."""
    raw = run_aws([
        "fis", "get-experiment",
        "--id", experiment_id,
        "--output", "json"
    ])
    return json.loads(raw).get("experiment", {}) if raw else {}


def print_experiment_status(exp):
    """Pretty-print experiment status."""
    state = exp.get("state", {})
    status = state.get("status", "UNKNOWN")
    reason = state.get("reason", "")

    color = GREEN if status == "completed" else RED if status in ("failed", "stopped") else YELLOW
    print(f"  Experiment: {BOLD}{exp.get('id', '?')}{NC}")
    print(f"  Template:   {exp.get('experimentTemplateId', '?')}")
    print(f"  Status:     {color}{status}{NC}")
    if reason:
        print(f"  Reason:     {reason}")

    create_time = exp.get("creationTime", "")
    if create_time:
        print(f"  Started:    {create_time}")
    end_time = exp.get("endTime", "")
    if end_time:
        print(f"  Ended:      {end_time}")

    # Show action statuses
    actions = exp.get("actions", {})
    if actions:
        print(f"\n  {BOLD}Actions:{NC}")
        for name, action in actions.items():
            a_state = action.get("state", {}).get("status", "?")
            a_color = GREEN if a_state == "completed" else RED if a_state == "failed" else YELLOW
            desc = action.get("description", "")
            print(f"    {name}: {a_color}{a_state}{NC}  {DIM}{desc}{NC}")


def pick_experiment():
    """Let user pick from recent experiments, or type an ID directly."""
    eid = input("Experiment ID (or press Enter to pick from recent): ").strip()
    if eid:
        return eid

    raw = run_aws([
        "fis", "list-experiments",
        "--max-results", "10",
        "--output", "json"
    ])
    data = json.loads(raw) if raw else {}
    experiments = data.get("experiments", [])

    if not experiments:
        print(f"{YELLOW}No recent experiments found.{NC}")
        return None

    print("\nRecent experiments:\n")
    for i, exp in enumerate(experiments, 1):
        status = exp.get("state", {}).get("status", "?")
        color = GREEN if status == "completed" else RED if status in ("failed", "stopped") else YELLOW
        created = str(exp.get("creationTime", "?"))[:19]
        desc = exp.get("experimentTemplateId", "?")
        print(f"  {i}) {exp.get('id', '?')}  {color}{status:<12}{NC}  {created}  {DIM}{desc}{NC}")
    print(f"  {len(experiments)+1}) Cancel")

    choice = input(f"\nChoose (1-{len(experiments)+1}): ").strip()
    try:
        idx = int(choice) - 1
    except ValueError:
        return None
    if idx < 0 or idx >= len(experiments):
        return None
    return experiments[idx].get("id")


def show_experiment_status(experiment_id):
    """One-shot status display."""
    banner("Experiment Status")
    exp = get_experiment_status(experiment_id)
    if not exp:
        print(f"{RED}Experiment {experiment_id} not found.{NC}")
        return
    print_experiment_status(exp)
    print()


def watch_experiment(experiment_id, interval=5):
    """Follow experiment status until terminal state, polling every `interval` seconds."""
    banner("Watching Experiment (Ctrl+C to stop)")
    terminal_states = {"completed", "stopped", "failed", "cancelled"}

    try:
        while True:
            exp = get_experiment_status(experiment_id)
            if not exp:
                print(f"{RED}Experiment {experiment_id} not found.{NC}")
                return

            # Clear screen and reprint
            print("\033[2J\033[H", end="")  # clear + home
            banner("Watching Experiment (Ctrl+C to stop)")
            print_experiment_status(exp)

            status = exp.get("state", {}).get("status", "")
            if status in terminal_states:
                print(f"\n{GREEN}Experiment reached terminal state: {status}{NC}")
                return

            print(f"\n{DIM}Refreshing in {interval}s...{NC}")
            time.sleep(interval)
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Stopped watching.{NC}")


def list_experiments(max_results=10):
    """List recent FIS experiments with status."""
    banner("Recent FIS Experiments")

    raw = run_aws([
        "fis", "list-experiments",
        "--max-results", str(max_results),
        "--output", "json"
    ])
    data = json.loads(raw) if raw else {}
    experiments = data.get("experiments", [])

    if not experiments:
        print(f"{YELLOW}No experiments found.{NC}")
        return

    print(f"  {'ID':<28} {'Status':<12} {'Template':<28} {'Created'}")
    print(f"  {'-'*27} {'-'*11} {'-'*27} {'-'*20}")
    for exp in experiments:
        eid = exp.get("id", "?")
        status = exp.get("state", {}).get("status", "?")
        tid = exp.get("experimentTemplateId", "?")
        created = str(exp.get("creationTime", "?"))[:19]
        color = GREEN if status == "completed" else RED if status in ("failed", "stopped") else YELLOW
        print(f"  {eid:<28} {color}{status:<12}{NC} {tid:<28} {created}")
    print()


# ---------------------------------------------------------------------------
# Experiment Launcher (with configurable duration)
# ---------------------------------------------------------------------------

def classify_template(description):
    """Classify a template by its description and return (sort_order, friendly_name, explanation).

    Returns (99, None, None) for unrecognized templates so they sort to the end.
    """
    desc = (description or "").lower()

    # Ordered from least impactful to most impactful
    # Each entry: (sort_order, friendly_name, plain_english_explanation, match_fn)
    patterns = [
        (1, "Pause EBS I/O - Primary",
         "Freezes disk I/O on Primary DB server volumes. DB will hang until I/O resumes.\n"
         "         Simulates: storage failure on the primary SQL Server.",
         lambda: "pause" in desc and "ebs" in desc and "primary" in desc),
        (2, "Pause EBS I/O - Secondary",
         "Freezes disk I/O on Secondary DB server volumes. Secondary DB will hang.\n"
         "         Simulates: storage failure on the secondary SQL Server.",
         lambda: "pause" in desc and "ebs" in desc and "secondary" in desc),
        (3, "Stop EC2 Instances - Primary",
         "Stops (powers off) the Primary DB EC2 instances, then restarts them.\n"
         "         Simulates: server crash or unexpected reboot of primary SQL Server.",
         lambda: "stop" in desc and "primary" in desc and "subnet" not in desc and "network" not in desc),
        (4, "Stop EC2 Instances - Secondary",
         "Stops (powers off) the Secondary DB EC2 instances, then restarts them.\n"
         "         Simulates: server crash or unexpected reboot of secondary SQL Server.",
         lambda: "stop" in desc and "secondary" in desc and "subnet" not in desc and "network" not in desc),
        (5, "Network Disruption - Primary AZ",
         "Blocks all network traffic to/from subnets in the Primary AZ (us-west-2b).\n"
         "         Simulates: complete AZ network failure. All resources in those subnets go dark.",
         lambda: ("disrupt" in desc or "network" in desc) and "primary" in desc and ("subnet" in desc or "az" in desc)),
        (6, "Network Disruption - Secondary AZ",
         "Blocks all network traffic to/from subnets in the Secondary AZ (us-west-2a).\n"
         "         Simulates: complete AZ network failure. All resources in those subnets go dark.",
         lambda: ("disrupt" in desc or "network" in desc) and "secondary" in desc and ("subnet" in desc or "az" in desc)),
        (7, "Network Disruption - Tertiary AZ",
         "Blocks all network traffic to/from subnets in the Tertiary AZ (us-west-2c).\n"
         "         Simulates: AZ failure in a zone with no OIH databases (non-DB workloads only).",
         lambda: ("disrupt" in desc or "network" in desc) and "tertiary" in desc),
    ]

    for order, name, explanation, match_fn in patterns:
        if match_fn():
            return order, name, explanation
    return 99, None, None


def get_all_templates_ordered():
    """Get all FIS experiment templates, classified and sorted in operational order."""
    raw = run_aws([
        "fis", "list-experiment-templates",
        "--output", "json"
    ])
    data = json.loads(raw) if raw else {}
    all_templates = data.get("experimentTemplates", [])

    results = []
    for tmpl in all_templates:
        tid = tmpl.get("id", "")
        desc = tmpl.get("description", "")
        sort_order, friendly_name, explanation = classify_template(desc)
        results.append({
            "id": tid,
            "name": friendly_name or desc or "(no description)",
            "description": desc,
            "explanation": explanation or "",
            "sort_order": sort_order,
        })

    results.sort(key=lambda x: (x["sort_order"], x["name"]))
    return results


def show_targeted_resources(template_detail):
    """Show which resources will be affected by this experiment."""
    tmpl = template_detail.get("experimentTemplate", {})
    targets = tmpl.get("targets", {})

    for name, target in targets.items():
        rtype = target.get("resourceType", "")
        tags = target.get("resourceTags", {})
        # filters (e.g., State.Name=running) are baked into template, not needed here

        print(f"\n  {YELLOW}Target: {name} ({rtype}){NC}")
        for k, v in tags.items():
            print(f"    Tag: {k}={v}")

        # Query actual resources that match
        if "ec2:instance" in rtype:
            filter_args = ["ec2", "describe-instances", "--filters"]
            for k, v in tags.items():
                filter_args.append(f"Name=tag:{k},Values={v}")
            filter_args.append("Name=instance-state-name,Values=running")
            filter_args += [
                "--query", "Reservations[].Instances[].{InstanceId:InstanceId,AvailabilityZone:Placement.AvailabilityZone,PrivateIP:PrivateIpAddress,State:State.Name,Name:Tags[?Key==`Name`].Value|[0]}",
                "--output", "table"
            ]
            output = run_aws(filter_args)
            if output:
                print(f"    {RED}Instances that WILL be affected:{NC}")
                for line in output.splitlines():
                    print(f"      {line}")
            else:
                print(f"    {GREEN}No matching instances found.{NC}")

        elif "ebs-volume" in rtype:
            filter_args = ["ec2", "describe-volumes", "--filters"]
            for k, v in tags.items():
                filter_args.append(f"Name=tag:{k},Values={v}")
            filter_args += [
                "--query", "Volumes[].{VolumeId:VolumeId,SizeGB:Size,Device:Attachments[0].Device,InstanceId:Attachments[0].InstanceId,Name:Tags[?Key==`Name`].Value|[0]}",
                "--output", "table"
            ]
            output = run_aws(filter_args)
            if output:
                print(f"    {RED}Volumes that WILL be affected:{NC}")
                for line in output.splitlines():
                    print(f"      {line}")
            else:
                print(f"    {GREEN}No matching volumes found.{NC}")

        elif "ec2:subnet" in rtype:
            filter_args = ["ec2", "describe-subnets", "--filters"]
            for k, v in tags.items():
                filter_args.append(f"Name=tag:{k},Values={v}")
            filter_args += [
                "--query", "Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}",
                "--output", "table"
            ]
            output = run_aws(filter_args)
            if output:
                print(f"    {RED}Subnets that WILL be affected:{NC}")
                for line in output.splitlines():
                    print(f"      {line}")
            else:
                print(f"    {GREEN}No matching subnets found.{NC}")


def get_template_duration_info(tmpl):
    """Extract current duration and the action/parameter key from a template."""
    actions = tmpl.get("actions", {})
    for action_name, action in actions.items():
        params = action.get("parameters", {})
        # EC2 stop uses startInstancesAfterDuration, others use duration
        for param_key in ("duration", "startInstancesAfterDuration"):
            if param_key in params:
                return action_name, param_key, params[param_key]
    return None, None, None


def update_template_duration(template_id, action_name, param_key, new_duration):
    """Update an experiment template's duration parameter."""
    # Build the action update payload
    detail_json = run_aws([
        "fis", "get-experiment-template",
        "--id", template_id,
        "--output", "json"
    ])
    detail = json.loads(detail_json)
    tmpl = detail.get("experimentTemplate", {})
    action = tmpl["actions"][action_name]

    update_actions = {
        action_name: {
            "actionId": action["actionId"],
            "parameters": {**action.get("parameters", {}), param_key: new_duration},
            "targets": action.get("targets", {}),
        }
    }
    if "description" in action:
        update_actions[action_name]["description"] = action["description"]

    run_aws([
        "fis", "update-experiment-template",
        "--id", template_id,
        "--actions", json.dumps(update_actions),
    ])


def run_experiment():
    """Interactively select and run an FIS experiment with configurable duration."""
    banner("FIS Experiment Launcher")

    templates = get_all_templates_ordered()
    if not templates:
        print(f"{RED}No FIS experiment templates found.{NC}")
        return

    print("Available experiments (ordered least to most impactful):\n")
    for i, t in enumerate(templates, 1):
        print(f"  {i}) {BOLD}{t['name']}{NC}")
        if t.get("explanation"):
            print(f"         {DIM}{t['explanation']}{NC}")
    print(f"\n  {len(templates)+1}) Cancel")

    choice = input(f"\nChoose experiment (1-{len(templates)+1}): ").strip()
    if not choice:
        print("Cancelled.")
        return
    try:
        idx = int(choice) - 1
    except ValueError:
        print(f"{RED}Invalid choice. Enter a number 1-{len(templates)+1}.{NC}")
        return
    if idx < 0 or idx >= len(templates):
        print("Cancelled.")
        return
    template_id = templates[idx]["id"]
    template_name = templates[idx]["name"]

    print(f"\n  Selected: {BOLD}{template_name}{NC}")
    print(f"  Template ID: {template_id}")

    # Get template details
    detail_json = run_aws([
        "fis", "get-experiment-template",
        "--id", template_id,
        "--output", "json"
    ])
    detail = json.loads(detail_json)
    tmpl = detail.get("experimentTemplate", {})

    # Show what will be affected
    print(f"\n{BOLD}Resources that will be affected:{NC}")
    show_targeted_resources(detail)

    # Show current duration and offer to change
    action_name, param_key, current_duration = get_template_duration_info(tmpl)
    if current_duration:
        human_dur = format_iso_duration(current_duration)
        print(f"\n  Current duration: {BOLD}{human_dur}{NC} ({current_duration})")
        new_dur_input = input(f"  New duration [Enter to keep {human_dur}]: ").strip()
        if new_dur_input:
            new_duration = parse_duration(new_dur_input)
            if not new_duration:
                print(f"{RED}Invalid duration format. Examples: 2m, 10m, 30s, 1h{NC}")
                return
            print(f"  Updating template duration to {format_iso_duration(new_duration)}...")
            update_template_duration(template_id, action_name, param_key, new_duration)
            print(f"  {GREEN}Duration updated.{NC}")
            current_duration = new_duration

    # Final confirmation
    print(f"\n{RED}{'='*56}")
    print("  THIS WILL RUN THE EXPERIMENT")
    print(f"  {template_name}")
    print(f"  Template: {template_id}")
    if current_duration:
        print(f"  Duration: {format_iso_duration(current_duration)}")
    print(f"{'='*56}{NC}\n")

    if not confirm("Type 'YES' to proceed", required="YES"):
        print(f"{GREEN}Experiment cancelled.{NC}")
        return

    cmd = [
        "fis", "start-experiment",
        "--experiment-template-id", template_id,
        "--experiment-options", "actionsMode=run-all",
        "--query", "experiment.id",
        "--output", "text",
    ]

    experiment_id = run_aws(cmd)
    print(f"\n{GREEN}Experiment started!{NC}")
    print(f"  Experiment ID: {BOLD}{experiment_id}{NC}")

    # Post-launch guidance
    dur_text = format_iso_duration(current_duration) if current_duration else "the configured duration"
    print(f"\n{CYAN}What happens now:{NC}")
    print(f"  1. FIS is injecting the fault NOW. The experiment runs for {BOLD}{dur_text}{NC}.")
    print("  2. During the experiment, affected resources will be impaired/unavailable.")
    print("  3. When the timer expires, FIS automatically rolls back the fault.")
    print("  4. After rollback, verify your application recovered (check ALB, DAG status, etc).")
    print(f"\n  {DIM}Tip: You can check status later with:  python fis_manager.py status {experiment_id}{NC}")

    # Offer to watch
    watch_choice = input("\nWatch experiment progress? (y/n) [y]: ").strip().lower()
    if watch_choice != "n":
        watch_experiment(experiment_id)


# ---------------------------------------------------------------------------
# Dry-Run Targeting
# ---------------------------------------------------------------------------

def dry_run_targeting():
    """Show which resources would be targeted by FIS experiments without running them."""
    banner("FIS Targeting Dry-Run")

    for role, az in [("Primary", "us-west-2b"), ("Secondary", "us-west-2a")]:
        print(f"{YELLOW}EC2 Instances: FISTarget=True, FISDBRole={role}, AZ={az}{NC}")
        output = run_aws([
            "ec2", "describe-instances",
            "--filters",
            "Name=tag:FISTarget,Values=True",
            f"Name=tag:FISDBRole,Values={role}",
            "Name=instance-state-name,Values=running",
            f"Name=availability-zone,Values={az}",
            "--query", "Reservations[].Instances[].{InstanceId:InstanceId,AvailabilityZone:Placement.AvailabilityZone,PrivateIP:PrivateIpAddress,Name:Tags[?Key==`Name`].Value|[0]}",
            "--output", "table"
        ])
        if output:
            print(f"{RED}Would be targeted:{NC}")
            print(output)
        else:
            print(f"{GREEN}No instances match these criteria.{NC}")
        print()

    for role in ["Primary", "Secondary"]:
        print(f"{YELLOW}EBS Volumes: FISTarget=True, FISEBSTarget=True, FISDBRole={role}{NC}")
        output = run_aws([
            "ec2", "describe-volumes",
            "--filters",
            "Name=tag:FISTarget,Values=True",
            "Name=tag:FISEBSTarget,Values=True",
            f"Name=tag:FISDBRole,Values={role}",
            "--query", "Volumes[].{VolumeId:VolumeId,SizeGB:Size,Device:Attachments[0].Device,InstanceId:Attachments[0].InstanceId,Name:Tags[?Key==`Name`].Value|[0]}",
            "--output", "table"
        ])
        if output:
            print(f"{RED}Would be targeted:{NC}")
            print(output)
        else:
            print(f"{GREEN}No volumes match these criteria.{NC}")
        print()

    for role in ["Primary", "Secondary"]:
        print(f"{YELLOW}Subnets: FISTarget=True, FISAZRole={role}{NC}")
        output = run_aws([
            "ec2", "describe-subnets",
            "--filters",
            "Name=tag:FISTarget,Values=True",
            f"Name=tag:FISAZRole,Values={role}",
            "--query", "Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}",
            "--output", "table"
        ])
        if output:
            print(f"{RED}Would be targeted:{NC}")
            print(output)
        else:
            print(f"{GREEN}No subnets match these criteria.{NC}")
        print()

    print(f"{YELLOW}All instances with FISTarget=True:{NC}")
    output = run_aws([
        "ec2", "describe-instances",
        "--filters", "Name=tag:FISTarget,Values=True",
        "--query", "sort_by(Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,AvailabilityZone:Placement.AvailabilityZone,FISDBRole:Tags[?Key==`FISDBRole`].Value|[0],Name:Tags[?Key==`Name`].Value|[0]}, &FISDBRole)",
        "--output", "table"
    ])
    print(output if output else f"{GREEN}No instances tagged.{NC}")
    print(f"\n{GREEN}Dry-run complete. No resources were modified.{NC}")


# ---------------------------------------------------------------------------
# Tag Resources (EC2/EBS)
# ---------------------------------------------------------------------------

def tag_resources():
    """Interactive menu for tagging EC2 instances and EBS volumes for FIS."""
    while True:
        banner("FIS Resource Tagging (EC2/EBS)")
        print(f"{BLUE}EC2 Instances:{NC}")
        print("  1) Tag an instance as Primary")
        print("  2) Tag an instance as Secondary")
        print("  3) Show Primary-tagged instances")
        print("  4) Show Secondary-tagged instances")
        print("  5) Remove FIS tags from an instance")
        print(f"\n{BLUE}EBS Volumes:{NC}")
        print("  6) Tag all volumes attached to an instance")
        print("  7) Show all FIS-tagged volumes")
        print("  8) Remove FIS tags from volumes on an instance")
        print("\n  9) Back to main menu\n")

        choice = input("Choose (1-9): ").strip()

        if choice in ("1", "2"):
            role = "Primary" if choice == "1" else "Secondary"
            instance_id = input(f"Enter instance ID to tag as {role}: ").strip()
            if not instance_id:
                continue
            info = run_aws([
                "ec2", "describe-instances", "--instance-ids", instance_id,
                "--query", "Reservations[0].Instances[0].[InstanceId,State.Name,Placement.AvailabilityZone,PrivateIpAddress,Tags[?Key==`Name`].Value|[0]]",
                "--output", "text"
            ])
            print(f"\nInstance: {info}")
            if confirm(f"\nTag as FISTarget=True, FISDBRole={role}?"):
                run_aws(["ec2", "create-tags", "--resources", instance_id,
                          "--tags", "Key=FISTarget,Value=True", f"Key=FISDBRole,Value={role}"])
                print(f"{GREEN}Tagged!{NC}")

        elif choice == "3":
            print(run_aws(["ec2", "describe-instances",
                            "--filters", "Name=tag:FISTarget,Values=True", "Name=tag:FISDBRole,Values=Primary",
                            "Name=instance-state-name,Values=running,stopped",
                            "--query", "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,AvailabilityZone:Placement.AvailabilityZone,Name:Tags[?Key==`Name`].Value|[0]}",
                            "--output", "table"]))

        elif choice == "4":
            print(run_aws(["ec2", "describe-instances",
                            "--filters", "Name=tag:FISTarget,Values=True", "Name=tag:FISDBRole,Values=Secondary",
                            "Name=instance-state-name,Values=running,stopped",
                            "--query", "Reservations[].Instances[].{InstanceId:InstanceId,State:State.Name,AvailabilityZone:Placement.AvailabilityZone,Name:Tags[?Key==`Name`].Value|[0]}",
                            "--output", "table"]))

        elif choice == "5":
            instance_id = input("Enter instance ID: ").strip()
            if instance_id:
                run_aws(["ec2", "delete-tags", "--resources", instance_id,
                          "--tags", "Key=FISTarget", "Key=FISDBRole"])
                print(f"{GREEN}FIS tags removed.{NC}")

        elif choice == "6":
            instance_id = input("Enter instance ID: ").strip()
            if not instance_id:
                continue
            role = run_aws(["ec2", "describe-instances", "--instance-ids", instance_id,
                             "--query", "Reservations[0].Instances[0].Tags[?Key==`FISDBRole`].Value|[0]",
                             "--output", "text"])
            if not role or role == "None":
                print(f"{RED}Instance has no FISDBRole tag. Tag the instance first.{NC}")
                continue
            vols = run_aws(["ec2", "describe-volumes",
                             "--filters", f"Name=attachment.instance-id,Values={instance_id}",
                             "--query", "Volumes[].[VolumeId,Size,Attachments[0].Device]",
                             "--output", "text"])
            print(f"\nVolumes attached (role={role}):\n{vols}")
            if confirm(f"\nTag all with FISTarget=True, FISEBSTarget=True, FISDBRole={role}?"):
                vol_ids = [line.split()[0] for line in vols.splitlines() if line.strip()]
                for vid in vol_ids:
                    run_aws(["ec2", "create-tags", "--resources", vid,
                              "--tags", "Key=FISTarget,Value=True", "Key=FISEBSTarget,Value=True",
                              f"Key=FISDBRole,Value={role}"])
                    print(f"{GREEN}Tagged {vid}{NC}")

        elif choice == "7":
            print(run_aws(["ec2", "describe-volumes",
                            "--filters", "Name=tag:FISTarget,Values=True", "Name=tag:FISEBSTarget,Values=True",
                            "--query", "sort_by(Volumes[].{VolumeId:VolumeId,SizeGB:Size,Device:Attachments[0].Device,InstanceId:Attachments[0].InstanceId,FISDBRole:Tags[?Key==`FISDBRole`].Value|[0],Name:Tags[?Key==`Name`].Value|[0]}, &FISDBRole)",
                            "--output", "table"]))

        elif choice == "8":
            instance_id = input("Enter instance ID: ").strip()
            if instance_id:
                vol_ids = run_aws(["ec2", "describe-volumes",
                                    "--filters", f"Name=attachment.instance-id,Values={instance_id}",
                                    "Name=tag:FISTarget,Values=True",
                                    "--query", "Volumes[].VolumeId", "--output", "text"])
                if vol_ids:
                    for vid in vol_ids.split():
                        run_aws(["ec2", "delete-tags", "--resources", vid,
                                  "--tags", "Key=FISTarget", "Key=FISEBSTarget", "Key=FISDBRole"])
                        print(f"{GREEN}Removed tags from {vid}{NC}")
                else:
                    print(f"{YELLOW}No FIS-tagged volumes found.{NC}")

        elif choice == "9":
            break


# ---------------------------------------------------------------------------
# Tag Subnets
# ---------------------------------------------------------------------------

def tag_subnets():
    """Interactive menu for tagging subnets for FIS network disruption experiments."""
    while True:
        banner("FIS Subnet Tagging (Network Disruption)")
        print(f"{BLUE}Tag Subnets:{NC}")
        print("   1) Tag a single subnet")
        print("   2) Tag all subnets in an AZ as Primary")
        print("   3) Tag all subnets in an AZ as Secondary")
        print("   4) Tag all subnets in an AZ as Tertiary (no DB servers)")
        print(f"\n{BLUE}View:{NC}")
        print("   5) Show all FIS-tagged subnets")
        print("   6) Show impact summary")
        print("   7) List Availability Zones")
        print(f"\n{BLUE}Remove:{NC}")
        print("   8) Remove FIS tags from a subnet")
        print("   9) Remove FIS tags from all subnets in an AZ")
        print("  10) Remove ALL FIS subnet tags")
        print("\n  11) Back to main menu\n")

        choice = input("Choose (1-11): ").strip()

        if choice == "1":
            subnet_id = input("Enter subnet ID (or press Enter to list all): ").strip()
            if not subnet_id:
                print(run_aws(["ec2", "describe-subnets",
                                "--query", "sort_by(Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CIDR:CidrBlock,Name:Tags[?Key==`Name`].Value|[0]}, &AvailabilityZone)",
                                "--output", "table"]))
                subnet_id = input("Enter subnet ID: ").strip()
            role = input("Enter AZ role (Primary/Secondary/Tertiary): ").strip()
            if not subnet_id or role not in ("Primary", "Secondary", "Tertiary"):
                print(f"{RED}Invalid input. Role must be Primary, Secondary, or Tertiary.{NC}")
                continue
            info = run_aws(["ec2", "describe-subnets", "--subnet-ids", subnet_id,
                             "--query", "Subnets[0].[SubnetId,CidrBlock,AvailabilityZone,VpcId,Tags[?Key==`Name`].Value|[0]]",
                             "--output", "text"])
            print(f"\nSubnet: {info}")
            if confirm(f"\nTag with FISTarget=True, FISAZRole={role}?"):
                run_aws(["ec2", "create-tags", "--resources", subnet_id,
                          "--tags", "Key=FISTarget,Value=True", f"Key=FISAZRole,Value={role}"])
                print(f"{GREEN}Tagged!{NC}")

        elif choice in ("2", "3", "4"):
            role = {"2": "Primary", "3": "Secondary", "4": "Tertiary"}[choice]
            az = input("Enter Availability Zone (e.g., us-west-2a): ").strip()
            if not az:
                continue
            subs = run_aws(["ec2", "describe-subnets",
                             "--filters", f"Name=availability-zone,Values={az}",
                             "--query", "Subnets[].[SubnetId,CidrBlock,Tags[?Key==`Name`].Value|[0]]",
                             "--output", "text"])
            if not subs:
                print(f"{RED}No subnets found in {az}.{NC}")
                continue
            print(f"\nSubnets in {az}:\n{subs}")
            if confirm(f"\nTag ALL as FISTarget=True, FISAZRole={role}?"):
                for line in subs.splitlines():
                    sid = line.split()[0]
                    run_aws(["ec2", "create-tags", "--resources", sid,
                              "--tags", "Key=FISTarget,Value=True", f"Key=FISAZRole,Value={role}"])
                    print(f"{GREEN}Tagged {sid}{NC}")

        elif choice == "5":
            print(run_aws(["ec2", "describe-subnets",
                            "--filters", "Name=tag:FISTarget,Values=True",
                            "--query", "sort_by(Subnets[].{SubnetId:SubnetId,AvailabilityZone:AvailabilityZone,CIDR:CidrBlock,FISAZRole:Tags[?Key==`FISAZRole`].Value|[0],Name:Tags[?Key==`Name`].Value|[0]}, &FISAZRole)",
                            "--output", "table"]))

        elif choice == "6":
            role = input("AZ role to analyze (Primary/Secondary/Tertiary): ").strip()
            sids = run_aws(["ec2", "describe-subnets",
                              "--filters", "Name=tag:FISTarget,Values=True",
                              f"Name=tag:FISAZRole,Values={role}",
                              "--query", "Subnets[].SubnetId", "--output", "text"])
            if not sids:
                print(f"{YELLOW}No subnets tagged with FISAZRole={role}.{NC}")
                continue
            for sid in sids.split():
                info = run_aws(["ec2", "describe-subnets", "--subnet-ids", sid,
                                 "--query", "Subnets[0].[Tags[?Key==`Name`].Value|[0],AvailabilityZone,CidrBlock]",
                                 "--output", "text"])
                ec2_count = run_aws(["ec2", "describe-instances",
                                      "--filters", f"Name=subnet-id,Values={sid}",
                                      "Name=instance-state-name,Values=running,stopped",
                                      "--query", "length(Reservations[].Instances[])",
                                      "--output", "text"])
                eni_count = run_aws(["ec2", "describe-network-interfaces",
                                      "--filters", f"Name=subnet-id,Values={sid}",
                                      "--query", "length(NetworkInterfaces)",
                                      "--output", "text"])
                print(f"{CYAN}{sid}{NC}: {info}  EC2={ec2_count}  ENIs={eni_count}")
            print(f"\n{RED}Network disruption will isolate ALL resources above.{NC}")

        elif choice == "7":
            output = run_aws(["ec2", "describe-subnets",
                               "--query", "Subnets[].[AvailabilityZone]",
                               "--output", "text"])
            from collections import Counter
            counts = Counter(output.split())
            for az, count in sorted(counts.items()):
                print(f"  {az} - {count} subnet(s)")

        elif choice == "8":
            sid = input("Enter subnet ID: ").strip()
            if sid:
                run_aws(["ec2", "delete-tags", "--resources", sid,
                          "--tags", "Key=FISTarget", "Key=FISAZRole"])
                print(f"{GREEN}FIS tags removed.{NC}")

        elif choice == "9":
            az = input("Enter AZ: ").strip()
            sids = run_aws(["ec2", "describe-subnets",
                              "--filters", f"Name=availability-zone,Values={az}",
                              "Name=tag:FISTarget,Values=True",
                              "--query", "Subnets[].SubnetId", "--output", "text"])
            if not sids:
                print(f"{YELLOW}No FIS-tagged subnets in {az}.{NC}")
                continue
            for sid in sids.split():
                run_aws(["ec2", "delete-tags", "--resources", sid,
                          "--tags", "Key=FISTarget", "Key=FISAZRole"])
                print(f"{GREEN}Removed tags from {sid}{NC}")

        elif choice == "10":
            sids = run_aws(["ec2", "describe-subnets",
                              "--filters", "Name=tag:FISTarget,Values=True",
                              "--query", "Subnets[].SubnetId", "--output", "text"])
            if not sids:
                print(f"{YELLOW}No FIS-tagged subnets.{NC}")
                continue
            sid_list = sids.split()
            if confirm(f"{RED}Remove FIS tags from ALL {len(sid_list)} subnet(s)?{NC}", required="YES"):
                for sid in sid_list:
                    run_aws(["ec2", "delete-tags", "--resources", sid,
                              "--tags", "Key=FISTarget", "Key=FISAZRole"])
                    print(f"{GREEN}Removed tags from {sid}{NC}")

        elif choice == "11":
            break


# ---------------------------------------------------------------------------
# Advanced: Infrastructure (one-time plumbing)
# ---------------------------------------------------------------------------

def update_stack(stack_name=STACK_NAME_DEFAULT):
    """Deploy or update the FIS CloudFormation stack."""
    banner("CloudFormation Stack Deploy/Update")
    print(f"Stack Name: {stack_name}")
    print(f"Template:   {CFN_TEMPLATE}\n")

    try:
        result = subprocess.run(
            ["aws"] + (["--profile", AWS_PROFILE] if AWS_PROFILE else []) +
            ["cloudformation", "describe-stacks", "--stack-name", stack_name],
            capture_output=True, text=True, check=False)
        if result.returncode == 0:
            exists = True
        elif "does not exist" in result.stderr:
            exists = False
        else:
            # Unexpected error (auth, network, etc.) — don't guess
            print(f"{RED}Error checking stack:{NC}")
            print(result.stderr.strip())
            return
    except Exception as e:
        print(f"{RED}Error: {e}{NC}")
        return

    if exists:
        print("Stack exists. Updating...")
        try:
            run_aws(["cloudformation", "update-stack",
                      "--stack-name", stack_name,
                      "--template-body", f"file://{CFN_TEMPLATE}",
                      "--capabilities", "CAPABILITY_NAMED_IAM"])
        except AWSError as e:
            msg = str(e)
            if "No updates are to be performed" in msg:
                print(f"{GREEN}Stack is already up to date.{NC}")
                return
            print(f"{RED}Update failed:{NC}")
            print(f"  {msg}")
            return
        print("Waiting for stack update to complete...")
        run_aws(["cloudformation", "wait", "stack-update-complete", "--stack-name", stack_name])
        print(f"{GREEN}Stack updated successfully!{NC}")
    else:
        print("Stack does not exist. Creating...")
        try:
            run_aws(["cloudformation", "create-stack",
                      "--stack-name", stack_name,
                      "--template-body", f"file://{CFN_TEMPLATE}",
                      "--capabilities", "CAPABILITY_NAMED_IAM"])
        except AWSError as e:
            print(f"{RED}Create failed:{NC}")
            print(f"  {e}")
            return
        print("Waiting for stack creation to complete...")
        run_aws(["cloudformation", "wait", "stack-create-complete", "--stack-name", stack_name])
        print(f"{GREEN}Stack created successfully!{NC}")

    print("\nStack Outputs:")
    output = run_aws(["cloudformation", "describe-stacks",
                       "--stack-name", stack_name,
                       "--query", "Stacks[0].Outputs[*].[OutputKey,OutputValue]",
                       "--output", "table"])
    print(output)


def deploy_ssm_document():
    """Deploy or update the SQL DAG Primary Discovery SSM document."""
    banner("SSM Document Deployment")
    print(f"Document: {SSM_DOCUMENT_NAME}")
    print(f"File:     {SSM_DOCUMENT_FILE}\n")

    try:
        run_aws(["ssm", "describe-document", "--name", SSM_DOCUMENT_NAME])
        exists = True
    except AWSError:
        exists = False

    if exists:
        print("Document exists. Updating to latest version...")
        run_aws(["ssm", "update-document",
                  "--name", SSM_DOCUMENT_NAME,
                  "--document-format", "YAML",
                  "--content", f"file://{SSM_DOCUMENT_FILE}",
                  "--document-version", "$LATEST"])
        latest = run_aws(["ssm", "describe-document",
                           "--name", SSM_DOCUMENT_NAME,
                           "--query", "Document.LatestVersion",
                           "--output", "text"])
        run_aws(["ssm", "update-document-default-version",
                  "--name", SSM_DOCUMENT_NAME,
                  "--document-version", latest])
        print(f"{GREEN}SSM Document updated to version {latest}!{NC}")
    else:
        print("Creating new document...")
        run_aws(["ssm", "create-document",
                  "--name", SSM_DOCUMENT_NAME,
                  "--document-type", "Command",
                  "--document-format", "YAML",
                  "--content", f"file://{SSM_DOCUMENT_FILE}",
                  "--tags", "Key=Application,Value=OIH", "Key=Purpose,Value=HA-DR-Testing"])
        print(f"{GREEN}SSM Document created successfully!{NC}")


def deploy_disk_activity(instance_id):
    """Deploy disk_activity.ps1 to a Windows instance via SSM."""
    banner("Deploy Disk Activity Script")

    if not os.path.isfile(DISK_ACTIVITY_SCRIPT):
        print(f"{RED}Script not found: {DISK_ACTIVITY_SCRIPT}{NC}")
        return

    print(f"Instance: {instance_id}")
    print(f"Script:   {DISK_ACTIVITY_SCRIPT}\n")

    with open(DISK_ACTIVITY_SCRIPT, "rb") as f:
        encoded = base64.b64encode(f.read()).decode()

    commands = [
        "if (-not (Test-Path C:\\\\temp)) { New-Item -Path C:\\\\temp -ItemType Directory -Force | Out-Null }",
        f'$scriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("{encoded}"))',
        '$scriptContent | Out-File -FilePath C:\\temp\\disk_activity.ps1 -Encoding UTF8',
        'Write-Host "Script deployed to C:\\temp\\disk_activity.ps1"',
    ]

    cmd_id = run_aws([
        "ssm", "send-command",
        "--instance-ids", instance_id,
        "--document-name", "AWS-RunPowerShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--comment", "Deploy disk I/O activity generator script",
        "--query", "Command.CommandId",
        "--output", "text"
    ])

    print(f"Command ID: {cmd_id}")
    print("Waiting for completion...")

    run_aws(["ssm", "wait", "command-executed",
              "--command-id", cmd_id, "--instance-id", instance_id])

    output = run_aws(["ssm", "get-command-invocation",
                        "--command-id", cmd_id, "--instance-id", instance_id,
                        "--query", "StandardOutputContent", "--output", "text"])
    print(f"\n{output}")
    print(f"\n{GREEN}Script deployed to C:\\temp\\disk_activity.ps1{NC}")


def delete_old_templates():
    """Delete manually-created FIS templates (pre-CloudFormation)."""
    banner("Delete Old FIS Experiment Templates")

    output = run_aws(["fis", "list-experiment-templates",
                        "--query", "experimentTemplates[].[id,description,tags.Name]",
                        "--output", "table"])
    print("Current templates:")
    print(output)

    if not confirm(f"\n{RED}Delete ALL listed templates?{NC}", required="YES"):
        print("Cancelled.")
        return

    ids = run_aws(["fis", "list-experiment-templates",
                     "--query", "experimentTemplates[].id", "--output", "text"])
    if not ids:
        print("No templates found.")
        return

    for tid in ids.split():
        try:
            run_aws(["fis", "delete-experiment-template", "--id", tid])
            print(f"{GREEN}Deleted {tid}{NC}")
        except AWSError:
            print(f"{RED}Failed to delete {tid}{NC}")

    print(f"\n{GREEN}Done. Run 'update-stack' to create CloudFormation-managed templates.{NC}")


def advanced_menu():
    """Sub-menu for infrastructure/one-time operations."""
    while True:
        banner("Advanced / Infrastructure")
        print(f"  {DIM}These are one-time setup tasks. Most users won't need these.{NC}\n")
        print("  1) Deploy/Update CloudFormation stack")
        print("  2) Deploy SSM document (SQL DAG discovery)")
        print("  3) Deploy disk activity script to instance")
        print("  4) Delete old (non-CFN) experiment templates")
        print("\n  5) Back to main menu\n")

        choice = input("Choose (1-5): ").strip()

        if choice == "1":
            stack = input(f"Stack name [{STACK_NAME_DEFAULT}]: ").strip() or STACK_NAME_DEFAULT
            update_stack(stack)
        elif choice == "2":
            deploy_ssm_document()
        elif choice == "3":
            iid = input("Enter instance ID: ").strip()
            if iid:
                deploy_disk_activity(iid)
        elif choice == "4":
            delete_old_templates()
        elif choice == "5":
            break


# ---------------------------------------------------------------------------
# Main Menu
# ---------------------------------------------------------------------------

def show_help():
    """Show a beginner-friendly explanation of FIS and this tool."""
    banner("What is FIS? (Quick Guide)")
    print(f"""  {BOLD}AWS Fault Injection Service (FIS){NC} lets us intentionally break things
  in a controlled way so we can verify our application recovers properly.

  {BOLD}Why do we do this?{NC}
  OIH runs SQL Server in a Distributed Availability Group (DAG) across
  on-premises and AWS. We need to know that if an AWS component fails,
  the system fails over correctly and recovers when the fault is resolved.

  {BOLD}What kinds of faults can we inject?{NC}

    {YELLOW}EBS I/O Pause{NC}  — Freezes disk access on database server volumes.
                     The DB engine hangs as if the storage layer died.

    {YELLOW}EC2 Stop{NC}       — Powers off database server instances, then restarts.
                     Simulates a server crash / unexpected reboot.

    {YELLOW}Network Disruption{NC} — Blocks all traffic to/from subnets in an AZ.
                     Simulates a complete availability zone outage.

  {BOLD}How experiments work:{NC}
    1. You pick an experiment and set a duration (e.g., 5 minutes).
    2. FIS injects the fault — resources are impaired for that duration.
    3. When the timer expires, FIS automatically rolls back the fault.
    4. You verify the application recovered (check the ALB, DAG status, etc).

  {BOLD}Key vocabulary:{NC}
    {CYAN}Experiment Template{NC} — A saved definition of what fault to inject and on what.
    {CYAN}Experiment{NC}          — A single run of a template (has a unique ID like EXP-abc123).
    {CYAN}FISTarget tag{NC}       — EC2/EBS/Subnet tag that marks a resource as a FIS target.
    {CYAN}FISDBRole tag{NC}       — Primary or Secondary, identifies which DB server role.
    {CYAN}FISAZRole tag{NC}       — Primary, Secondary, or Tertiary AZ designation.

  {BOLD}Our AZ layout:{NC}
    Primary AZ:   us-west-2b  (Primary SQL Server)
    Secondary AZ: us-west-2a  (Secondary SQL Server)
    Tertiary AZ:  us-west-2c  (no OIH databases)
""")
    input(f"  {DIM}Press Enter to return to the main menu...{NC}")


def interactive_menu():
    """Main interactive menu — day-to-day operations first."""
    while True:
        banner("OIH FIS Manager")
        if AWS_PROFILE:
            print(f"  {DIM}AWS Profile: {AWS_PROFILE}{NC}\n")

        print(f"{BLUE}Experiments:{NC}")
        print("  1) Run an experiment")
        print("  2) Check experiment status")
        print("  3) Watch experiment (live follow)")
        print("  4) List recent experiments")
        print(f"\n{BLUE}Targeting:{NC}")
        print("  5) Dry-run targeting check")
        print(f"\n{BLUE}Tagging:{NC}")
        print("  6) Tag EC2 instances / EBS volumes")
        print("  7) Tag subnets (network disruption)")
        print(f"\n{BLUE}Advanced:{NC}")
        print("  8) Infrastructure / one-time setup")
        print(f"\n  {CYAN}?) What is FIS? (quick guide for the team){NC}")
        print("  9) Exit\n")

        choice = input("Choose (1-9, ?): ").strip()

        if choice == "1":
            run_experiment()
        elif choice == "2":
            eid = pick_experiment()
            if eid:
                show_experiment_status(eid)
        elif choice == "3":
            eid = pick_experiment()
            if eid:
                interval = input("Poll interval seconds [5]: ").strip()
                try:
                    interval = int(interval) if interval else 5
                except ValueError:
                    interval = 5
                watch_experiment(eid, interval)
        elif choice == "4":
            list_experiments()
        elif choice == "5":
            dry_run_targeting()
        elif choice == "6":
            tag_resources()
        elif choice == "7":
            tag_subnets()
        elif choice == "8":
            advanced_menu()
        elif choice == "?":
            show_help()
        elif choice == "9":
            print("Goodbye!")
            sys.exit(0)
        else:
            print(f"{RED}Invalid option. Type '?' for help.{NC}")


# ---------------------------------------------------------------------------
# CLI Entry Point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="OIH FIS Manager - Unified tool for Fault Injection Service operations",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Commands:
  (none)            Interactive menu
  run               Run an FIS experiment (with configurable duration)
  status <ID>       Check experiment status (one-shot)
  watch <ID>        Follow experiment until done (live, like tail -f)
  list              List recent experiments
  dry-run           Targeting dry-run check
  tag-resources     Tag EC2/EBS resources
  tag-subnets       Tag subnets for network disruption

Advanced (one-time setup):
  update-stack      Deploy/update CloudFormation stack
  deploy-ssm        Deploy SSM document
  deploy-disk       Deploy disk activity script
  delete-templates  Delete old experiment templates

Examples:
  python fis_manager.py                           # Interactive menu
  python fis_manager.py run                       # Launch an experiment
  python fis_manager.py status EXP-abc123         # One-shot status
  python fis_manager.py watch EXP-abc123          # Follow until done
  python fis_manager.py --profile prod run        # Use 'prod' AWS profile
  python fis_manager.py list                      # Recent experiments
""")

    parser.add_argument("command", nargs="?", default=None,
                        choices=["run", "status", "watch", "list",
                                 "dry-run", "tag-resources", "tag-subnets",
                                 "update-stack", "deploy-ssm", "deploy-disk",
                                 "delete-templates"])
    parser.add_argument("experiment_id", nargs="?", default=None,
                        help="Experiment ID (for status/watch commands)")
    parser.add_argument("--profile", default=None,
                        help="AWS CLI profile to use (default: default profile)")
    parser.add_argument("--stack-name", default=STACK_NAME_DEFAULT,
                        help=f"CloudFormation stack name (default: {STACK_NAME_DEFAULT})")
    parser.add_argument("--instance-id", help="EC2 instance ID (for deploy-disk)")
    parser.add_argument("--interval", type=int, default=5,
                        help="Poll interval in seconds for watch command (default: 5)")

    args = parser.parse_args()

    # Set global profile
    global AWS_PROFILE
    AWS_PROFILE = args.profile

    if args.command is None:
        interactive_menu()
    elif args.command == "run":
        run_experiment()
    elif args.command == "status":
        if not args.experiment_id:
            print(f"{RED}Usage: fis_manager.py status <EXPERIMENT_ID>{NC}")
            sys.exit(1)
        show_experiment_status(args.experiment_id)
    elif args.command == "watch":
        if not args.experiment_id:
            print(f"{RED}Usage: fis_manager.py watch <EXPERIMENT_ID>{NC}")
            sys.exit(1)
        watch_experiment(args.experiment_id, args.interval)
    elif args.command == "list":
        list_experiments()
    elif args.command == "dry-run":
        dry_run_targeting()
    elif args.command == "tag-resources":
        tag_resources()
    elif args.command == "tag-subnets":
        tag_subnets()
    elif args.command == "update-stack":
        update_stack(args.stack_name)
    elif args.command == "deploy-ssm":
        deploy_ssm_document()
    elif args.command == "deploy-disk":
        if not args.instance_id:
            print(f"{RED}--instance-id required for deploy-disk{NC}")
            sys.exit(1)
        deploy_disk_activity(args.instance_id)
    elif args.command == "delete-templates":
        delete_old_templates()


if __name__ == "__main__":
    try:
        main()
    except AWSError as e:
        print(f"\n{RED}AWS Error:{NC} {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print(f"\n{YELLOW}Interrupted.{NC}")
        sys.exit(130)
    except EOFError:
        print(f"\n{YELLOW}Input closed. Exiting.{NC}")
        sys.exit(0)
    except json.JSONDecodeError as e:
        print(f"\n{RED}Unexpected response from AWS (not valid JSON).{NC}")
        print(f"  {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{RED}Unexpected error:{NC} {e}")
        print("  If this keeps happening, check your AWS credentials and try again.")
        sys.exit(1)
