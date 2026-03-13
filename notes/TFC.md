# Do We Need Terraform Cloud Workspaces & Registry?

## Position
Terraform Cloud (TFC) is a good platform built for a specific kind of organization: one that lacks the internal skills, tools, or infrastructure to manage Terraform state, execution, and modules on its own, or one that is building and publishing infrastructure modules for broad external consumption.

PG&E is neither of those organizations.

We have a Cloud COE with the skills to manage Terraform backends, IAM, and KMS. We have ADO Pipeline and GitHub already in the toolchain. Our modules are internal, built for PG&E and consumed by PG&E app teams. We are not publishing infrastructure products for external consumption. Paying for a platform that fills a capability gap we do not have is waste, not strategy.

---

## Who TFC Is Actually Built For

**Organizations without internal skills or infrastructure**
- Teams that cannot manage remote state, state locking, or Terraform execution without an abstraction layer
- Teams without a CI/CD platform capable of running Terraform plans and applies
- Teams without the IAM and cloud infrastructure knowledge to secure and manage backends natively

**Organizations publishing modules for broad external consumption**
- HashiCorp partners and ISVs building reusable infrastructure products for other companies
- Consultancies publishing public or multi-tenant module catalogs
- Organizations whose modules need to be discoverable and consumable outside their own environment

PG&E does not fit either profile. We have a Cloud COE, an ADO Pipeline platform, AWS infrastructure, and GitHub. The capability gap TFC is designed to fill does not exist here.

---

## How TFC Is Currently Being Used at PG&E

| TFC Feature | Current Usage | Assessment |
|---|---|---|
| Remote execution | Running Terraform plans and applies | Replaced by ADO Pipeline |
| Sentinel policies | Owned and managed by app teams | Wrong team, wrong layer |
| Private module registry | Versioned module hosting | GitHub + tags does the same thing at no cost |
| Remote state storage | S3-compatible state backend | S3 + DynamoDB + KMS is cheaper and native |

---

## Remote Execution: We Are Building the Replacement

TFC's remote execution model runs Terraform plans and applies inside TFC's infrastructure. ADO Pipeline already does this, and EPIC is being built to handle it at scale across all app teams and AWS accounts.

- Plan, apply, and destroy are parameterized stages in ADO Pipeline today
- OIDC service connections to AWS are already in place
- Approval gates, audit history, and branch-based triggers are built into ADO natively
- Everything runs inside PG&E's controlled environment, not a third-party SaaS execution plane

Once ADO Pipeline is the standard deployment mechanism for infrastructure, the primary justification for TFC remote execution is gone. We are not evaluating whether to replace it. We are replacing it right now.

---

## Sentinel: Wrong Team, Wrong Layer

Sentinel is TFC's policy-as-code engine. At PG&E, app teams are currently owning and managing Sentinel policies. That is the wrong model for two reasons.

**Wrong team.** Policy enforcement is a platform team responsibility. App teams owning Sentinel policies means inconsistent enforcement, no central governance, and no audit trail the platform team controls. When every team manages its own policies, you do not have guardrails. You have suggestions.

**Wrong layer.** AWS already provides policy enforcement at the account and organization level through Service Control Policies (SCPs) and IAM permission boundaries. These cannot be bypassed by an app team misconfiguring a Sentinel policy. Enforcing guardrails at the AWS layer is more reliable, more auditable, and does not require a TFC subscription.

---

## Module Registry: GitHub Already Does This

TFC's Private Registry provides a versioned, browsable module catalog. GitHub already provides this.

- Tag a module repo `v1.0.0` and Terraform resolves it natively
- Modules are version-pinned the same way in both approaches
- GitHub provides PR reviews, branch protection, and change history on every module
- Discoverability is solved with a naming convention and a README, not a paid UI

PG&E's modules are internal. We are not publishing them for external consumption. The only thing TFC's registry adds over GitHub is a web interface. That is not worth the subscription cost.

---

## State Management: S3 / DynamoDB / KMS

TFC's state storage is S3-compatible under the covers. We can own that layer directly.

- **S3** stores state files with versioning, encryption, and lifecycle policies natively
- **DynamoDB** provides state locking natively
- **KMS** encrypts state at rest natively
- **IAM** controls who can read and write state natively
- All of this lives inside our AWS accounts, under our control, audited by CloudTrail

There is no feature gap. There is no operational gap. There is only a cost gap, in TFC's favor.

---

## The Bottom Line

TFC fills a real gap for organizations that need it. PG&E does not need it.

We have the skills, the tools, and the infrastructure to manage Terraform state, execution, and modules without a third-party SaaS platform. ADO Pipeline is replacing TFC's remote execution. AWS SCPs and IAM are the right layer for policy enforcement. GitHub handles module versioning. S3, DynamoDB, and KMS handle state.

The right move is to complete the ADO Pipeline migration, move state to native AWS backends, and retire the TFC subscription. We get lower cost, less complexity, and better alignment with the tools and governance models we already own.