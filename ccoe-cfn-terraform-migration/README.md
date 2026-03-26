# CloudFormation Discovery, Analysis, and AI Assessment Pipeline

A three-stage pipeline that discovers CloudFormation usage across PG&E's GitHub organization, classifies each repository, and generates structured Terraform migration assessments using an AWS Bedrock agent.

---

## Pipeline Flow

```
search.sh  →  analyze.sh  →  assessment.sh
```

Each stage produces an artifact that becomes the input for the next. All scripts are idempotent — safe to re-run without duplicating work.

---

## Prerequisites

| Tool | Used By | Purpose |
|------|---------|---------|
| `gh` (GitHub CLI) | search.sh, analyze.sh | Repo listing, metadata fetching |
| `rg` (ripgrep) | search.sh | Fast content search |
| `git` | all scripts | Shallow cloning |
| `jq` | analyze.sh | JSON parsing |
| `aws` CLI | assessment.sh | SSO auth, STS pre-flight check |
| Python 3.11+ | assessment.sh | Bedrock agent invocation |
| `boto3` | invoke_agent.py | AWS Bedrock SDK |

---

## Stage 1 — Repository Discovery (`search.sh`)

Finds all non-archived repos in the `pgetech` GitHub org that contain `AWSTemplateFormatVersion`.

```bash
./search.sh
```

**How it works:**
1. Fetches the full repo list via `gh repo list` (or reuses `repos.txt` if it exists)
2. Shallow-clones each repo, searches with `rg`, deletes the clone
3. Appends matches to `cfn-repos.txt`
4. Tracks progress in `__scan_progress.txt` for resume on interruption

**Output:** `cfn-repos.txt` — one repo name per line

---

## Stage 2 — Repository Analysis (`analyze.sh`)

Classifies each CloudFormation repo and extracts migration complexity signals. Produces two CSVs.

```bash
./analyze.sh
```

**How it works:**
1. For each repo in `cfn-repos.txt`, fetches metadata (created date, last push, default branch)
2. Clones and locates all CFN templates (YAML, JSON, .template — excludes `node_modules/`, `vendor/`, `.terraform/`)
3. Categorizes AWS resource types using weighted signals
4. Extracts migration complexity signals from the templates
5. Checks for existing Terraform (`.tf` files) in the repo

### Output 1 — `cfn-repo-analysis.csv` (what exists)

```
repo_name,created_at,last_pushed_at,default_branch,cfn_file_count,platform_pct,application_pct,data_pct,other_pct
```

| Category | Strong Signals (4x) | Supporting Signals (1x) |
|----------|---------------------|------------------------|
| Platform | CodePipeline, CodeBuild, CodeDeploy, StackSets | IAM, SSM, Logs, S3 (0.5x) |
| Application | ECS, EKS, Lambda, ALB, API Gateway | — |
| Data | RDS, DynamoDB, Glue, Redshift, Kinesis, Athena | — |

### Output 2 — `cfn-migration-complexity.csv` (how hard to convert)

```
repo_name,total_resources,resource_types,nested_stacks,cross_stack_refs,custom_resources,sam_transforms,parameters,conditions,has_terraform,cfn_lines,aws_account_ids,app_ids
```

| Column | What It Tells You |
|--------|-------------------|
| `total_resources` | Number of `Type: AWS::*` resource declarations across all templates |
| `resource_types` | Pipe-delimited list of unique AWS resource types (e.g. `AWS::EC2::Instance\|AWS::Lambda::Function`) |
| `nested_stacks` | Count of `AWS::CloudFormation::Stack` — each becomes a Terraform module |
| `cross_stack_refs` | Count of `Fn::ImportValue` / `!ImportValue` — need `terraform_remote_state` or data sources |
| `custom_resources` | Count of `AWS::CloudFormation::CustomResource` / `Custom::*` — no direct Terraform equivalent |
| `sam_transforms` | Whether SAM (`AWS::Serverless::`) is used — each SAM resource expands to multiple TF resources |
| `parameters` | Count of `Parameters:` sections — become Terraform `variable` blocks |
| `conditions` | Count of `Fn::If` / `!If` / `Conditions:` — become `count`/`for_each` ternaries |
| `has_terraform` | Whether `.tf` files already exist in the repo |
| `cfn_lines` | Total lines of CloudFormation code |
| `aws_account_ids` | Pipe-delimited list of unique 12-digit account IDs extracted from ARNs |
| `app_ids` | Pipe-delimited list of unique app identifiers from CFN tag values (`Application`, `AppName`, `AppId`, `Project`) |

Both files are keyed on `repo_name` and joinable in Excel or downstream scripts.

---

## Stage 3 — AI Assessment (`assessment.sh`)

Generates structured migration assessments using an AWS Bedrock agent.

```bash
# Requires active AWS SSO session
aws sso login --profile pge-sso
./assessment.sh
```

**How it works:**
1. Reads `cfn-repo-analysis.csv`, skips excluded prefixes (`aws-*`, `ccsp-*`, `pge-ecm-*`) and already-assessed repos
2. Clones each repo, bundles CFN files into text chunks
3. Sends each chunk to the Bedrock agent via `invoke_agent.py`
4. Normalizes the response into a strict 7-section format via `normalize.py`
5. For multi-chunk repos (>25 files), runs a consolidation pass to merge partial results

**Output:** `results/{repo}_agent_results.md` — one file per repo

### Assessment Format

Every assessment follows this structure:

```markdown
# Repository Assessment: {repo}

## 1. Overview
## 2. Architecture Summary
## 3. Identified Resources
## 4. Issues & Risks
## 5. Technical Debt
## 6. Terraform Migration Complexity
## 7. Recommended Migration Path
```

Missing sections are filled with `Not Observed`.

### Chunking

| Scenario | Behavior |
|----------|----------|
| <= 25 CFN files | Single chunk, single agent call |
| > 25 CFN files | Split into chunks of 15, analyzed separately, then consolidated |
| Chunk > 180KB | Trimmed to 180KB before sending |

### AWS Configuration

| Setting | Value |
|---------|-------|
| Region | `us-east-2` |
| Profile | `pge-sso` (override with `AWS_PROFILE` env var) |
| Agent ID | `U9QDABQJQM` |
| Agent Alias | `FVBEN4YT6P` |

---

## Re-run Behavior

All scripts skip completed work automatically:

| Script | Skip Logic |
|--------|-----------|
| `search.sh` | Skips repos in `cfn-repos.txt` or `__scan_progress.txt`. Reuses `repos.txt`. |
| `analyze.sh` | Skips repos already in both `cfn-repo-analysis.csv` and `cfn-migration-complexity.csv`. |
| `assessment.sh` | Skips repos with existing non-empty `results/{repo}_agent_results.md`. |

### Full Clean Re-run

Delete all generated files and start from scratch:

```bash
rm -f repos.txt cfn-repos.txt __scan_progress.txt cfn-repo-analysis.csv cfn-migration-complexity.csv
rm -rf results/
```

---

## File Layout

```
search.sh                  — Stage 1: discover CFN repos
analyze.sh                 — Stage 2: classify and produce CSVs
assessment.sh              — Stage 3: AI assessment via Bedrock
invoke_agent.py            — Bedrock agent invocation + output normalization
normalize.py               — Markdown section normalizer (shared)
repos.txt                  — All non-archived repos (generated)
cfn-repos.txt              — Repos containing CFN (generated)
cfn-repo-analysis.csv      — Analysis CSV: metadata + categories (generated)
cfn-migration-complexity.csv — Complexity CSV: migration signals (generated)
__scan_progress.txt        — Resume tracker for search.sh (generated)
results/                   — Per-repo assessment markdown (generated)
```
