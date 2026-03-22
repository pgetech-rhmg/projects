{
  "schemaVersion": "2.2",
  "description": "Configure Portal site using cinc-client (multi-step, per-step logging + waits)",
  "parameters": {
    "arcgisPortalFileServer": { "type": "String" },
    "arcgisPortalPrimary": { "type": "String" }
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
          "LOG_DIR=/var/log/portal-config",
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
          "LOG_DIR=/var/log/portal-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/downloadAssets.log\") 2>&1",
          "echo \"=== downloadAssets: starting at $(date) ===\"",
          "",
          "mkdir -p \"${portal_certs_dir}\"",
          "aws s3 cp \"s3://${s3_bucket}/${portal_root_cert_name}\" \"${portal_certs_dir}/${portal_root_cert_name}\" --region ${s3_region} || (echo 'Failed to download root cert' >&2; exit 1)",
          "aws s3 cp \"s3://${s3_bucket}/${portal_pfx_cert_name}\"  \"${portal_certs_dir}/${portal_pfx_cert_name}\" --region ${s3_region} || (echo 'Failed to download pfx cert' >&2; exit 1)",
          "",
          "mkdir -p \"${portal_license_dir}/${esri_version}\"",
          "aws s3 cp \"s3://${s3_bucket}/${portal_license_name}\" \"${portal_license_dir}/${esri_version}/${portal_license_name}\" --region ${s3_region} || (echo 'Failed to download license' >&2; exit 1)",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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

          "LOG_DIR=/var/log/portal-config",
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
          "LOG_DIR=/var/log/portal-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/portal-fileserver.log\") 2>&1",
          "echo \"=== runFileServerConfig: starting at $(date) ===\"",
          "",
          "echo '${arcgisPortalFileServer}' | base64 --decode > /opt/cinc/attributes/arcgis-portal-fileserver.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-portal-fileserver.json 2>&1 | tee -a \"$LOG_DIR/portal-fileserver.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"FileServer cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/portal_fileserver_done",
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
          "LOG_DIR=/var/log/portal-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForFileServer.log\") 2>&1",
          "echo \"Waiting for portal_fileserver_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/portal_fileserver_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for portal_fileserver_done' >&2; exit 1; fi",
          "done",
          "echo \"portal_fileserver_done found, continuing.\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "runPortalPrimaryConfig",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/portal-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/portal-primary.log\") 2>&1",
          "echo \"=== runPortalPrimaryConfig: starting at $(date) ===\"",
          "",
          "echo '${arcgisPortalPrimary}' | base64 --decode > /opt/cinc/attributes/arcgis-portal-primary.json",
          "cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-portal-primary.json 2>&1 | tee -a \"$LOG_DIR/portal-primary.log\"",
          "RC=$${PIPESTATUS[0]}",
          "if [ $RC -ne 0 ]; then echo \"Portal Primary cinc-client failed with exit $RC\" >&2; exit $RC; fi",
          "touch /var/run/portal_primary_done",
          "echo \"=== runPortalPrimaryConfig: finished at $(date) ===\""
        ]
      }
    },

    {
      "action": "aws:runShellScript",
      "name": "waitForPortalPrimary",
      "inputs": {
        "runCommand": [
          "#!/bin/bash",
          "set -euxo pipefail",
          "",
          "LOG_DIR=/var/log/portal-config",
          "mkdir -p \"$LOG_DIR\"",
          "exec > >(tee -a \"$LOG_DIR/waitForPortalPrimary.log\") 2>&1",
          "echo \"Waiting for portal_primary_done marker...\"",
          "COUNT=0",
          "while [ ! -f /var/run/portal_primary_done ]; do",
          "  sleep 5",
          "  COUNT=$((COUNT+1))",
          "  if [ $COUNT -ge 720 ]; then echo 'Timed out waiting for portal_primary_done' >&2; exit 1; fi",
          "done",
          "echo \"portal_primary_done found, continuing.\""
        ]
      }
    }

  ]
}
