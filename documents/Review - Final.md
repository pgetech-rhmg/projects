# EPIC Peer Review — Meeting Talking Points

---

## Final Thoughts — likely questions

**"Why ADO and not GitHub Actions / Jenkins / etc.?"**
- ADO is the established CI/CD platform. Using ADO means we inherit existing service connections, agent pools, and audit infrastructure.

**"Why EC2 for epic-api instead of Beanstalk / Lambda / containers?"**
- The workload is light, the team owns the runtime, and EC2 + systemd is the simplest path that meets PG&E's networking and patching standards. We can revisit if traffic justifies it.

**"Why Aurora Serverless v2 instead of plain RDS?"**
- Bursty workload pattern, predictable low-volume baseline. Serverless v2 scales without us having to size an instance class and lets us right-size cost as adoption grows.

**"What stops a team from bypassing EPIC?"**
- Branch protection plus CODEOWNERS on `.pipeline/` and `.infra/`. The only sanctioned deploy path for these repos is through the EPIC engine. New repos can be added to a CCOE allow-list as a hard gate if needed.

**"What's the disaster-recovery story?"**
- Aurora Serverless v2 has automated backups and point-in-time recovery. The EPIC platform itself is recoverable from Terraform — `.infra/` plus state in S3 is the source of truth. We could rebuild epic-web/epic-api from the IaC in roughly a couple hours.

**"Cross-account trust — why STS AssumeRole and not OIDC federation?"**
- Current state uses the ADO `AWS` service connection. OIDC federation is a planned hardening — eliminates the long-lived ADO key in favor of short-lived federated tokens.
