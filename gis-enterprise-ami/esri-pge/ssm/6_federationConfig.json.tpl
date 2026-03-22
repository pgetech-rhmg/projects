{
  "schemaVersion": "2.2",
  "description": "Federate Hosting Server and Go ArcGIS Server with Portal using cinc-client (multi-step, per-step logging + waits)",
  "parameters": {
    "hostingFederation": { "type": "String" },
    "goFederation": { "type": "String" }
  },
  "mainSteps": [

    {
      "action": "aws:runShellScript",
      "name": "prepSystem",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/federation-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/prepSystem.log\") 2>&1",
          "echo \"=== prepSystem: starting at $(date) ===\"",
          "",
          "echo \"=== prepSystem: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "runHostingFederationConfig",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/federation-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/hosting-federation-config.log\") 2>&1",
          "echo \"=== runHostingFederationConfig: starting at $(date) ===\"",
          "",
          "echo '${hostingFederation}' | base64 --decode > /opt/cinc/attributes/hosting-server-federation.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/hosting-server-federation.json 2>&1 | tee -a \"$LOG_DIR/hosting-server-federation.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"Hosting Federation cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/hosting_federation_done",
          "echo \"=== runHostingFederationConfig: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "waitForHostingFederation",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/federation-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForHostingFederation.log\") 2>&1",
          "echo \"Waiting for hosting_federation_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/hosting_federation_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for hosting_federation_done' >&2; exit 1; fi",
          "done",
          "echo \"hosting_federation_done found, continuing.\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "runGoFederationConfig",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/federation-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/go-federation-config.log\") 2>&1",
          "echo \"=== runGoFederationConfig: starting at $(date) ===\"",
          "",
          "echo '${goFederation}' | base64 --decode > /opt/cinc/attributes/go-server-federation.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/go-server-federation.json 2>&1 | tee -a \"$LOG_DIR/go-server-federation.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"Go Federation cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/go_federation_done",
          "echo \"=== runGoFederationConfig: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "waitForGoFederation",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/federation-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForGoFederation.log\") 2>&1",
          "echo \"Waiting for go_federation_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/go_federation_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for go_federation_done' >&2; exit 1; fi",
          "done",
          "echo \"go_federation_done found, continuing.\""
        ]
      }
    }

  ]
}
