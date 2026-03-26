# CloudFormation Discovery, Analysis, and AI Assessment Pipeline

This project implements a **three-stage, automated pipeline** to:

1. **Discover** CloudFormation usage across a GitHub organization  
2. **Analyze** and classify CloudFormation repositories  
3. **Assess** each repository using an AI agent and produce structured migration guidance toward Terraform

The end result is a **repeatable, auditable, and scalable assessment workflow** that transforms raw CloudFormation repositories into actionable modernization insights.

---

## High-Level Workflow

```
search.sh  →  analyze.sh  →  assessment.sh
```

Each step produces an artifact that becomes the input for the next stage.

---

## Stage 1 — Repository Discovery (`search.sh`)

### Purpose
Identify all active repositories in a GitHub organization that contain **CloudFormation templates**.

### What This Script Does

1. Retrieves all **non-archived repositories** in the organization
2. Clones each repository **shallowly**
3. Scans the contents for the CloudFormation signature:
   ```
   AWSTemplateFormatVersion
   ```
4. Records only repositories that contain CloudFormation
5. Cleans up all temporary files after each scan

### Inputs
- GitHub organization name
- GitHub CLI (`gh`) authentication

### Outputs
- ```
  cfn-repos.txt
  ```
  A newline-delimited list of repositories containing CloudFormation

### Why This Step Exists
- Prevents unnecessary cloning and analysis
- Scales safely to thousands of repositories
- Establishes a **clean, deterministic candidate list**

---

## Stage 2 — Repository Analysis (`analyze.sh`)

### Purpose
Inspect each CloudFormation-enabled repository and produce a **classification and metadata report**.

### What This Script Does

For each repository found in `cfn-repos.txt`:

1. Fetches repository metadata
   - Created date
   - Last push date
   - Default branch
2. Clones the default branch
3. Locates all CloudFormation templates
   - YAML and JSON formats
4. Counts CloudFormation files
5. Categorizes infrastructure intent using weighted signals:
   - Platform
   - Application
   - Data
   - Other
6. Outputs a CSV summarizing the repository

### Categorization Logic

| Category     | Examples of Signals |
|--------------|---------------------|
| Platform     | CodePipeline, IAM, SSM, StackSets |
| Application  | Lambda, ECS, EKS, ALB, API Gateway |
| Data         | RDS, DynamoDB, Glue, Redshift |
| Other        | Unclassified remainder |

Percentages are calculated from weighted signals to reflect **dominant architectural intent**.

### Outputs
- ```
  cfn-repo-analysis.csv
  ```

Example columns:
```
repo_name,
created_at,
last_pushed_at,
default_branch,
cfn_file_count,
platform_pct,
application_pct,
data_pct,
other_pct
```

### Why This Step Exists
- Provides **portfolio-level visibility**
- Enables filtering and prioritization
- Creates a deterministic input for AI-driven analysis

---

## Stage 3 — AI-Based Assessment (`assessment.sh`)

### Purpose
Generate **structured, human-readable migration assessments** for each CloudFormation repository using an AI agent.

### What This Script Does

Driven entirely by `cfn-repo-analysis.csv`:

1. Skips:
   - Excluded repository prefixes
      - aws-*
      - ccsp-*
      - pge-ecm-*
   - Repositories with zero CFN files
   - Repositories already assessed
2. Clones the target repository
3. Re-validates CloudFormation templates
4. Chunks templates safely for AI input
5. Sends each chunk to an AWS Bedrock Agent
6. Normalizes responses into a strict format
7. Consolidates multi-chunk analyses into a single report
8. Writes final results as Markdown

### AI Output Contract

Every assessment strictly follows this structure:

```
# Repository Assessment: <repo>

## 1. Overview
## 2. Architecture Summary
## 3. Identified Resources
## 4. Issues & Risks
## 5. Technical Debt
## 6. Terraform Migration Complexity
## 7. Recommended Migration Path
```

Missing information is explicitly labeled:
```
Not Observed
```

### Outputs
- One Markdown file per repository:
  ```
  results/<repo>_agent_results.md
  ```

### Why This Step Exists
- Produces **consistent, executive-ready assessments**
- Converts raw CFN into migration guidance
- Enables parallel, resumable execution

---

## Design Principles

### Deterministic & Idempotent
- Safe to rerun
- Skips completed work automatically

### Scalable
- Handles thousands of repositories
- Chunking avoids payload limits

### Clean Boundaries
- Each stage produces a concrete artifact
- No hidden coupling between steps

### Enterprise-Ready
- Audit-friendly
- CSV-driven orchestration
- Clear exclusion and control points

---

## Directory Structure

```
.
├── search.sh
├── analyze.sh
├── assessment.sh
├── cfn-repos.txt
├── cfn-repo-analysis.csv
├── results/
│   ├── repo-a_agent_results.md
│   └── repo-b_agent_results.md
└── __temp_dirs__/
```

Temporary directories are created and destroyed automatically.

---

## End Result

This pipeline transforms:

```
Unstructured CloudFormation repositories
```

into:

```
Actionable, Terraform migration intelligence
```

at **organization scale**, with **repeatability**, **consistency**, and **enterprise governance** built in from the start.

