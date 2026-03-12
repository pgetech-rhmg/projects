## Outside the ADO Pipeline - CCoE Ownership & Approach

These items are not solved by the ADO Pipeline itself, but CCoE is responsible for closing the gap. Each one has a straightforward path forward.

---

### Observability Hooks (Pipeline Telemetry + Deployment Traceability)

**The gap:** The ADO Pipeline produces logs and run history natively, but there's no structured telemetry feeding into a central observability platform.

**CCoE approach:** Configure ADO Service Hooks to POST pipeline completion events to an API Gateway endpoint. A Lambda function receives the event and writes a structured record to DynamoDB - status, duration, run ID, commit SHA, branch, timestamp. CloudWatch Logs captures Lambda execution automatically.

For deployment traceability, tag every AWS resource at deploy time with the ADO run ID and commit SHA. Both are available as built-in pipeline variables. That creates a direct link from any running resource back to the pipeline run and commit that put it there.

---

### Run Model (Pipeline Support + Platform SLAs)

**The gap:** No defined answer to "who do I call when my pipeline breaks?" or "what's the uptime commitment on this platform?"

**CCoE approach:** Publish a one-page run model that answers three questions:

- Is the failure in the ADO Pipeline templates or in the app team's code/config? App team owns the latter. CCoE owns the former.
- What's the escalation path when the platform itself is the problem? CCoE on-call, with a defined response SLA.
- What does CCoE commit to for pipeline platform availability? 99.5% during business hours is defensible and honest.

Post it in the CCoE wiki. Reference it in onboarding.

---

### Compliance Evidence

**The gap:** The ADO Pipeline generates all the right artifacts - scan results, approval records, run logs - but nothing packages them into audit-ready evidence automatically.

**CCoE approach:** Add a post-deployment stage to the pipeline that collects scan results, approval records, and artifact hashes, then publishes them to a versioned S3 bucket using a standardized key structure tied to the run ID. S3 versioning and Object Lock handle immutability. Athena can query the archive if an auditor needs reporting.

No compliance dashboard needed yet. A consistent, queryable archive per deployment is enough.

---

### Audit-Ready Logs Across Azure DevOps + AWS

**The gap:** ADO audit logs and AWS CloudTrail both exist but live in separate places with no correlation between them.

**CCoE approach:** Schedule an ADO Audit Log API export and ship the output to the same S3 bucket as CloudTrail. Use Athena to query across both. The correlation key is the IAM role session name - stamp it with the ADO run ID at pipeline execution time and every CloudTrail event becomes traceable back to the pipeline run that triggered it.

One-time setup. No ongoing engineering investment.