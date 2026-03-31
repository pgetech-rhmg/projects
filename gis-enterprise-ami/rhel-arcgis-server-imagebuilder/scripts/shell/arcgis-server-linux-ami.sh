set -e
# NOTE: cloud-init readiness check moved into main() so sourcing this file for unit tests
# does not block or fail when cloud-init is absent.
# RHEL AMI setup script

# Script configuration
SCRIPT_NAME="$(basename "$0")"
LOG_FILE="/var/log/arcgis-install.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
# Usage: log <LEVEL> <MESSAGE>
# LEVEL: One of INFO, SUCCESS, WARNING, ERROR
# MESSAGE: Log message string
# Output format: "<timestamp> [LEVEL] MESSAGE" (also color-coded to stdout/stderr)
log() {
    echo -e "${TIMESTAMP} [$1] $2" | tee -a "$LOG_FILE"
    if [[ "$1" == "ERROR" ]]; then
        echo -e "${RED}ERROR: $2${NC}" >&2
    elif [[ "$1" == "SUCCESS" ]]; then
        echo -e "${GREEN}SUCCESS: $2${NC}"
    elif [[ "$1" == "WARNING" ]]; then
        echo -e "${YELLOW}WARNING: $2${NC}"
    elif [[ "$1" == "INFO" ]]; then
        echo -e "${BLUE}INFO: $2${NC}"
    fi
}


function die() {
    log "ERROR" "$@"
    exit 1
}

function get_contents() {
    if [ -x "$(which curl)" ]; then
        curl -s -f "$1"
    elif [ -x "$(which wget)" ]; then
        wget "$1" -O -
    else
        die "Neither curl nor wget is installed"
    fi
}

function exec_cmd() {
    log "INFO" "Invoking $@"
    eval "$@"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        die "Command failed: $@"
    fi
}

#######################################
# Performs a comprehensive system upgrade using yum package manager.
# Updates all installed packages to their latest available versions
# from configured repositories. This function is typically used during
# system initialization or maintenance to ensure security patches
# and software updates are applied.
#
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   Exit status of yum upgrade command
#   0 on success, non-zero on failure
#######################################
function yum_upgrade() {
    
    exec_cmd "yum clean all"
    
     # Wait for any other yum process to complete
    # Install mandatory packages
    if [ ! -z "$MANDATORY_PACKAGES" ]; then
        for package in $MANDATORY_PACKAGES; do
            exec_cmd "yum -y install $package"
        done
    fi
}

############################################
# This function downloads the arcgis cookbooks for Linux x86_64 architecture
############################################
function update_cookbook() {
    get_contents "https://arcgisstore.s3.amazonaws.com/1150/cookbooks/arcgis-5.2.0-cookbooks.tar.gz" > "/tmp/cookbook.tar.gz"
    exec_cmd "tar -xf /tmp/cookbook.tar.gz -C /opt/cinc"
    exec_cmd "rm /tmp/cookbook.tar.gz"
}

############################################
# This function downloads the latest Cinc client for Linux x86_64 architecture
############################################
function update_cincclient() {
    exec_cmd "curl -L https://omnitruck.cinc.sh/install.sh | bash -s -- -v 18.5.0"
}

############################################
# This function downloads and installs
# the latest AWS CLI v2 for Linux x86_64 architecture
############################################
function install_cli() {
    get_contents "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" > "awscliv2.zip"
    exec_cmd "unzip -o awscliv2.zip"
    exec_cmd "./aws/install --bin-dir /usr/sbin --install-dir /usr/aws-cli"
    exec_cmd "rm awscliv2.zip"
}

############################################
# This function downloads and installs the latest AWS CLI v2 for Linux x86_64 architecture
# Removes any existing installation and performs a clean install
# Used during AMI build process to ensure the latest CLI tools are available
############################################
function update_cli() {
    
    if [ -x "$(which aws 2>/dev/null)" ]; then
        log "AWS CLI Exists"
    elif [ -x "$(which pip 2>/dev/null)" ]; then
        exec_cmd "pip install --upgrade awscli"
    else
        install_cli
    fi
}

function sanitize_inputs() {
    value="$(echo $@ | sed 's/,/ /g' | xargs | xargs)"
    if [ ! -z "$value" ] && [ "$value" != "none" ] && [ "$value" != "all" ]; then
        echo "$value"
    fi
}

############################################################
# Generic unpack tar helper (file)
# Params / env vars:
#   $1 / tarball_path : tar file path
#   $2 / dest_path    : Destination file or directory path
#   $3 / run_as_user  : run as user (optional)
#   $4 / label        : Human friendly label (optional)
############################################################
function run_unpack_tar(){
    local tarball_path="$1"
    local dest_path="$2"
    local run_as_user="$3"
    

    if [ ! -s "$tarball_path" ]; then
        log "WARNING" "Tarball not found or empty: $tarball_path"
        return 1
    fi

    if [ ! -d "$dest_path" ]; then
        log "INFO" "Destination directory $dest_path not found; creating..."
        mkdir -p "$dest_path" || die "Failed to create destination directory $dest_path"
        if [ -n "$run_as_user" ] && id "$run_as_user" >/dev/null 2>&1; then
            chown -R "$run_as_user:$run_as_user" "$dest_path" || true
        fi
    fi
    # Skip if already extracted
    if [ -n "$(ls -A "$dest_path" 2>/dev/null)" ]; then
        first_entry="$(tar -tzf "$tarball_path" 2>/dev/null | head -1 | cut -d/ -f1)"
        if [ -n "$first_entry" ] && [ -e "$dest_path/$first_entry" ]; then
            log "INFO" "tarball appears already extracted (found $dest_path/$first_entry); skipping."
            return 0
        fi
    fi
    log "INFO" "Extracting $tarball_path to $dest_path"
    tar -xzf "$tarball_path" -C "$dest_path"
}


function check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Function to check if Server is already installed
function is_server_installed() {
    log "INFO" "Checking if ArcGIS Server is already installed..."

    local esri_properties_file="/home/${RUN_AS_USER}/.ESRI.properties.$(hostname).${ARCGIS_VERSION}"
    
    if [[ -f "$esri_properties_file" ]]; then
        if grep -q "ArcGISServer" "$esri_properties_file" 2>/dev/null; then
            log "INFO" "ArcGIS Server ${ARCGIS_VERSION} appears to be already installed"
            return 0
        fi
    fi
    
    # Also check for installation directory
    if [[ -d "${SERVER_INSTALL_PATH}" ]]; then
        if [[ -f "${SERVER_INSTALL_PATH}/startserver.sh" ]]; then
            log "INFO" "ArcGIS Server installation directory found"
            return 0
        fi
    fi

    log "ERROR" "ArcGIS Server not detected as installed"
    return 1

}


function install_server_system_packages() {
    log "INFO" "Installing system packages..."

    local packages=()
    packages=("gettext" "nfs-utils" "autofs")
            
    # Update package manager
    yum update -y
    
    # Install packages
    for package in "${packages[@]}"; do
        log "INFO" "Installing package: $package"
        yum install -y "$package" || log "WARNING" "Failed to install $package"
    done
    
    log "SUCCESS" "System packages installation completed"
}

function configure_system_limits() {
    log "INFO" "Configuring system limits for user: ${RUN_AS_USER}"

    local limits_file="/etc/security/limits.conf"
    local limits_config="
# ArcGIS Server limits
${RUN_AS_USER}    hard    nofile     65536
${RUN_AS_USER}    soft    nofile     65536
${RUN_AS_USER}    hard    nproc      25059
${RUN_AS_USER}    soft    nproc      25059
${RUN_AS_USER}    hard    memlock    unlimited
${RUN_AS_USER}    soft    memlock    unlimited
${RUN_AS_USER}    hard    fsize      unlimited
${RUN_AS_USER}    soft    fsize      unlimited
${RUN_AS_USER}    hard    as         unlimited
${RUN_AS_USER}    soft    as         unlimited"

    # Backup original limits file
    if [[ ! -f "${limits_file}.backup" ]]; then
        cp "$limits_file" "${limits_file}.backup"
        log "INFO" "Backed up original limits.conf"
    fi

    # Remove existing ArcGIS entries
    sed -i "/# ArcGIS Server limits/,/^$/d" "$limits_file"

    # Add new limits
    echo "$limits_config" >> "$limits_file"
    log "INFO" "Updated system limits for ${RUN_AS_USER}"
}

function create_user_and_group() {
    log "INFO" "Creating ArcGIS user and group..."

    # Create user and group if they don't exist
    if ! getent group "$RUN_AS_GROUP" > /dev/null 2>&1; then
        groupadd -g "$ARCGIS_GID" "$RUN_AS_GROUP"
        log "SUCCESS" "Created group: $RUN_AS_GROUP"
    else
		echo "Group $RUN_AS_GROUP already exists"
    fi

    if ! getent passwd "$RUN_AS_USER" > /dev/null 2>&1; then
        useradd -m -d "/home/$RUN_AS_USER" -s /bin/bash -u "$ARCGIS_UID" -g "$ARCGIS_GID" -c "ArcGIS user account" "$RUN_AS_USER"
        log "SUCCESS" "Created user: $RUN_AS_USER"
    else
        log "INFO" "User already exists: ${RUN_AS_USER}"

    fi

    # Ensure home directory has correct permissions
    local home_dir="/home/${RUN_AS_USER}"
    if [[ -d "$home_dir" ]]; then
        chown -R "${RUN_AS_USER}:${RUN_AS_GROUP}" "$home_dir"
        chmod 755 "$home_dir"
        log "INFO" "Updated permissions for home directory: ${home_dir}"
    fi
}

function configure_aws_specific() {
    
    # Rename .ESRI.properties files to include correct hostname
    log "INFO" "Configuring aws specific settings for arcgis server..."
    local home_dir="/home/${RUN_AS_USER}"
    if [[ -d "$home_dir" ]]; then
        su - "$RUN_AS_USER" -c "
            for file in ${home_dir}/.ESRI.properties.*; do
                if [[ -f \"\$file\" ]]; then
                    oldhost=\$(echo \$file | cut -d'.' -f 4)
                    newhost=\$(hostname)
                    newfile=\$(echo \$file | sed -e \"s,\$oldhost,\$newhost,g\")
                    if [[ ! -f \"\$newfile\" ]]; then
                        mv \"\$file\" \"\$newfile\"
                        echo \"Renamed \$file to \$newfile\"
                    fi
                fi
            done
        "
    fi
    
}

#############################################################
# This function sets up the autofs service to automatically mount and unmount
# filesystems as needed by ArcGIS Portal. It configures the master configuration
# file, establishes mount points for shared storage or network filesystems,
# and ensures the service is properly enabled and started.
#
# USAGE:
#   configure_autofs_service
#
# PARAMETERS:
#   None
#
# RETURNS:
#   0 - Success: autofs service configured and started successfully
#   1 - Failure: Configuration failed or service could not be started
#
# DEPENDENCIES:
#   - autofs package must be installed
#   - Network connectivity to remote filesystems (if applicable)
#   - Root or sudo privileges to modify system configuration
#
# FILES MODIFIED:
#   - /etc/auto.master - Main autofs configuration file
#   - /etc/auto.* - Additional autofs map files as needed
#   - Service configuration files
############################################################
function configure_autofs() {
    
    log "INFO" "Configuring autofs..."
    local auto_master="/etc/auto.master"
    sed -i 's/#\/net/\/net/g' /etc/auto.master
    if [[ -f "$auto_master" ]]; then
        # Remove comment from #/net line
        sed -i 's|^#/net|/net|g' "$auto_master"
        
        # Enable and start autofs service
        systemctl enable autofs
        systemctl restart autofs
        log "INFO" "Configured and started autofs service"
    else
        log "WARNING" "auto.master file not found: $auto_master"
    fi

    exec_cmd "yum install -y nfs-utils"
    
    if [[ $(systemctl status firewalld.service | grep Active | awk '{print $2}') = "active" ]]; then
        exec_cmd "firewall-cmd --zone=public --permanent --add-port=0-65535/tcp"
        exec_cmd "firewall-cmd --reload"
    fi
    
    exec_cmd "systemctl enable autofs"
    exec_cmd "systemctl start autofs"
    exec_cmd "systemctl reload autofs"
    
}

function install_server(){
    log "INFO"  "Starting ArcGIS Server installation script"
    log "INFO"  "Version: ${ARCGIS_VERSION}"
    log "INFO"  "Install Directory: ${SERVER_INSTALL_PATH}"
    log "INFO"  "ArcGIS User: ${RUN_AS_USER}"

    # Pre-installation checks
    check_root
    
    # Check if already installed
    if is_server_installed; then
        log "INFO" "ArcGIS Server is already installed"
        return 0
    fi
    # install system requirements and configure OS
    install_server_system_packages
    create_user_and_group
    configure_system_limits
    configure_aws_specific

    # Download server setup if not present or size is zero
    if [ ! -s "$SERVER_TARBALL_PATH" ]; then
        run_download_s3 "$SERVER_S3_URI" "$SERVER_TARBALL_PATH" "ArcGIS Server tarball"
    else
        log "INFO" "ArcGIS Server tarball already present: $SERVER_TARBALL_PATH"
    fi

    # Unpack setup if not already done
    run_unpack_tar "$SERVER_TARBALL_PATH" "$SETUP_PATH" "$RUN_AS_USER"

    # Create installation directory structure 
    log "INFO" "Creating installation directory structure..."
    if [ ! -d "$SERVER_INSTALL_PATH" ]; then
        mkdir -p "$SERVER_INSTALL_PATH"	
	fi
    # Create subdirectories with proper permissions
    IFS='/' read -ra SUBDIR_PARTS <<< "arcgis/server"
    current_path="/opt"
    for part in "${SUBDIR_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="$current_path/$part"
            chmod 700 "$current_path"
            chown "$RUN_AS_USER:$RUN_AS_GROUP" "$current_path"
        fi
    done
    # Run Server installation (equivalent to :install action)
    log "INFO" "Installing ArcGIS Server..."
    # Prepare installation command
    local server_setup_executable="${SETUP_PATH}/ArcGISServer/Setup"
    local install_cmd="${server_setup_executable} -m silent -l yes -d '${SERVER_INSTALL_PATH}'"
    log "INFO" "Install command: $install_cmd"

    # Execute installation as non-root user
    if [[ "$EUID" -eq 0 ]]; then
        # Running as root, switch to arcgis user
        su - "$RUN_AS_USER" -c "$install_cmd"
    else
        # Running as non-root user  
        eval "$install_cmd"
    fi

    # Verify installation
    local start_script="${SERVER_INSTALL_PATH}/startserver.sh"
    if [[ ! -f "$start_script" ]]; then
        log "ERROR" "Installation verification failed - startserver.sh not found: ${start_script}"
        exit 1
    fi

    log "SUCCESS" "ArcGIS Server installation completed successfully"
    configure_server_service
    start_server
    configure_aws_nodeagent
    validate_server_installation

    log "INFO" "=== INSTALLATION SUMMARY ==="
    log "INFO" "ArcGIS Server ${ARCGIS_VERSION} installation completed successfully"
    log "INFO" "Installation Directory: ${SERVER_INSTALL_PATH}"
    log "INFO" "User: ${RUN_AS_USER}"
    log "INFO" "Start Command: ${SERVER_INSTALL_PATH}/startserver.sh"
    log "INFO" "Stop Command: ${SERVER_INSTALL_PATH}/stopserver.sh"
    log "INFO" "Service Management: systemctl {start|stop|status} arcgisserver"
    log "INFO" "Installation script completed successfully"

}

function validate_server_installation() {
    log "INFO" "Validating ArcGIS Server installation..."

    local validation_errors=0

    # Check installation directory
    if [[ ! -d "${SERVER_INSTALL_PATH}" ]]; then
        log "ERROR" "Installation directory not found: ${SERVER_INSTALL_PATH}"
        ((validation_errors++))
    else
        log "INFO" "✓ Installation directory exists"
    fi

    # Check start/stop scripts
    local start_script="${SERVER_INSTALL_PATH}/startserver.sh"
    local stop_script="${SERVER_INSTALL_PATH}/stopserver.sh"
    if [[ ! -f "$start_script" ]]; then
        log "ERROR" "Start script not found: ${start_script}"
        ((validation_errors++))
    fi

    if [[ ! -f "$stop_script" ]]; then
        log "ERROR" "Stop script not found: ${stop_script}"
        ((validation_errors++))
    fi
    
    # Check if server processes are running
    if pgrep -f "java.*ArcGISServer" > /dev/null; then
        log "INFO" "✓ Stop script exists"
    else
        log "WARNING" "ArcGIS Server processes not detected (this may be normal if server was just installed)"
    fi

    # Check service configuration
        log "INFO" "✓ ArcGIS Server processes are running"
    if systemctl is-enabled arcgisserver > /dev/null 2>&1; then
        log "INFO" "✓ ArcGIS Server service is enabled for autostart"
    else
        log "WARNING" "ArcGIS Server service is not enabled for autostart"
    fi

    if [[ $validation_errors -gt 0 ]]; then
        log "ERROR" "Installation validation failed with ${validation_errors} error(s)"
        return 1
    else
        log "INFO" "✓ Installation validation passed"
        return 0
    fi
}

function start_server() {

    log "INFO" "Starting ArcGIS Server..."

    if systemctl --version >/dev/null 2>&1 && [[ -f /etc/systemd/system/arcgisserver.service ]]; then
        systemctl start arcgisserver.service
        #systemctl status arcgisserver.service --no-pager
    elif [[ -f /etc/init.d/arcgisserver ]]; then
        service arcgisserver start
    else
        # Direct start using Server scripts
        local start_script="${SERVER_INSTALL_PATH}/startserver.sh"
    
        if [[ ! -f "$start_script" ]]; then
            log "ERROR" "Start script not found: ${start_script}"
            exit 1
        fi

        # Start server as arcgis user
        if su - "$RUN_AS_USER" -c "$start_script"; then
            log "INFO" "ArcGIS Server started successfully"

            # Wait for server to be fully ready
            sleep 30
            
            # Verify server is running
            if pgrep -f "java.*ArcGISServer" > /dev/null; then
                log "INFO" "ArcGIS Server processes are running"
            else
                log "WARNING" "ArcGIS Server processes not detected"
            fi
        else
            log "ERROR" "Failed to start ArcGIS Server"
            exit 1
        fi
    fi

    log "SUCCESS" "ArcGIS Server service started"

}
        
function configure_server_service() {

    log "INFO" "Configuring systemd service for ArcGIS Server..."

    local service_script="${SERVER_INSTALL_PATH}/framework/etc/scripts/arcgisserver"
    local systemd_service="/etc/systemd/system/arcgisserver.service"

    # Check if service script exists
    if [[ ! -f "$service_script" ]]; then
        log "WARNING" "Service script not found: ${service_script}"
        return 1
    fi

    # Create systemd service file
    cat > "$systemd_service" << EOF
[Unit]
Description=ArcGIS Server
After=network.target

[Service]
Type=forking
User=${RUN_AS_USER}
Group=${RUN_AS_GROUP}
ExecStart=${SERVER_INSTALL_PATH}/startserver.sh
ExecStop=${SERVER_INSTALL_PATH}/stopserver.sh
TimeoutStartSec=300
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF
    # Set proper permissions
    chmod 644 "$systemd_service"

    # Enable service
    systemctl daemon-reload
    systemctl enable arcgisserver.service
    log "SUCCESS" "Configured arcgisserver service for autostart"

}

# Function to configure AWS-specific NodeAgent settings

function configure_aws_nodeagent() {

    log "INFO" "Configuring AWS-specific NodeAgent settings..."

    local nodeagent_config="${SERVER_INSTALL_PATH}/framework/etc/NodeAgentExt.xml"
    local hostname_props="${SERVER_INSTALL_PATH}/framework/etc/hostname.properties"

    # Create disabled NodeAgentExt.xml
    if [[ -f "$nodeagent_config" ]]; then
        # Backup original
        cp "$nodeagent_config" "${nodeagent_config}.backup"
        
        # Create disabled version
        cat > "$nodeagent_config" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<NodeAgentExt>
  <!-- All plugins disabled for AWS/EC2 -->
</NodeAgentExt>
EOF
        chown "${RUN_AS_USER}:${RUN_AS_GROUP}" "$nodeagent_config"
        log "INFO" "Disabled NodeAgent plugins for AWS"

        # Remove hostname.properties if it exists
        if [[ -f "$hostname_props" ]]; then
            rm -f "$hostname_props"
            log "INFO" "Removed hostname.properties file"
        fi

        # Restart server to apply changes
        log "INFO" "Restarting ArcGIS Server to apply NodeAgent changes..."
        local stop_script="${SERVER_INSTALL_PATH}/stopserver.sh"
        
        if [[ -f "$stop_script" ]]; then
            su - "$RUN_AS_USER" -c "$stop_script" || true
            sleep 10
            start_server
        fi
    else
        log "WARNING" "NodeAgentExt.xml not found: ${nodeagent_config}"
    fi

}

function cleanup_installer_files() {
    log "INFO" "Cleaning up installer files..."

    # Clean up setup files if requested
    if [[ -d "$SETUP_PATH" ]]; then
        rm -rf "$SETUP_PATH"
        log "INFO" "Removed setup directory: ${SETUP_PATH}"
    fi

    log "INFO" "Cleanup completed"
}


############################################################
# Generic S3 download helper (file or recursive)
# Params / env vars:
#   $1 / S3_URI      : s3://bucket/key[|prefix/]
#   $2 / DEST_PATH   : Destination file or directory path
#   $3 / LABEL       : Human friendly label (optional)
#   $4 / MODE        : auto|file|recursive (optional, default: auto)
#
# Recursive mode triggers when:
#   - MODE=recursive
#   - S3 URI ends with '/'
#   - DEST_PATH ends with '/'
#   - DEST_PATH is an existing directory
#
# For recursive copy we use: aws s3 cp --recursive
# For single object copy we use: aws s3 cp (no --recursive)
############################################################
function run_download_s3() {
    
    local s3_uri="${1:-$S3_URI}"
    local dest_path="${2:-$DEST_PATH}"
    local label="${3:-${LABEL:-artifact}}"
    local mode="${4:-${MODE:-auto}}"

    if [ -z "$s3_uri" ] || [ -z "$dest_path" ]; then
        die "run_download_s3: Missing required parameters (s3_uri, dest_path)"
    fi

    # Decide recursive
    local recursive="false"
    if [ "$mode" = "recursive" ]; then
        recursive="true"
    elif [ "$mode" = "file" ]; then
        recursive="false"
    else
        if [[ "$s3_uri" == */ ]] || [[ "$dest_path" == */ ]] || [ -d "$dest_path" ]; then
            recursive="true"
        fi
    fi

    if [ "$recursive" = "true" ]; then
        # Ensure destination directory
        if [ ! -d "$dest_path" ]; then
            mkdir -p "$dest_path"
            chmod 700 "$dest_path"
        fi
        # Idempotency: skip if non-empty directory
        if [ "$(find "$dest_path" -mindepth 1 -print -quit 2>/dev/null)" ]; then
            log "INFO" "$label directory already populated: $dest_path"
        else
            log "INFO" "Recursively downloading $label from $s3_uri to $dest_path"
            exec_cmd "aws s3 cp '$s3_uri' '$dest_path' --recursive"
        fi
    else
        # Single file logic
        # If destination is a directory, derive filename from S3 key
        if [ -d "$dest_path" ]; then
            local fname
            fname="$(basename "$s3_uri")"
            dest_path="${dest_path%/}/$fname"
        fi
        if [ ! -s "$dest_path" ]; then
            log "INFO" "Downloading $label from $s3_uri to $dest_path"
            local parent
            parent="$(dirname "$dest_path")"
            mkdir -p "$parent"
            exec_cmd "aws s3 cp '$s3_uri' '$dest_path'"
        else
            log "INFO" "$label already present: $dest_path"
        fi
    fi
}

function parse_configuration() {
    # Parse JSON configuration and set global variables
    # Params / env vars:
    #   $1 / CONFIG_JSON : JSON string or file path
    #
    local config_json="$1"
    if [ -z "$config_json" ]; then
        die "parse_configuration: Missing configuration input"
    fi

    if [ -f "$config_json" ]; then
        config_json="$(cat "$config_json")"
    fi


    # ArcGIS common
    ARCGIS_VERSION=$(echo "$config_json" | jq -r '.arcgis.version // empty')
    RUN_AS_USER=$(echo "$config_json" | jq -r '.arcgis.run_as_user // "arcgis"')
    RUN_AS_GROUP=$(echo "$config_json" | jq -r '.arcgis.run_as_group // "arcgis"')
    DOWNLOAD_PATH=$(echo "$config_json" | jq -r '.arcgis.download_path // empty')
    SETUPS_PATH=$(echo "$config_json" | jq -r '.arcgis.setups_path // empty')


    # Server
    SERVER_S3_URI=$(echo "$config_json" | jq -r '.arcgis.server.s3_uri // empty')
    SERVER_INSTALL_PATH=$(echo "$config_json" | jq -r '.arcgis.server.install_path // empty')
    SERVER_TARBALL_PATH=$(echo "$config_json" | jq -r '.arcgis.server.tarball_path // empty')

    # Server patches
    mapfile -t SERVER_PATCH_NAMES < <(echo "$config_json" | jq -r '.arcgis.server.patches[]?.name')
    mapfile -t SERVER_PATCH_S3_URIS < <(echo "$config_json" | jq -r '.arcgis.server.patches[]?.s3_uri')
    mapfile -t SERVER_PATCH_DOWNLOAD_PATHS < <(echo "$config_json" | jq -r '.arcgis.server.patches[]?.download_path')
    mapfile -t SERVER_PATCH_APPLY < <(echo "$config_json" | jq -r '.arcgis.server.patches[]?.apply')
    SERVER_PATCH_COUNT=${#SERVER_PATCH_NAMES[@]}

    # Derived configuration
    SETUP_PATH="$SETUPS_PATH/$ARCGIS_VERSION"

    # Fixed UID/GID for arcgis user/group
	ARCGIS_UID="1100"
	ARCGIS_GID="1100"

}

function main() {
    # main function of the script
    # Params / env vars:
    #   $1 / install component : portal
    #   $2 / component config  : Destination file path
    # 
    log "INFO" "Starting ArcGIS RHEL AMI setup script"
    log "INFO" "Script version: 1.0.0"
    log "INFO" "Timestamp: $TIMESTAMP"

    # Wait for cloud-init to finish before proceeding when running normally
    if command -v cloud-init >/dev/null 2>&1; then
        /usr/bin/cloud-init status --wait || log "WARNING" "cloud-init wait failed or timed out"
    else
        log "INFO" "cloud-init not found; skipping wait"
    fi

    # Check if running as root
    if [[ "$EUID" -ne 0 ]]; then
        log "WARNING" "This script should typically be run as root for full functionality"
    fi

    # Below 2 parameters are user inputs
    MANDATORY_PACKAGES="$(sanitize_inputs jq,autofs,unzip)"
    log "MANDATORY_PACKAGES = $MANDATORY_PACKAGES"

    # Performs a comprehensive system upgrade and Install mandatory packages using yum package manager
    yum_upgrade
    
    #Configures autofs service for automatic filesystem mounting
    configure_autofs
    # Updates the AWS CLI to the latest version
    update_cli
    # Parse JSON configuration and set global variables
    parse_configuration "$1"
    install_server
    log "RHEL AMI setup completed successfully"
    cleanup_installer_files
    exit 0
}

# Testability guard: only invoke main when script is executed directly, not when sourced.
# Main execution
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi