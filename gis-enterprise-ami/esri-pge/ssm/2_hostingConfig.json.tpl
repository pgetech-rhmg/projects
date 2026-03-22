{
  "schemaVersion": "2.2",
  "description": "Configure Hosting Server site using cinc-client (multi-step, per-step logging + waits)",
  "parameters": {
    "hostingFileServer": { "type": "String" },
    "hostingServer": { "type": "String" }
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
          "LOG_DIR=/var/log/hosting-config",
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
      "name": "downloadAssets",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/downloadAssets.log\") 2>&1",
          "echo \"=== downloadAssets: starting at $(date) ===\"",
          "",
          "mkdir -p \"${hosting_certs_dir}\"",
          "aws s3 cp \"s3://${s3_bucket}/${hosting_root_cert_name}\" \"${hosting_certs_dir}/${hosting_root_cert_name}\" --region ${s3_region} || (echo 'Failed to download root cert' >&2; exit 1)",
          "aws s3 cp \"s3://${s3_bucket}/${hosting_pfx_cert_name}\"  \"${hosting_certs_dir}/${hosting_pfx_cert_name}\" --region ${s3_region} || (echo 'Failed to download pfx cert' >&2; exit 1)",
          "",
          "mkdir -p \"${hosting_license_dir}/${esri_version}\"",
          "aws s3 cp \"s3://${s3_bucket}/${hosting_license_name}\" \"${hosting_authorization_file}\" --region ${s3_region} || (echo 'Failed to download license' >&2; exit 1)",
          "",
          "echo \"=== downloadAssets: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installCinc",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installCinc.log\") 2>&1",
          "echo \"=== installCinc: starting at $(date) ===\"",

          "echo \"Downloading Cinc RPM from S3...\"",
          "aws s3 cp s3://${s3_bucket}/cinc-18.5.0-1.amazon2023.x86_64.rpm /tmp/cinc.rpm",

          "echo \"Installing Cinc...\"",
          "sudo rpm -Uvh /tmp/cinc.rpm",

          "export PATH=\"$PATH:/opt/cinc/bin\"",

          "echo \"=== installCinc: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "configureCinc",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/configureCinc.log\") 2>&1",
          "echo \"=== configureCinc: starting at $(date) ===\"",
          "echo \"Configuring /etc/cinc/client.rb with cookbook_path...\"",
          "CLIENT_CONFIG='/etc/cinc/client.rb'",
          "# Ensure the file exists",
          "sudo touch \"$CLIENT_CONFIG\"",
          "# Remove existing cookbook_path lines to avoid duplicates",
          "sudo sed -i '/^cookbook_path/d' \"$CLIENT_CONFIG\"",
          "# Add cookbook_path line",
          "echo \"cookbook_path ['/opt/cinc/cookbooks']\" | sudo tee -a \"$CLIENT_CONFIG\"",

          "echo \"All future cinc-client commands should use -c /etc/cinc/client.rb\"",

          "echo \"=== configureCinc: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "downloadCookbooks",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/downloadCookbooks.log\") 2>&1",
          "echo \"=== downloadCookbooks: starting at $(date) ===\"",

          "# Create required directories",
          "mkdir -p /opt/cinc/cookbooks /opt/cinc/attributes /opt/cinc/cache /opt/cinc/temp",

          "echo \"Downloading ArcGIS cookbook bundle...\"",
          "aws s3 cp s3://${s3_bucket}/arcgis-cookbook-main.zip /tmp/arcgis-cookbook.zip",

          "echo \"Extracting ArcGIS cookbook...\"",
          "unzip -o /tmp/arcgis-cookbook.zip -d /opt/cinc/temp",

          "mv /opt/cinc/temp/arcgis-cookbook-main/* /opt/cinc/ || true",
          "rm -rf /opt/cinc/temp || true",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/*",
          "chmod -R 755 /opt/cinc/*",

          "echo \"=== downloadCookbooks: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installNFSCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installNFSCookbook.log\") 2>&1",
          "echo \"=== installNFSCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/nfs",

          "echo \"Downloading NFS Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/nfs/ /opt/cinc/cookbooks/nfs --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/nfs",
          "chmod -R 755 /opt/cinc/cookbooks/nfs",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/nfs/metadata.rb ]; then",
          "  echo \"ERROR: NFS cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installNFSCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installLineCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installLineCookbook.log\") 2>&1",
          "echo \"=== installLineCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/line",

          "echo \"Downloading Line Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/line/ /opt/cinc/cookbooks/line --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/line",
          "chmod -R 755 /opt/cinc/cookbooks/line",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/line/metadata.rb ]; then",
          "  echo \"ERROR: Line cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installLineCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installHostsfileCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installHostsfileCookbook.log\") 2>&1",
          "echo \"=== installHostsfileCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/hostsfile",

          "echo \"Downloading Hostsfile Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/hostsfile/ /opt/cinc/cookbooks/hostsfile --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/hostsfile",
          "chmod -R 755 /opt/cinc/cookbooks/hostsfile",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/hostsfile/metadata.rb ]; then",
          "  echo \"ERROR: Hostsfile cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installHostsfileCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installLimitsCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installLimitsCookbook.log\") 2>&1",
          "echo \"=== installLimitsCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/limits",

          "echo \"Downloading Limits Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/limits/ /opt/cinc/cookbooks/limits --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/limits",
          "chmod -R 755 /opt/cinc/cookbooks/limits",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/limits/metadata.rb ]; then",
          "  echo \"ERROR: Limits cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installLimitsCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installDotNetCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installDotNetCookbook.log\") 2>&1",
          "echo \"=== installDotNetCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/ms_dotnet",

          "echo \"Downloading ms_dotnet Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/ms_dotnet/ /opt/cinc/cookbooks/ms_dotnet --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/ms_dotnet",
          "chmod -R 755 /opt/cinc/cookbooks/ms_dotnet",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/ms_dotnet/metadata.rb ]; then",
          "  echo \"ERROR: ms_dotnet cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installDotNetCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "installJavaPropCookbook",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",

          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/installJavaPropCookbook.log\") 2>&1",
          "echo \"=== installJavaPropCookbook: starting at $(date) ===\"",

          "mkdir -p /opt/cinc/cookbooks/java_properties",

          "echo \"Downloading java_properties Cookbook from S3...\"",
          "aws s3 cp s3://${s3_bucket}/java_properties/ /opt/cinc/cookbooks/java_properties --recursive",

          "echo \"Fixing permissions...\"",
          "chown -R root:root /opt/cinc/cookbooks/java_properties",
          "chmod -R 755 /opt/cinc/cookbooks/java_properties",

          "echo \"Validating cookbook structure...\"",
          "if [ ! -f /opt/cinc/cookbooks/java_properties/metadata.rb ]; then",
          "  echo \"ERROR: java_properties cookbook missing metadata.rb — S3 structure incorrect!\"",
          "  exit 1",
          "fi",

          "echo \"=== installJavaPropCookbook: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "runFileServerConfig",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/hosting-server-fileserver.log\") 2>&1",
          "echo \"=== runFileServerConfig: starting at $(date) ===\"",
          "",
          "echo '${hostingFileServer}' | base64 --decode > /opt/cinc/attributes/hosting-server-fileserver.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/hosting-server-fileserver.json 2>&1 | tee -a \"$LOG_DIR/hosting-server-fileserver.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"FileServer cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/hosting_fileserver_done",
          "echo \"=== runFileServerConfig: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "waitForFileServer",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForFileServer.log\") 2>&1",
          "echo \"Waiting for hosting_fileserver_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/hosting_fileserver_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for hosting_fileserver_done' >&2; exit 1; fi",
          "done",
          "echo \"hosting_fileserver_done found, continuing.\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "runHostingServerConfig",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/hosting-server.log\") 2>&1",
          "echo \"=== runHostingServerConfig: starting at $(date) ===\"",
          "",
          "echo '${hostingServer}' | base64 --decode > /opt/cinc/attributes/hosting-server.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/hosting-server.json 2>&1 | tee -a \"$LOG_DIR/hosting-server.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"Hosting Server cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/hosting_server_done",
          "echo \"=== runHostingServerConfig: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "waitForHostingServer",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/hosting-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForHostingServer.log\") 2>&1",
          "echo \"Waiting for hosting_server_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/hosting_server_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for hosting_server_done' >&2; exit 1; fi",
          "done",
          "echo \"hosting_server_done found, continuing.\""
        ]
      }
    }

  ]
}
