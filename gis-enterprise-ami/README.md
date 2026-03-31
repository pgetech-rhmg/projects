# GIS Enterprise AMI

Automated deployment of GIS Enterprise components on AWS using Terraform and AWS Systems Manager (SSM).

This repository contains deployment automation for the following **independent** products:

| Product | Description |
|---------|-------------|
| [FME Flow](#fme-flow) | Distributed server deployment (Core + Engine) with ArcGIS Server |
| [FME Form](#fme-form) | Standalone desktop application deployment |

---

## Table of Contents

- [FME Flow](#fme-flow)
  - [Architecture](#fme-flow-architecture)
  - [CI/CD Pipeline](#fme-flow-cicd-pipeline)
  - [Directory Structure](#fme-flow-directory-structure)
  - [Prerequisites](#fme-flow-prerequisites)
- [FME Form](#fme-form)
  - [Architecture](#fme-form-architecture)
  - [CI/CD Pipeline](#fme-form-cicd-pipeline)
  - [Directory Structure](#fme-form-directory-structure)
  - [Prerequisites](#fme-form-prerequisites)

---
---

# FME Flow

Distributed FME Flow deployment (Core + Engine) with ArcGIS Server on AWS using Terraform and AWS Systems Manager (SSM).

FME Flow is deployed across the following AWS accounts:

| Account | Environment | FME Flow URL |
|---------|-------------|-------------|
| Gas (GOGIS) | Dev | https://go-fme-dev.nonprod.pge.com/fmeserver/ |
| Electric (EOGIS) | Dev | https://eogis-fme-dev.nonprod.pge.com/fmeserver/ |
| Enterprise (ENTGIS) | Dev | https://entgis-fme-dev.nonprod.pge.com/fmeserver/ |

> [!IMPORTANT]
> Currently, FME Engine is **not** installed as a separate machine. Core and Engine are installed on the **same machine**.
> The `InstallEngine` parameter (`Yes`/`No`) controls whether Engine is included during Core installation.

## FME Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        AWS Cloud Environment                        │
│                                                                     │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐   │
│  │  Application  │   │   FME Flow   │◄───│    FME Flow Engine   │   │
│  │  Load Balancer│──>│   Core + Web │    │    + ArcGIS Server   │   │
│  │  (ALB)        │   │   Services   │    │                      │   │
│  └──────────────┘    └──────┬───────┘    └──────────┬───────────┘   │
│                             │                        │              │
│                    ┌────────┴────────┐               │              │
│                    │                 │               │              │
│              ┌─────▼─────┐    ┌─────▼──────────────▼────────┐       │
│              │  Amazon   │    │         Amazon FSx          │       │
│              │  RDS      │    │    (Shared Storage - used by│       │
│              │  PostgreSQL│   │     both Core and Engine)   │       │
│              └───────────┘    └─────────────────────────────┘       │
└─────────────────────────────────────────────────────────────────────┘
```

## FME Flow CI/CD Pipeline

The deployment follows a three-stage pipeline pattern:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    FME Flow Complete CI/CD Pipeline                          │
│                                                                              │
│  ┌─────────────────┐    ┌─────────────────┐    ┌────────────────────────┐   │
│  │   Stage 1        │    │   Stage 2        │    │   Stage 3             │   │
│  │   TF Workspace:  │    │   TF Workspace:  │    │                       │   │
│  │   fmeflow-ssm    │──▶│   fmeflow-infra  │───▶│   SSM Execution       │   │
│  │                  │    │                   │    │                      │   │
│  │  Create:         │    │  Create:          │    │  Execute:            │   │
│  │  ✓ ArcGIS Server │    │  ✓ EC2 (Core)    │    │  3a. Core Automation │   │
│  │    Command Doc   │    │  ✓ EC2 (Engine)  │    │      ├─ ArcGIS Server │   │
│  │  ✓ FME Core      │    │  ✓ RDS PostgreSQL│    │      └─ FME Flow Core │  │
│  │    Command Doc   │    │  ✓ FSx Storage   │    │          │            │  │
│  │  ✓ FME Engine    │    │  ✓ ALB           │    │          ▼            │  │
│  │    Command Doc   │    │  ✓ Secrets       │    │  3b. Engine Automation │ │
│  │  ✓ Core          │    │  ✓ Security Grps │    │      ├─ ArcGIS Server │  │
│  │    Automation Doc│    │                   │    │      └─ FME Engine    │   │
│  │  ✓ Engine        │    │                   │    │                      │   │
│  │    Automation Doc│    │                   │    │                      │   │
│  └─────────────────┘    └─────────────────┘    └────────────────────────┘   │
│                                                                              │
│  Duration: ~2 min         Duration: ~15 min      Duration: ~45-60 min        │
│  Total Estimated Duration: ~60-75 minutes                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### FME Flow Stage 1: SSM Document Deployment

**Terraform Workspace:** `fmeflow-ssm-<environment>`

Deploys SSM Command and Automation documents using Terraform.

```
┌─────────────────────────────────────────────────┐
│        Stage 1: SSM Document Deployment          │
│        Workspace: fmeflow-ssm-gogis-dev          │
│                                                   │
│  terraform plan -var-file=terraform-gogis-dev.tfvars
│  terraform apply -var-file=terraform-gogis-dev.tfvars
│                                                   │
│  SSM Documents Created:                           │
│  ├── Command: arcgis-server-115-windows-install   │
│  │   (ArcGIS Server installation steps)           │
│  │                                                │
│  ├── Command: fmeflow-core-windows-command        │
│  │   (FME Flow Core installation steps)           │
│  │                                                │
│  ├── Command: fmeflow-engine-windows-command      │
│  │   (FME Flow Engine installation steps)         │
│  │                                                │
│  ├── Automation: arcgis-fme-core-windows-install  │
│  │   (Orchestrates: ArcGIS Server → FME Core)     │
│  │                                                │
│  └── Automation: arcgis-fme-engine-windows-install│
│      (Orchestrates: ArcGIS Server → FME Engine)   │
└─────────────────────────────────────────────────┘
```

---

### FME Flow Stage 2: Infrastructure Provisioning

**Terraform Workspace:** `fmeflow-infra-<environment>`

Provisions all AWS infrastructure required for FME Flow.

```
┌─────────────────────────────────────────────────┐
│        Stage 2: FME Flow Infrastructure          │
│        Workspace: fmeflow-infra-gogis-dev        │
│                                                   │
│  terraform plan -var-file=terraform-gogis-dev.tfvars
│  terraform apply -var-file=terraform-gogis-dev.tfvars
│                                                   │
│  Resources Created:                               │
│  ├── EC2: FME Flow Core Instance                 │
│  ├── EC2: FME Flow Engine Instance(s)            │
│  ├── RDS: PostgreSQL Aurora Cluster              │
│  ├── FSx: Windows File System (Shared Storage)   │
│  ├── ALB: Application Load Balancer              │
│  ├── Route53: DNS Records                        │
│  ├── Security Groups: Core, Engine, RDS, FSx     │
│  ├── Secrets Manager: DB Admin Password          │
│  ├── Secrets Manager: FME DB User Password       │
│  ├── IAM: Instance Roles & Policies              │
│  └── S3: Installer Bucket (if not exists)        │
└─────────────────────────────────────────────────┘
```

---

### FME Flow Stage 3: SSM Automation Execution

Executes the SSM Automation documents to install and configure FME Flow using infrastructure outputs from Stage 2.

```
┌──────────────────────────────────────────────────────────────────────┐
│        Stage 3: SSM Automation Execution                             │
│                                                                      │
│  Step 3a: Execute Core Automation                                    │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  Document: arcgis-fme-core-windows-install                     │  │
│  │  Target: Core EC2 Instance                                     │  │
│  │                                                                │  │
│  │  Parameters (from Stage 2 outputs):                            │  │
│  │  ├── InstanceId         ← core_instance_id                     │  │
│  │  ├── FsxDnsName         ← fsx_dns_name                         │  │
│  │  ├── InstancePrivateDNS ← core_private_dns                     │  │
│  │  ├── LoadBalancerDNS    ← alb_dns_name                         │  │
│  │  ├── DatabaseEndpoint   ← rds_cluster_endpoint                 │  │
│  │  ├── DBAdminSecret      ← db_admin_secret_name                 │  │
│  │  ├── DBPasswordSecret   ← db_fmeflow_secret_name               │  │
│  │  ├── InstallDrive       ← E: (configurable)                    │  │
│  │  └── InstallEngine      ← Yes/No (configurable)                │  │
│  │                                                                │  │
│  │  Execution Flow:                                               │  │
│  │  ConfigureArcGISServer ──▶ InstallFMEFlowCore                  │  │
│  └────────────────────────────────────────────────────────────────┘  │
│         │                                                            │
│         ▼ (Wait for Core completion)                                 │
│                                                                      │
│  Step 3b: Execute Engine Automation                                  │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  Document: arcgis-fme-engine-windows-install                   │  │
│  │  Target: Engine EC2 Instance(s)                                │  │
│  │                                                                │  │
│  │  Parameters (from Stage 2 outputs):                            │  │
│  │  ├── InstanceId         ← engine_instance_ids                  │  │
│  │  ├── FsxDnsName         ← fsx_dns_name                         │  │
│  │  ├── CoreHostDNSName    ← core_private_dns                     │  │
│  │  ├── InstancePrivateDNS ← engine_private_dns                   │  │
│  │  └── InstallDrive       ← E: (configurable)                    │  │
│  │                                                                │  │
│  │  Execution Flow:                                               │  │
│  │  ConfigureArcGISServer ──▶ InstallFMEEngine                    │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## FME Flow Directory Structure

```
fmeflow/
└── ssm/                                     # SSM Documents (Terraform)
    ├── main.tf                              # SSM document definitions
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tf
    ├── terraform-gogis-dev.tfvars
    ├── terraform-datamigration.tfvars
    └── scripts/
        └── windows/
            ├── ssm-install-configure-fme-core-windows.yml      # FME Core command doc
            ├── ssm-install-configure-fme-engine-windows.yml    # FME Engine command doc
            ├── ssm-configure-arcgis-server-windows.yml         # ArcGIS Server command doc
            ├── ssm-install-arcgis-fme-core-automation.yml      # Core automation doc
            └── ssm-install-arcgis-fme-engine-automation.yml    # Engine automation doc
```

## FME Flow Prerequisites

### AWS Secrets Manager Secrets

| Secret Name | Purpose |
|-------------|---------|
| `rds!cluster-*` | RDS admin password (auto-managed) |
| `fme/db-fmeflow` | FME Flow database user password |
| `fme/admin-fmeflow` | FME Flow Application admin user password |

### AD Groups (Application Access)

| AD Group | Account | Purpose |
|----------|---------|---------|
| `AAD-Apr-A3696-Dev-FME-User` | GOGIS Dev  | Required to access the FME Flow URL for GOGIS  |
| `AAD-Apr-A3605-Dev-FME-User` | ENTGIS Dev | Required to access the FME Flow URL for ENTGIS |
| `AAD-Apr-3695-Dev-FME-User`  | EOGIS Dev  | Required to access the FME Flow URL for EOGIS  |

For a complete inventory of AD groups, refer to the wiki:
🔗 [Elevate AD Group Inventory](https://wiki.comp.pge.com/display/GEOMW2/Elevate+AD+Group+Inventory)

### S3 Bucket Structure

```
elevate-installer/
└── esri/
    ├── fmeflow/
    │   ├── fme-flow-2025.2.2-b25827-win-x64.exe
    │   └── postgresql-18.1-2-windows-x64.exe
    └── arcgis-enterprise/
        └── 11-5/
            ├── ArcGIS_Server_Windows_115_195344.exe
            ├── ArcGIS_Server_Windows_115_195344.exe.001
            └── license/
                └── server/
                    └── ArcGISGISServerAdvanced_ArcGISServer_1556363.ecp
```

### Software Requirements

| Software | Version |
|----------|--------|
| FME Flow | 2025.2.2 (Build 25827) |
| ArcGIS Server | 11.5 |
| PostgreSQL Client | 18.1 |

---
---

# FME Form

Standalone FME Form desktop application deployment on AWS using Terraform and AWS Systems Manager (SSM).

> **Note:** FME Form is currently deployed to the **Data Migration account only**.

### FME Form Licensing

FME Form uses a Floating License Server hosted in the **PGE-Elevate-Dev** AWS account, shared across Gas & Electric accounts.

For license server configuration details, refer to the wiki:
🔗 [FME Form Licensing](https://wiki.comp.pge.com/display/GEOMW2/FME+Form+Licensing)

## FME Form Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                AWS Account: Target Environment                      │
│                (e.g., PGE-Elevate-DataMigration-Test)               │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    FME Form EC2 Instance                     │   │
│  │                    (Windows Server)                          │   │
│  │                                                              │   │
│  │            ┌──────────────┐  ┌──────────────┐                │   │
│  │            │  FME Form    │  │  FME_HOME    │                │   │
│  │            │  2025.2.2    │  │  Environment │                │   │
│  │            │  Desktop App │  │  Variable    │                │   │
│  │            └──────────────┘  └──────────────┘                │   │
│  └──────────────────────────┬───────────────────────────────────┘   │
│                             │                                      │
│  ┌──────────────┐  ┌──────────────┐                                 │
│  │  S3 Bucket   │  │  IAM Role    │                                 │
│  │  (Installer) │  │  (SSM, S3)   │                                 │
│  └──────────────┘  └──────────────┘                                 │
└──────────────────────────────┼──────────────────────────────────────┘
                               │ Cross-Account
┌──────────────────────────────┼──────────────────────────────────────┐
│                AWS Account: PGE-Elevate-Dev                         │
│                (Shared across Gas & Electric)                       │
│                                                                     │
│              ┌───────────────▼──────────────────┐                   │
│              │    Floating License Server        │                  │
│              │(Shared - Gas & Electric, DataMigration)      │       │
│              └──────────────────────────────────┘                   │
└─────────────────────────────────────────────────────────────────────┘
```

## FME Form CI/CD Pipeline

The deployment follows a three-stage pipeline pattern:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                    FME Form Complete CI/CD Pipeline                         │
│                                                                             │
│  ┌─────────────────┐    ┌─────────────────┐    ┌────────────────────────┐   │
│  │   Stage 1        │    │   Stage 2        │    │   Stage 3              │  │
│  │   TF Workspace:  │    │   TF Workspace:  │    │                        │  │
│  │   fmeform-ssm    │───▶│   fmeform-infra │───▶│   SSM Execution        │  │
│  │                   │    │                   │    │                      │  │
│  │  Create:          │    │  Create:          │    │  Execute:            │  │
│  │  ✓ FME Form      │    │  ✓ EC2 Instance  │    │  3a. FME Form Install │  │
│  │    Command Doc   │    │  ✓ Security Grps │    │      ├─ Download       │  │
│  │                   │    │  ✓ IAM Role      │    │      ├─ Install       │  │
│  │                   │    │                   │    │      ├─ Verify        │  │
│  │                   │    │                   │    │      └─ Cleanup       │  │
│  └─────────────────┘    └─────────────────┘    └────────────────────────┘  │
│                                                                             │
│  Duration: ~1 min         Duration: ~10 min      Duration: ~15-20 min      │
│  Total Estimated Duration: ~25-30 minutes                                   │
└────────────────────────────────────────────────────────────────────────────┘
```

### FME Form Stage 1: SSM Document Deployment

**Terraform Workspace:** `fmeform-ssm-<environment>`

```
┌─────────────────────────────────────────────────┐
│        Stage 1: SSM Document Deployment          │
│        Workspace: fmeform-ssm-gogis-dev          │
│                                                   │
│  SSM Documents Created:                           │
│  └── Command: fme-form-windows-install           │
│      (FME Form installation & configuration)     │
└─────────────────────────────────────────────────┘
```

---

### FME Form Stage 2: Infrastructure Provisioning

**Terraform Workspace:** `fmeform-infra-<environment>`

```
┌─────────────────────────────────────────────────┐
│        Stage 2: FME Form Infrastructure          │
│        Workspace: fmeform-infra-gogis-dev        │
│                                                   │
│  Resources Created:                               │
│  ├── EC2: FME Form Instance                     │
│  ├── Security Groups: FME Form                   │
│  ├── IAM: Instance Role & Policy                │
│  └── S3: Installer Access                        │
└─────────────────────────────────────────────────┘
```

---

### FME Form Stage 3: SSM Command Execution

Executes the SSM Command document to install and configure FME Form.

```
┌──────────────────────────────────────────────────────────────────────┐
│        Stage 3: SSM Command Execution                                │
│                                                                      │
│  Execute FME Form Installation                                       │
│  ┌────────────────────────────────────────────────────────────────┐  │
│  │  Document: fme-form-windows-install                            │  │
│  │  Target: FME Form EC2 Instance                                │  │
│  │                                                                 │  │
│  │  Parameters:                                                    │  │
│  │  ├── S3Bucket     = elevate-installer                          │  │
│  │  ├── S3Key        = esri/fmeform/fme-form-*.exe                │  │
│  │  └── InstallDrive = G:                                         │  │
│  │                                                                 │  │
│  │  Execution Flow:                                                │  │
│  │  PrerequisiteChecks ──▶ DownloadInstaller ──▶ Uninstall ──▶    │  │
│  │  Install ──▶ Verify ──▶ Configure ──▶ Cleanup                  │  │
│  └────────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

## FME Form Directory Structure

```
fmeform/
├── main.tf                                  # SSM Document (Terraform)
├── variables.tf
├── outputs.tf
├── terraform.tf
├── terraform-gogis-dev.tfvars
├── terraform-datamigration.tfvars
└── scripts/
    └── ssm/
        └── install-configure-fme-form.yml   # FME Form command doc
```

## FME Form Prerequisites

### S3 Bucket Structure

```
elevate-installer/
└── esri/
    └── fmeform/
        └── fme-form-2025.2.2-b25827-win-x64.exe
```

### Software Requirements

| Software | Version |
|----------|--------|
| FME Form | 2025.2.2 (Build 25827) |
