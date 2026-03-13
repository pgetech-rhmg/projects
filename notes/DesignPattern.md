# Azure DevOps Design

## Security
- **No long-lived credentials** — AWS Well-Architected Framework explicitly states *"the most secure credential is one that you do not have to store, manage, or handle"* — OIDC is how you get there
- **OIDC is the current industry standard** for CI/CD-to-cloud auth — AWS, Microsoft, GitHub, and JFrog all recommend it over static access keys
- **ADO never touches target accounts directly** — AWS documents this cross-account trust pattern (tools account → STS AssumeRole → target account) as the recommended model for CI/CD pipelines in their DevOps blog
- SonarQube gates block vulnerable code before it reaches AWS — security is enforced, not optional

---

## Consistency
- **Centralized YAML templates** are Microsoft's recommended pattern for scaling pipelines across teams — documented on Microsoft Learn under Azure Pipelines best practices
- App teams configure via JSON, they don't build pipelines — one engine, enforced standards
- SonarQube and JFrog are mandatory stops — not optional per-team decisions

---

## Scale
- **Hub/spoke cross-account deployment** is AWS's documented pattern for platform teams managing multi-account environments — referenced across AWS Architecture Blog, AWS DevOps Blog, and AWS CodePipeline docs
- New target account = one IAM role, not a new pipeline
- New app team = one JSON config file, nothing else

---

## Considerations
- *Pipeline account compromised?* — Each target account role has its own trust policy and least-privilege permissions; blast radius is contained by design
- *Flexible design?* — App teams own their JSON config; behavior is configurable within guardrails
