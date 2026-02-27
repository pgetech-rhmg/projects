# ADO Pipeline Build — Cost/Effort Analysis
## PG&E DevSecOps Program

---

## Assumptions
- Pilot covers 3–5 application teams
- Principal Architect / Engineer (consultant), 2–3 internal PG&E engineers executing
- Goal: reusable enterprise template library, not one-off pipelines

---

## Team & Duration

| Role | Who | Hours/Week | Duration | Est. Cost |
|---|---|---|---|---|
| Principal Architect / Engineer | Consultant | 40 hrs/wk | 12 weeks | Hourly rate |
| Security/Compliance SME | Internal (part-time) | 10 hrs/wk | 12 weeks | Already salaried |
| DevSecOps Engineer | Internal (1 FTE) | 40 hrs/wk | 12 weeks | Already salaried |
| Application Engineer | Internal (1–2 FTEs) | 40 hrs/wk | 12 weeks | Already salaried |

**Total Timeline: 12 weeks (3 months) for a working pilot**

---

## What Gets Built in 12 Weeks

| Deliverable | Notes |
|---|---|
| ADO Pipeline Templates (YAML) | Reusable across all application teams |
| Branch Strategy & Governance Model | Standards PG&E owns forever |
| Security Gates (SAST, DAST, SCA) | Integrated into pipeline, not bolted on |
| Compliance Checkpoints | Mapped to NERC/CIP or internal policy |
| Environment Promotion Workflow | Dev → QA → Prod with approval gates |
| Onboarding Runbook | So teams can self-serve after pilot |
| Documentation | DevSecOps team owns it |

---

## Cost Summary

| Item | Cost |
|---|---|
| Consultant (Principal Architect / Engineer) — 12 weeks | (hourly rate * 12 weeks * 40 hour/week) |
| ADO Licensing | (already covered under existing Microsoft EA) |
| Tooling — SAST/DAST (e.g. Checkmarx, SonarQube) | (already covered under existing licenses) |
| Internal Team (salaried, redirected) | $0 net new |
| **Total Pilot Cost** | **1 Consultant** |

---

## What Comes Next

After the pilot, PG&E has a proven, documented, enterprise-ready template platform.
Scaling to 50+ teams is an **enablement and adoption effort** — not a rebuild.
That's another 2–3 quarters with internal staff executing, not a new contract.
