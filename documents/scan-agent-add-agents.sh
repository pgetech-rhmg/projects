#!/usr/bin/env bash
#
# scan-agent-add-agents.sh — register additional Azure DevOps agents on the
# EPIC scan-agent EC2 box, joining the "EPIC - Self-hosted" pool.
#
# WHERE THIS RUNS: on the scan-agent EC2 instance itself, as ROOT, over SSM.
#   aws ssm start-session --target i-0af3ffca111ae0556 --region us-west-2
#   sudo su -
#   export ADO_PAT='<your registration PAT>'   # Agent Pools -> Read & manage
#   bash scan-agent-add-agents.sh
#
# It does NOT install the toolchain (git/dotnet/java/node/wizcli) — that is
# already installed once on the box and shared via the adoagent user's PATH.
# It only registers new agents, each in its own dir + its own systemd service.
#
# Idempotent: an agent whose dir is already configured is skipped, so you can
# re-run this safely if one agent fails partway.
#
# See documents/scan-agent-setup.md ("Adding another agent") for the manual
# procedure this automates.

set -euo pipefail

###############################################################################
# Config — edit these if your topology differs
###############################################################################

ORG_URL="https://dev.azure.com/pgetech"
POOL="EPIC - Self-hosted"
AGENT_USER="adoagent"
AGENT_HOME="/home/${AGENT_USER}"
SEED_DIR="${AGENT_HOME}/myagent"   # existing agent-01 dir — source of the tarball

# Agents to create: "install-dir:agent-name" — dir is relative to $AGENT_HOME.
# scan-agent-01 already exists in $SEED_DIR; we add 02/03/04 to fill the
# m5.2xlarge (32 GB ~= 4 concurrent heavy scans).
AGENTS=(
  "agent2:scan-agent-02"
  "agent3:scan-agent-03"
  "agent4:scan-agent-04"
)

###############################################################################
# Preflight
###############################################################################

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

[[ "$(id -u)" -eq 0 ]] || die "Must run as root (over SSM: 'sudo su -' first)."
[[ -n "${ADO_PAT:-}" ]] || die "Set the registration PAT first:  export ADO_PAT='<pat>'"

id "$AGENT_USER" &>/dev/null || die "User '$AGENT_USER' does not exist — is this the scan-agent box?"
[[ -d "$SEED_DIR" ]] || die "Seed dir $SEED_DIR not found — agent-01 should already be installed here."

# Find the agent tarball already on the box so new agents match agent-01's version.
TARBALL="$(ls -1 "${SEED_DIR}"/vsts-agent-linux-x64-*.tar.gz 2>/dev/null | head -n1 || true)"
[[ -n "$TARBALL" ]] || die "No vsts-agent tarball found in ${SEED_DIR} — cannot clone the agent version."
log "Using agent tarball: $(basename "$TARBALL")"

###############################################################################
# Register each agent
###############################################################################

for entry in "${AGENTS[@]}"; do
  dir="${entry%%:*}"
  name="${entry##*:}"
  target="${AGENT_HOME}/${dir}"

  log "Agent '${name}'  (dir: ${target})"

  # Skip if already configured (idempotent re-runs).
  if [[ -f "${target}/.agent" ]]; then
    warn "${target}/.agent exists — '${name}' already configured; skipping registration."
  else
    # --- Unpack + configure as the agent user ---
    sudo -u "$AGENT_USER" mkdir -p "$target"
    sudo -u "$AGENT_USER" cp "$TARBALL" "$target/"
    sudo -u "$AGENT_USER" bash -c "cd '$target' && tar zxf '$(basename "$TARBALL")'"

    # config.sh must run as the agent user, never root. PAT passed via the
    # already-exported env; --replace lets a half-registered name re-register.
    sudo -u "$AGENT_USER" env ADO_PAT="$ADO_PAT" bash -c "
      cd '$target' &&
      ./config.sh \
        --unattended \
        --url '$ORG_URL' \
        --auth pat --token \"\$ADO_PAT\" \
        --pool '$POOL' \
        --agent '$name' \
        --replace \
        --acceptTeeEula
    " || die "config.sh failed for '${name}'. Check PAT scope (Agent Pools -> Read & manage) and pool name '${POOL}'."
  fi

  # --- Install + start as a systemd service (as root) ---
  # Always run `install` — it is idempotent (re-creates the unit + symlink) and
  # is the step that actually registers the systemd service. Do NOT gate it on
  # `svc.sh status`: a configured-but-not-installed agent can report cleanly
  # enough to skip install, leaving the agent Offline (registered but no service).
  # `|| true`: on an idempotent re-run the service may already be installed and
  # `install` exits non-zero — harmless, so don't let set -e abort the loop.
  ( cd "$target" && ./svc.sh install "$AGENT_USER" ) || true
  ( cd "$target" && ./svc.sh start ) || true

  ( cd "$target" && ./svc.sh status ) || warn "svc.sh status returned nonzero for '${name}' (name-escaping noise is expected; verify in the ADO portal)."
done

###############################################################################
# Done
###############################################################################

log "All agents processed."
cat <<EOF

Next:
  * ADO -> Organization Settings -> Agent pools -> "${POOL}"
    Confirm scan-agent-01 plus the new agents all show Online / Idle.
  * Check each new agent's Capabilities tab lists git / java / node / dotnet
    (inherited from the shared ${AGENT_USER} PATH).
  * REVOKE the registration PAT now that the agents are registered.
  * unset ADO_PAT   # clear it from this shell

Sizing reminder: this box is an m5.2xlarge (32 GB) ~= 4 concurrent heavy scans.
Watch memory under real concurrent load before adding more agents.
EOF
