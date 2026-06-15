# EPIC Scan Agent — Setup Runbook

This runbook stands up the **`EPIC - Self-hosted`** Azure DevOps agent on an AWS
EC2 instance. That pool is already referenced by the pipeline for:

- **SonarQube / Wiz scans** — [`scan/main.yml`](../epic-pipeline/scan/main.yml) routes any
  `scanTool: sonarqube` or `scanTool: wiz` job to `EPIC - Self-hosted`.
- **.NET + SonarQube builds** — [`build/main.yml`](../epic-pipeline/build/main.yml) routes
  `dotnet`/`dotnet_framework` builds to the same pool when SonarQube is enabled, because
  SonarQube's dotnet mode instruments the build (pre/post-build), so build **and** scan
  must run on the same agent.

Everything else stays on Microsoft-hosted `ubuntu-latest` / `windows-latest`.

> **Topology decided for this stand-up:** Terraform provisions a single, always-on
> EC2 box; the scan toolchain is installed **by hand** over SSM and the agent is
> registered once. The Terraform lives in `EPIC AWS Resources/Scan Agent/`.

---

## Prerequisites

- Azure DevOps org/project admin (to create the pool + a registration PAT).
- AWS CLI with the **Session Manager plugin** installed locally.
- Networking is pre-filled in `terraform.auto.tfvars` to the **shared EPIC nonprod VPC**
  (`vpc-8c57a5f4`) and the subnet epic-api's app server runs in (`subnet-f9206980`), which has
  proven outbound egress to GitHub/ADO. The stack creates its **own egress-only security
  group** — you do not supply one. That subnet's egress must reach:
  - Azure DevOps — `dev.azure.com`, `*.vssps.visualstudio.com`, `*.dev.azure.com`
  - Internal SonarQube server (`*.lab.pge.com` or wherever it lives)
  - Wiz — `wizcli.app.wiz.io` and your Wiz tenant API
  - AWS Secrets Manager (if pulling `WIZ_*` / `GITHUB_PAT` from there)
  - No **inbound** rules are required — SSM Session Manager is outbound-initiated.

---

## Step 1 — Create the ADO agent pool

1. Azure DevOps → **Organization Settings → Agent pools → Add pool**.
2. Type **Self-hosted**, name it exactly **`EPIC - Self-hosted`** (must match the YAML).
3. Grant your project access to the pool (Security tab) and "Auto-provision in projects" if desired.
4. Create a **PAT** with scope **Agent Pools → Read & manage**. Save it temporarily — it is
   only needed for the one-time `config.sh` registration and can be revoked afterward.

---

## Step 2 — Provision the EC2 host (Terraform)

From `EPIC AWS Resources/Scan Agent/`:

1. Review `terraform.auto.tfvars`. The VPC/subnet default to the shared EPIC nonprod
   network (same as epic-api); the egress-only SG is created by the stack. The only value
   you may need to set:
   - `scan_secret_arns` — ARNs of the Wiz / GitHub PAT secrets (or leave `[]`)
   - (Override `vpc_id` / `subnet_id` only if you stand up dedicated networking.)
2. Apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
3. Note the `instance_id` output.

The EC2 module attaches `AmazonSSMManagedInstanceCore`, so the box is reachable via
Session Manager with no SSH key or public IP.

---

## Step 3 — Connect to the box

You can connect either from the AWS console (**Systems Manager → Session Manager →
Start session → pick the instance**) or from a local terminal:

```bash
aws ssm start-session --target <instance_id> --region us-west-2
```

> **Heads-up:** SSM drops you in as the unprivileged `ssm-user`, **not** root. Every install
> command below needs root. Become root once so you don't have to prefix everything with `sudo`:
>
> ```bash
> sudo su -
> ```
>
> Your prompt should change to `[root@ip-... ~]#`. Stay root through Steps 4–5 (you'll `su -`
> into the agent user only for the registration sub-steps, which are called out explicitly).

---

## Step 4 — Install the scan toolchain

Amazon Linux 2023 (`dnf`), as **root**. Adjust versions to match your SonarQube server.

> **Do this one block at a time and check the output of each.** A bare AL2023 AMI is
> minimal — do not assume a package installed just because `dnf` didn't obviously fail.
> The verification step at the end of this section is mandatory, not optional. (We learned
> this the hard way: `git` was silently absent and the scan failed with "git was not found"
> only at pipeline run time — see Troubleshooting.)

```bash
# Base utilities — git is REQUIRED (source checkout); the agent scans for it at startup.
dnf install -y git curl tar gzip unzip rsync which jq

# libicu — REQUIRED by .NET for globalization. Without it `dotnet` aborts immediately with
# "Couldn't find a valid ICU package". (epic-api's own EC2 bootstrap installs this too.)
dnf install -y libicu

# JRE 17 — SonarScanner runs on the JVM
dnf install -y java-17-amazon-corretto-headless

# Node.js + npm (jest/vitest coverage lcov paths that SonarQube reads)
dnf install -y nodejs npm

# .NET SDK (for .NET builds + SonarQube dotnet mode)
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet
ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet

# Wiz CLI (scan/wiz/main.yml also curls this at runtime, but bake it in)
curl -o /usr/local/bin/wizcli https://wizcli.app.wiz.io/latest/wizcli-linux-amd64
chmod +x /usr/local/bin/wizcli
```

### Verify the toolchain (do NOT skip)

```bash
git --version && java -version && node --version && dotnet --version && wizcli version
```

All five must print a version. If any errors:

- **`dotnet` → "Couldn't find a valid ICU package"** — `libicu` didn't install. Run
  `dnf install -y libicu` and re-check.
- **`git` not found** — re-run `dnf install -y git`. **A missing git is the single most
  likely cause of a failed scan**, because the agent only detects git at startup; if you
  install it after the agent is already running you MUST restart the agent (Step 5c note).
- **`wizcli` EOS warning** — v0.X prints an "End of Support (April 15, 2026)" warning. This
  is expected and matches what the pipeline downloads at runtime; leave it for now. Migrating
  to wizcli v1.X is a separate pipeline-level change (the `dir scan`/`auth` syntax differs).

### `dotnet-sonarscanner` — OPTIONAL, and prone to hanging

> **This tool is NOT required to get the agent working.** The `SonarQubePrepare@8` ADO task
> downloads its own scanner at run time. Treat this as belt-and-suspenders and **defer it** if
> it gives any trouble — do not let it block agent registration or Wiz validation.

If you do install it, install it **as the `adoagent` service user** (global tools are per-user),
after that user exists (Step 5a):

```bash
su - adoagent -c 'DOTNET_CLI_TELEMETRY_OPTOUT=1 DOTNET_NOLOGO=1 dotnet tool install --global dotnet-sonarscanner'
su - adoagent -c 'dotnet tool list --global'   # confirm dotnet-sonarscanner is listed
```

> **If `dotnet tool install` hangs:** the first run prints a long .NET welcome banner; a
> `Ctrl+C` there can orphan a `dotnet` process that holds a lock, making every subsequent
> `dotnet` command hang. Recover with:
>
> ```bash
> pkill -9 dotnet                       # kill the stuck process(es)
> ps aux | grep -i dotnet | grep -v grep   # confirm the list is empty
> su - adoagent -c 'dotnet nuget locals all --clear'   # clear any half-written cache
> ```
>
> Then retry the install (egress to `api.nuget.org` is required — verify with
> `curl -sSI --max-time 15 https://api.nuget.org/v3/index.json` → expect HTTP 200).
> A wedged terminal can also just be closed and reopened from the SSM console; the
> instance is unaffected.

> **Memory note:** SonarQube analysis of large .NET solutions is JVM-heavy. If the
> scan job OOMs on `m5.large` (8 GB), bump `instance_type` to `m5.xlarge` (16 GB) in
> tfvars and `terraform apply`.

---

## Step 5 — Create the agent user, register, and install as a service

Run the agent as a non-root user (never as root).

### 5a — Create the service user (as root)

```bash
useradd -m -s /bin/bash adoagent

# Make .NET global tools + /usr/local/bin (dotnet symlink, wizcli) available to the agent
echo 'export PATH="$PATH:/home/adoagent/.dotnet/tools:/usr/local/bin"' >> /home/adoagent/.bashrc
```

### 5b — Download and register the agent (as the `adoagent` user)

Get the **current download URL** from ADO: **Organization Settings → Agent pools →
EPIC - Self-hosted → New agent → Linux → x64**. It shows the exact version (e.g. `4.274.1`).
Substitute it below.

```bash
su - adoagent

mkdir -p ~/myagent && cd ~/myagent
curl -O https://download.agent.dev.azure.com/agent/<VERSION>/vsts-agent-linux-x64-<VERSION>.tar.gz
tar zxf vsts-agent-linux-x64-*.tar.gz
ls   # expect config.sh, run.sh, svc.sh, bin/, externals/ ...

# Register into the pool (unattended). Replace <YOUR_PAT> with the Step 1 registration PAT.
./config.sh \
  --unattended \
  --url https://dev.azure.com/pgetech \
  --auth pat --token <YOUR_PAT> \
  --pool "EPIC - Self-hosted" \
  --agent scan-agent-01 \
  --acceptTeeEula

exit   # back to root to install the service
```

Expect `Successfully added the agent` / `Settings Saved`. It does not hang — if it does, the
PAT scope (Agent Pools → Read & manage) or the exact pool name `EPIC - Self-hosted` is wrong.

### 5c — Install and start as a systemd service (as root)

```bash
cd /home/adoagent/myagent
./svc.sh install adoagent
./svc.sh start
./svc.sh status
```

`status` should show `active (running)`. The agent then shows **Online / Idle** in the ADO pool.
Revoke the registration PAT once confirmed.

> **Expected noise — ignore it:** `svc.sh` prints
> `is not an absolute file system path, escaping is likely not going to be reversible` and the
> unit filename appears mangled as `vsts.agent.pgetech.EPIC\x20\x2d\x20Self\x2dhosted...`.
> This is only because the pool name `EPIC - Self-hosted` contains spaces/hyphens; the service
> works fine. **Always manage it through `./svc.sh` (`stop`/`start`/`status`)** — raw
> `systemctl`/`journalctl` with the human-readable name will report a bogus `inactive` because
> it escapes the name differently. The ADO portal (Agents tab) is the source of truth for
> Online/Idle, not the CLI.

> **CRITICAL — restart the agent after any tool change.** The agent scans for tool
> capabilities (git, node, java, etc.) **once at startup** and caches them. If you install or
> update a tool while the agent is running, it will NOT see it until restarted:
>
> ```bash
> cd /home/adoagent/myagent && ./svc.sh stop && ./svc.sh start && ./svc.sh status
> ```
>
> Verify a tool registered in ADO: **Agents → scan-agent-01 → Capabilities** tab.

---

## Step 6 — Create the SonarQube service connection

The scan tasks reference a service connection named literally `'SonarQube'`
(see [`scan/sonarqube/prepare.yml`](../epic-pipeline/scan/sonarqube/prepare.yml)).

1. ADO → Project Settings → **Service connections → New → SonarQube**.
2. Name it exactly **`SonarQube`**, point at your internal SonarQube server, add the token.
3. Confirm the agent's subnet can reach the server (`curl -I https://<sonarqube-host>` from the box).

Confirm the Wiz credentials exist in the `GV-account-access` variable group
(`WIZ_CLIENT_ID`, `WIZ_CLIENT_SECRET`) per the pipeline README.

---

## Step 7 — Validate end-to-end

> **Prerequisite — enable the "Scan App" toggle in epic-web.** The New Run modal's "Scan App"
> checkbox was hardcoded off ("Requires self-hosted agents (coming soon)") until the agent
> existed. It is now enabled in [`app.html`](../epic-web/src/app/app.html) (binds to
> `newRunScan`). A run only scans when **both** are true: the user checks "Scan App" **and**
> the selected `epic.json` has `"scanTool": "sonarqube"` or `"wiz"` — the checkbox is the
> on/off, `scanTool` picks which tool. With no `scanTool`, the scan job runs on `ubuntu-latest`
> and does nothing.

1. **Wiz first** (fewest dependencies). Run a pipeline with `"scanTool": "wiz"`. Confirm:
   - the job lands on `scan-agent-01` (watch the pool's **Jobs** tab; it leaves Idle),
   - `wizcli auth` succeeds,
   - the `epic-wiz-scan` artifact is published.
2. **SonarQube .NET** — run a `dotnet` app with `"scanTool": "sonarqube"`. This exercises
   the build-and-scan-on-the-same-agent path and is the most demanding. Confirm the
   `SonarQubeAnalyze@8` / `SonarQubePublish@8` steps pass the quality gate publish.

---

## Operations notes

- **This box is hand-built.** This runbook is the only record of what's installed — keep it
  current when you patch or add tooling, so the agent can be rebuilt if the instance is lost.
- **Reboot / stop-start recovery is automatic.** The agent is a systemd service installed with
  `./svc.sh install` (unit is `enabled`, symlinked into `multi-user.target.wants`), so it comes
  back **Online** on its own after an OS reboot or an EC2 stop/start — no manual step. The
  toolchain lives on the persistent root EBS volume and survives reboots too. Only a full
  **instance termination** loses everything (rebuild from this runbook). Note: an EC2 stop/start
  changes the private IP, which is harmless here because the agent polls ADO outbound.
- **Patching:** `dnf update -y` on a cadence; **restart the agent service after** (`./svc.sh
  stop && ./svc.sh start`) so capabilities re-scan.
- **Agent updates:** ADO auto-updates the agent binary; no action needed normally.
- **Stale agents:** remove dead/offline agents (e.g. an old `EPIC-Agent`) from the pool so they
  don't muddy capacity reporting.
- **Scaling later:** with one agent, concurrent scan-bearing pipelines queue (one job at a
  time; a .NET+SonarQube pipeline consumes the agent twice — build then scan). To scale,
  register a second agent in its own dir on the same box, run the stack again for a second
  instance, or move to a baked AMI + autoscaling set.

---

## Troubleshooting (issues hit during the first stand-up)

| Symptom | Cause | Fix |
|---|---|---|
| Pipeline scan fails: **"git was not found"** | git absent on the minimal AMI; agent cached "no git" at startup | `dnf install -y git`, then **restart the agent** (`./svc.sh stop && ./svc.sh start`) so it re-scans capabilities |
| `dotnet` aborts: **"Couldn't find a valid ICU package"** | `libicu` not installed | `dnf install -y libicu` |
| `dotnet tool install` **hangs forever** | a `Ctrl+C` during the first-run banner orphaned a `dotnet` process holding a lock | `pkill -9 dotnet`; confirm none remain; `dotnet nuget locals all --clear`; retry. This tool is optional — defer if it keeps fighting. |
| `systemctl is-active "...EPIC - Self-hosted..."` reports **inactive** but agent is up | systemd escapes the spaced/hyphenated unit name differently than `svc.sh` did | Use `./svc.sh status` and the ADO Agents tab — they're authoritative |
| Agent shows **Offline** in ADO | service not running, or lost egress to ADO | `./svc.sh status`; check egress: `curl -sSI https://dev.azure.com` (404 is fine — proves reachability) |
| SonarQube step can't reach the server | subnet egress doesn't reach the internal SonarQube host | `curl -I https://<sonarqube-host>` from the box; open the egress path if it hangs |
| "Scan App" runs but nothing is scanned | selected `epic.json` has no `scanTool` | add `"scanTool": "sonarqube"` or `"wiz"` to the config (the checkbox is on/off; `scanTool` picks the tool) |
