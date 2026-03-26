"""Invoke a Bedrock agent and write the normalized result to a file."""

import argparse
import uuid

import boto3
from botocore.config import Config

from normalize import normalize


def invoke(agent_id: str, agent_alias_id: str, region: str, prompt: str) -> str:
    config = Config(read_timeout=300, connect_timeout=30)
    client = boto3.client(
        "bedrock-agent-runtime",
        region_name=region,
        config=config,
    )

    response = client.invoke_agent(
        agentId=agent_id,
        agentAliasId=agent_alias_id,
        sessionId=str(uuid.uuid4()),
        inputText=prompt,
    )

    return "".join(
        event["chunk"]["bytes"].decode("utf-8", errors="replace")
        for event in response.get("completion", [])
        if "chunk" in event
    )


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--agent-id", required=True)
    parser.add_argument("--agent-alias-id", required=True)
    parser.add_argument("--region", required=True)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--input-file", required=True, help="File containing CFN content or chunk analyses")
    parser.add_argument("--output-file", required=True, help="Where to write normalized result")
    parser.add_argument("--mode", choices=["chunk", "consolidate"], default="chunk")
    parser.add_argument("--chunk-num", type=int, default=1)
    parser.add_argument("--total-chunks", type=int, default=1)
    args = parser.parse_args()

    input_text = open(args.input_file, encoding="utf-8", errors="replace").read()

    if args.mode == "chunk":
        prompt = f"""You are analyzing PARTIAL CloudFormation input (chunk {args.chunk_num} of {args.total_chunks}).

You MUST follow the REQUIRED OUTPUT FORMAT exactly.
Do NOT rename, reorder, omit, or add sections.
If information is missing, output Not Observed.

REQUIRED OUTPUT FORMAT:

# Repository Assessment: {args.repo}

## 1. Overview
## 2. Architecture Summary
## 3. Identified Resources
## 4. Issues & Risks
## 5. Technical Debt
## 6. Terraform Migration Complexity
## 7. Recommended Migration Path

BEGIN CLOUDFORMATION INPUT
{input_text}
END CLOUDFORMATION INPUT
"""
    else:
        prompt = f"""You are consolidating multiple PARTIAL repository assessments.

You MUST preserve the REQUIRED OUTPUT FORMAT exactly.
Do NOT invent data.
If a section cannot be confidently derived, output Not Observed.

REQUIRED OUTPUT FORMAT:

# Repository Assessment: {args.repo}

## 1. Overview
## 2. Architecture Summary
## 3. Identified Resources
## 4. Issues & Risks
## 5. Technical Debt
## 6. Terraform Migration Complexity
## 7. Recommended Migration Path

BEGIN ANALYSIS INPUT
{input_text}
END ANALYSIS INPUT
"""

    raw = invoke(args.agent_id, args.agent_alias_id, args.region, prompt)
    normalized = normalize(raw, args.repo)
    open(args.output_file, "w", encoding="utf-8").write(normalized)


if __name__ == "__main__":
    main()
