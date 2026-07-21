#!/usr/bin/env bash
#
# scan-agent-push.sh — RUN THIS ON YOUR MACBOOK.
#
# Uploads scan-agent-add-agents.sh onto the scan-agent EC2 box via SSM
# (no scp needed, no PAT involved — the script itself carries no secret),
# so you can then open an interactive SSM session and run it there with the
# PAT exported only in that on-box shell (PAT never hits AWS logs).
#
# Usage (from this documents/ folder on your Mac):
#   ./scan-agent-push.sh
#
# Requires: awscli + the Session Manager plugin, and creds for account
# 514712703977 (us-west-2).

set -euo pipefail

INSTANCE_ID="i-0af3ffca111ae0556"
REGION="us-west-2"
LOCAL_SCRIPT="$(dirname "$0")/scan-agent-add-agents.sh"
REMOTE_PATH="/root/scan-agent-add-agents.sh"

[[ -f "$LOCAL_SCRIPT" ]] || { echo "Can't find $LOCAL_SCRIPT" >&2; exit 1; }

echo "==> Uploading $(basename "$LOCAL_SCRIPT") to ${INSTANCE_ID}:${REMOTE_PATH} ..."

# base64 the script and have the box decode it to $REMOTE_PATH. No secret in transit.
B64="$(base64 < "$LOCAL_SCRIPT" | tr -d '\n')"

CMD_ID="$(aws ssm send-command \
  --region "$REGION" \
  --instance-ids "$INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --comment "push scan-agent-add-agents.sh" \
  --parameters "commands=[\"echo '$B64' | base64 -d > $REMOTE_PATH\",\"chmod +x $REMOTE_PATH\",\"ls -l $REMOTE_PATH\"]" \
  --query 'Command.CommandId' --output text)"

echo "==> send-command id: $CMD_ID  (waiting for it to finish...)"
aws ssm wait command-executed --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" || true

aws ssm get-command-invocation \
  --region "$REGION" --command-id "$CMD_ID" --instance-id "$INSTANCE_ID" \
  --query 'StandardOutputContent' --output text

cat <<EOF

==> Upload done. Now open an interactive session and run it (PAT stays on the box):

    aws ssm start-session --target $INSTANCE_ID --region $REGION
    sudo su -
    export ADO_PAT='<your registration PAT>'
    bash $REMOTE_PATH
    unset ADO_PAT      # clear it when done, then revoke the PAT in ADO
EOF
