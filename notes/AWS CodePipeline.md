# AWS CodePipeline (Per-App / Per-Account) Alternative

## Cost
- Every app team gets their own pipeline — at PG&E's scale, that's hundreds of pipelines across dozens of accounts
- AWS CodePipeline charges per active pipeline per month — costs multiply fast with no centralization
- Duplicate tooling cost: SonarQube and JFrog integrations would need to be configured independently in every pipeline

---

## Operational Overhead
- No single pane of glass — pipeline failures, drift, and misconfiguration are scattered across accounts
- Updates to standards (new scan tool, new deploy target, security patch) require touching every pipeline individually
- Onboarding a new app team means building a new pipeline, not dropping a config file

---

## Multi-Cloud is a Hard Blocker
- PG&E runs both AWS and Azure — AWS CodePipeline is AWS-only, full stop
- ADO Pipeline is cloud-agnostic — the same pipeline engine can target AWS today and Azure tomorrow without re-platforming
- Standardizing on a native AWS tool locks PG&E's CI/CD strategy to one cloud vendor; ADO Pipeline does not

---

## Security & Governance
- Per-account pipelines mean per-account IAM configurations — no consistent enforcement, no central audit trail
- ADO Pipeline centralizes the trust boundary in one account with one OIDC provider; CodePipeline per-account scatters that surface area
- Enforcing SonarQube gates and JFrog artifact policies across independently owned pipelines is a governance nightmare — teams can bypass or misconfigure them

---

## The Bottom Line
- AWS CodePipeline is a solid tool — for teams that are AWS-only and willing to manage pipeline sprawl
- PG&E is multi-cloud, multi-team, and needs centralized governance — that's exactly what ADO Pipeline is built for