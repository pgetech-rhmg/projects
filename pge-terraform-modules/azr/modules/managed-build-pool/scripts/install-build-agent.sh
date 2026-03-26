#!/bin/bash
# Azure DevOps Build Agent Installation Script
# Runs on VM startup to configure and register the build agent
#
# Environment variables (provided by Terraform custom_data):
# - ADO_URL: Azure DevOps organization URL
# - ADO_PAT_TOKEN: Personal access token for registration
# - POOL_NAME: ADO agent pool name
# - AGENT_PREFIX: Prefix for agent names
# - MANAGED_IDENTITY_ID: Managed identity resource ID

set -e

# Logging
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/ado-agent-setup.log
}

# Error handling
trap 'log "ERROR: Agent installation failed at line $LINENO"' ERR

log "Starting ADO Build Agent installation..."
log "ADO URL: $ADO_URL"
log "Pool: $POOL_NAME"
log "Agent Prefix: $AGENT_PREFIX"

# Step 1: Install dependencies
log "Step 1: Installing system dependencies..."
apt-get update
apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    libffi-dev \
    python3-dev \
    python3-pip \
    jq

# Step 2: Install Docker (optional but useful for most builds)
log "Step 2: Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker azureuser

# Step 3: Install Node.js (optional but common)
log "Step 3: Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Step 4: Install Azure CLI
log "Step 4: Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Step 5: Create agent directory
log "Step 5: Creating agent directory..."
AGENT_DIR="/home/azureuser/ado-agent"
mkdir -p "$AGENT_DIR"
chown -R azureuser:azureuser "$AGENT_DIR"

# Step 6: Download and extract ADO agent
log "Step 6: Downloading ADO agent..."
cd "$AGENT_DIR"

# Get the agent download URL from ADO organization
AGENT_VERSION=$(curl -s https://vstsagentpackage.azureedge.net/agent/releases | jq -r 'sort_by(.version) | reverse[0].version')
AGENT_URL="https://vstsagentpackage.azureedge.net/agent/$AGENT_VERSION/vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"

log "Agent Version: $AGENT_VERSION"
log "Downloading from: $AGENT_URL"

sudo -u azureuser curl -O "$AGENT_URL"
sudo -u azureuser tar -xzf "vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"
rm "vsts-agent-linux-x64-$AGENT_VERSION.tar.gz"

# Step 7: Configure the agent
log "Step 7: Configuring ADO agent..."

# Get hostname for unique agent name
HOSTNAME_SHORT=$(hostname -s)
AGENT_NAME="${AGENT_PREFIX}-${HOSTNAME_SHORT}"

# Create a script to configure the agent (runs as azureuser)
cat > /tmp/configure-agent.sh << 'EOF'
#!/bin/bash
AGENT_DIR="/home/azureuser/ado-agent"
cd "$AGENT_DIR"

# Configure agent with PAT token
./config.sh \
    --unattended \
    --url "$1" \
    --auth "pat" \
    --token "$2" \
    --pool "$3" \
    --agent "$4" \
    --acceptTeeEula \
    --work "_work"

# Install and start as service
./svc.sh install azureuser
./svc.sh start

exit_code=$?
EOF

chmod +x /tmp/configure-agent.sh
sudo -u azureuser /tmp/configure-agent.sh "$ADO_URL" "$ADO_PAT_TOKEN" "$POOL_NAME" "$AGENT_NAME"

log "Step 8: Setting up managed identity integration..."
cat > /tmp/setup-identity.sh << 'EOF'
#!/bin/bash
# Install and configure managed identity for the agent
# This allows the agent to use Azure resources securely

# Install Managed Identity extension
az extension add --name managedservices --allow-preview 2>/dev/null || true

# Verify identity is accessible
IDENTITY_TOKEN=$(curl -H Metadata:true "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com" -s | jq -r '.access_token')

if [ ! -z "$IDENTITY_TOKEN" ] && [ "$IDENTITY_TOKEN" != "null" ]; then
    echo "Managed identity is accessible"
else
    echo "Warning: Managed identity may not be properly configured"
fi
EOF

chmod +x /tmp/setup-identity.sh
sudo -u azureuser /tmp/setup-identity.sh

# Step 9: Verify agent is running
log "Step 9: Verifying agent status..."
sleep 5

if systemctl is-active --quiet azureuser-ado-agent@1; then
    log "SUCCESS: ADO Build Agent is running"
    systemctl status azureuser-ado-agent@1 || true
else
    log "WARNING: ADO Build Agent may not be running correctly"
    journalctl -u azureuser-ado-agent@1 -n 50 || true
fi

log "Agent installation completed successfully!"
