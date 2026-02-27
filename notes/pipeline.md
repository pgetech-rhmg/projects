| Capability | Harness (Buy) | ADO (Build) | Key Distinction |
|---|---|---|---|
| **Pipeline Orchestration** | Requires setup, migration from existing tools, team retraining | Configure ADO Pipelines with existing toolchain | Same setup effort, no migration cost |
| **Security Gates / Policy** | Requires defining policies, configuring OPA, mapping to PG&E compliance | Define policies once, build them natively into ADO templates | Either way, PG&E must define the policy first |
| **Deployment Strategies** | Requires configuring environments, connectors, approval gates | Build deployment stages tailored to PG&E infra | Same configuration work, but PG&E owns the output |
| **Audit & Compliance** | Requires mapping Harness RBAC to PG&E roles and regulatory requirements | Build audit trails to exact PG&E/NERC/FERC requirements | Custom build = purpose-fit for regulated utility |
| **Dashboards & Visibility** | Requires instrumentation, connector setup, data mapping | Build on existing ADO + Power BI investment | Harness dashboards don't auto-populate |
| **Cost** | Based on licenses (per user/module) | Already paying for it | Additional tool cost with Harness |
| **Vendor Lock-in** | Configuration lives in Harness — hard to exit | PG&E owns everything built | Critical risk for a regulated utility |
