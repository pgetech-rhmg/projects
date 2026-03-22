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
###########################################################
# Generic unpack tar helper (file)
# Params / env vars:
#   $1 / tarball_path : tar file path
#   $2 / dest_path    : Destination file or directory path
#   $3 / run_as_user  : run as user (optional)
#   $4 / label        : Human friendly label (optional)
#############################################################
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

function configure_autofs() {
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

function is_datastore_installed() {
    log "INFO" "Checking if ArcGIS DataStore is already installed..."

    local esri_properties_file="/home/${RUN_AS_USER}/.ESRI.properties.$(hostname).${ARCGIS_VERSION}"
    
    if [[ -f "$esri_properties_file" ]]; then
        if grep -q "ArcGISDataStore" "$esri_properties_file" 2>/dev/null; then
            log "INFO" "ArcGIS DataStore ${ARCGIS_VERSION} appears to be already installed"
            return 0
        fi
    fi
    
    # Also check for installation directory
    if [[ -d "${DATA_STORE_INSTALL_PATH}" ]]; then
        if [[ -f "${DATA_STORE_INSTALL_PATH}/startdatastore.sh" ]]; then
            log "INFO" "ArcGIS DataStore installation directory found"
            return 0
        fi
    fi

    log "INFO" "ArcGIS DataStore not detected as installed"
    return 1
}

function install_epel_release() {
    log "INFO" "Installing EPEL repository..."

    # Ensure EPEL repository; fall back to RPM download if epel-release package is unavailable
    if ! ls /etc/yum.repos.d/epel*.repo >/dev/null 2>&1; then
        if command -v dnf >/dev/null 2>&1; then
            if ! dnf -y install epel-release; then
                releasever=$(rpm -E %rhel 2>/dev/null || rpm -q --qf '%{VERSION}' -f /etc/redhat-release | cut -d. -f1)
                rpm_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${releasever}.noarch.rpm"
                dnf -y install "$rpm_url" || log "WARNING" "Failed to install EPEL from ${rpm_url}"
            fi
        else
            if ! yum -y install epel-release; then
                releasever=$(rpm -E %rhel 2>/dev/null || rpm -q --qf '%{VERSION}' -f /etc/redhat-release | cut -d. -f1)
                rpm_url="https://dl.fedoraproject.org/pub/epel/epel-release-latest-${releasever}.noarch.rpm"
                yum -y install "$rpm_url" || log "WARNING" "Failed to install EPEL from ${rpm_url}"
            fi
        fi
    else
        log "INFO" "EPEL repository already present"
    fi
}

function install_datastore_rhel_packages() {
    log "INFO" "Installing RHEL system packages..."

    # Install EPEL repository for additional packages
    install_epel_release

    # Required packages for ArcGIS DataStore
    local packages=(
        "gettext"
        "curl"
        "wget"
        "unzip"
        "tar"
        "gzip"
        "which"
        "hostname"
        "net-tools"
        "procps-ng"
        "util-linux"
        "systemd"
        "sudo"
        "fontconfig"
        "libX11"
        "libXext"
        "libXtst"
        "libXi"
        "libXrender"
        "libXrandr"
        "glibc-langpack-en"
    )

    for package in "${packages[@]}"; do
        log "INFO" "Installing package: $package"
        yum install -y "$package" || log "WARNING" "Failed to install $package"
    done

    log "INFO" "RHEL system packages installation completed"
}

function install_datastore(){
    log "INFO" "Starting ArcGIS DataStore installation script for RHEL/CentOS"
    log "INFO" "Version: ${ARCGIS_VERSION}"
    log "INFO" "Install Directory: ${DATA_STORE_INSTALL_PATH}"
    log "INFO" "Data Directory: ${DATASTORE_DATA_DIR}"
    log "INFO" "ArcGIS User: ${RUN_AS_USER}"

    # Pre-installation checks
    check_root

    # Check if already installed
    if is_datastore_installed; then
        log "INFO" "ArcGIS DataStore appears to be already installed. Skipping installation."
        log "INFO" "To force reinstallation, remove the installation directory and .ESRI.properties files"
        exit 0
    fi

    # Install required RHEL packages
    install_datastore_rhel_packages
    configure_datastore_rhel_firewall
    configure_datastore_system_limits
    optimize_system_for_datastore
    create_user_and_group
    
    # Download DataStore setup if not present or size is zero
    if [ ! -s "$DATA_STORE_TARBALL_PATH" ]; then
        run_download_s3 "$DATA_STORE_S3_URI" "$DATA_STORE_TARBALL_PATH" "ArcGIS DataStore tarball"
    else
        log "INFO" "ArcGIS DataStore tarball already present: $DATA_STORE_TARBALL_PATH"
    fi

    # Unpack setup if not already done
    run_unpack_tar "$DATA_STORE_TARBALL_PATH" "$SETUP_PATH" "$RUN_AS_USER"
    # Check prerequisites
    check_datastore_prerequisites
    create_datastore_directories

    

    log "INFO" "Installing ArcGIS DataStore..."

    # Prepare installation command
    local install_cmd="${SETUP_PATH}/ArcGISDataStore_Linux/Setup -m silent -d '${DATA_STORE_INSTALL_PATH}' -l yes -f Complete"
    
    log "INFO" "Running installation command: ${install_cmd}"

    # Run installation as arcgis user
    if ! su - "$RUN_AS_USER" -c "$install_cmd"; then
        log "ERROR" "ArcGIS DataStore installation failed"
        exit 1
    fi

    # Verify installation
    local start_script="${DATA_STORE_INSTALL_PATH}/startdatastore.sh"
    if [[ ! -f "$start_script" ]]; then
        log "ERROR" "Installation verification failed - startdatastore.sh not found: ${start_script}"
        exit 1
    fi

    log "INFO" "ArcGIS DataStore installation completed successfully"

    # Post-installation configuration
    log "INFO" "=== POST-INSTALLATION CONFIGURATION ==="
    configure_datastore_hostidentifiers
    configure_datastore_service
    start_datastore
    
    validate_datastore_installation

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

function create_datastore_directories() {
    log "INFO" "Creating ArcGIS DataStore directories..."
    local DATASTORE_BACKUP_DIR="${DATASTORE_DATA_DIR}/usr/arcgisbackup"
    local directories=(
        "$DATASTORE_DATA_DIR"
        "$DATASTORE_BACKUP_DIR"
        "$DATA_STORE_INSTALL_PATH"
        "${DATASTORE_BACKUP_DIR}/relational"
        "${DATASTORE_BACKUP_DIR}/tilecache"
        "${DATASTORE_BACKUP_DIR}/object"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            chown -R "${RUN_AS_USER}:${RUN_AS_USER}" "$dir"
            chmod 700 "$dir"
            log "INFO" "Created directory: $dir"
        fi
    done

    # Create subdirectories with proper permissions
    IFS='/' read -ra SUBDIR_PARTS <<< "arcgis/datastore"
    current_path="/opt"
    for part in "${SUBDIR_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="$current_path/$part"
            chmod 700 "$current_path"
            chown "$RUN_AS_USER:$RUN_AS_GROUP" "$current_path"
        fi
    done
}

function validate_datastore_installation() {
    log "INFO" "Validating ArcGIS DataStore installation..."

    local validation_errors=0

    # Check installation directory
    if [[ ! -d "${DATA_STORE_INSTALL_PATH}" ]]; then
        log "ERROR" "Installation directory not found: ${DATA_STORE_INSTALL_PATH}"
        ((validation_errors++))
    else
        log "INFO" "✓ Installation directory exists"
    fi

    # Check start/stop scripts
    local start_script="${DATA_STORE_INSTALL_PATH}/startdatastore.sh"
    local stop_script="${DATA_STORE_INSTALL_PATH}/stopdatastore.sh"
    
    if [[ ! -f "$start_script" ]]; then
        log "ERROR" "Start script not found: ${start_script}"
        ((validation_errors++))
    else
        log "INFO" "✓ Start script exists"
    fi

    if [[ ! -f "$stop_script" ]]; then
        log "ERROR" "Stop script not found: ${stop_script}"
        ((validation_errors++))
    else
        log "INFO" "✓ Stop script exists"
    fi

    # Check data directories
    local directories=(
        "$DATASTORE_DATA_DIR"
        "${DATASTORE_DATA_DIR}/usr/arcgisbackup"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log "ERROR" "Required directory not found: $dir"
            ((validation_errors++))
        else
            log "INFO" "✓ Directory exists: $dir"
        fi
    done


    # Check if DataStore processes are running
    if pgrep -f "java.*datastore" > /dev/null; then
        log "INFO" "✓ ArcGIS DataStore processes are running"
    else
        log "WARNING" "ArcGIS DataStore processes not detected (this may be normal if DataStore was just installed)"
    fi

    # Check auto service configuration
    if systemctl is-enabled arcgisdatastore > /dev/null 2>&1; then
        log "INFO" "✓ ArcGIS DataStore service is enabled for autostart"
    else
        log "WARNING" "ArcGIS DataStore service is not enabled for autostart"
    fi

    if [[ $validation_errors -gt 0 ]]; then
        log "ERROR" "Installation validation failed with ${validation_errors} error(s)"
        return 1
    else
        log "INFO" "✓ Installation validation passed"
    fi

    log "INFO" "=== INSTALLATION SUMMARY ==="
    log "INFO" "ArcGIS DataStore ${ARCGIS_VERSION} installation completed successfully"
    log "INFO" "Installation Directory: ${DATA_STORE_INSTALL_PATH}"
    log "INFO" "Data Directory: ${DATASTORE_DATA_DIR}"
    log "INFO" "Backup Directory: ${DATASTORE_DATA_DIR}/usr/arcgisbackup"
    log "INFO" "User: ${RUN_AS_USER}"
    log "INFO" "Start Command: ${DATASTORE_DATA_DIR}/startdatastore.sh"
    log "INFO" "Stop Command: ${DATASTORE_DATA_DIR}/stopdatastore.sh"
    log "INFO" "Host Identifier: ${DATASTORE_PREFERRED_IDENTIFIER}"
    log "INFO" "Service Management: systemctl {start|stop|status} arcgisdatastore"
    log "INFO" "DataStore installation script completed successfully"
    log "INFO" ""
    log "INFO" "Next Steps:"
    log "INFO" "1. Configure DataStore with ArcGIS Server using configuredatastore tool"
    log "INFO" "2. Register DataStore types (relational, object, tilecache) as needed"
    log "INFO" "3. Configure backups if required"
    log "INFO" "4. Monitor DataStore logs: ${DATA_STORE_INSTALL_PATH}/usr/logs/"

}

function configure_datastore_service() {

    log "INFO" "Configuring ArcGIS DataStore service for autostart..."

    local service_script="${DATA_STORE_INSTALL_PATH}/framework/etc/scripts/arcgisdatastore"
    local systemd_service="/etc/systemd/system/arcgisdatastore.service"

    # Check if service script exists
    if [[ ! -f "$service_script" ]]; then
        log "WARNING" "Service script not found: ${service_script}"
        return 1
    fi

    # Create systemd service file
    cat > "$systemd_service" << EOF
[Unit]
Description=ArcGIS DataStore
After=network.target

[Service]
Type=forking
User=${RUN_AS_USER}
Group=${RUN_AS_GROUP}
ExecStart=${DATA_STORE_INSTALL_PATH}/startdatastore.sh
ExecStop=${DATA_STORE_INSTALL_PATH}/stopdatastore.sh
TimeoutStartSec=600
TimeoutStopSec=60

[Install]
WantedBy=multi-user.target
EOF

    # Enable service
    systemctl daemon-reload
    systemctl enable arcgisdatastore
    log "INFO" "Configured arcgisdatastore service for autostart"

}

function start_datastore() {
    log "INFO" "Starting ArcGIS DataStore..."
    
    if systemctl --version >/dev/null 2>&1 && [[ -f /etc/systemd/system/arcgisdatastore.service ]]; then
        systemctl start arcgisdatastore.service
        #systemctl status arcgisdatastore.service --no-pager
    elif [[ -f /etc/init.d/arcgisdatastore ]]; then
        service arcgisdatastore start
    else
        local start_script="${DATA_STORE_INSTALL_PATH}/startdatastore.sh"
    
        if [[ ! -f "$start_script" ]]; then
            log "ERROR" "Start script not found: ${start_script}"
            exit 1
        fi

        # Start DataStore as arcgis user
        if su - "$RUN_AS_USER" -c "$start_script"; then
            log "INFO" "ArcGIS DataStore started successfully"
            
            # Wait for DataStore to be fully ready
            sleep 60
            
            # Verify DataStore is running
            if pgrep -f "java.*datastore" > /dev/null; then
                log "INFO" "ArcGIS DataStore processes are running"
            else
                log "WARNING" "ArcGIS DataStore processes not detected"
            fi
        else
            log "ERROR" "Failed to start ArcGIS DataStore"
            exit 1
        fi
    fi
    log "SUCCESS" "ArcGIS DataStore service started"
    
}

function configure_datastore_hostidentifiers() {
    log "INFO" "Configuring host identifiers..."

    local hostidentifier_properties="${DATA_STORE_INSTALL_PATH}/framework/etc/hostidentifier.properties"
    
    if [[ -f "$hostidentifier_properties" ]]; then
        # Backup original file
        cp "$hostidentifier_properties" "${hostidentifier_properties}.backup"
        
        # Configure preferred identifier
        case "$DATASTORE_PREFERRED_IDENTIFIER" in
            "hostname")
                local identifier=$(hostname -f)
                ;;
            "ip")
                local identifier=$(hostname -i | awk '{print $1}')
                ;;
            *)
                local identifier=$(hostname -f)
                log "WARNING" "Unknown preferred identifier: $DATASTORE_PREFERRED_IDENTIFIER, using hostname"
                ;;
        esac
        
        # Update hostidentifier.properties
        cat > "$hostidentifier_properties" << EOF
# ArcGIS DataStore Host Identifier Configuration
# Generated by installation script
preferredidentifier=${DATASTORE_PREFERRED_IDENTIFIER}
hostidentifier=${identifier}
EOF

        chown "${RUN_AS_USER}:${RUN_AS_GROUP}" "$hostidentifier_properties"
        log "INFO" "Configured host identifier: ${identifier} (${DATASTORE_PREFERRED_IDENTIFIER})"
    else
        log "ERROR" "hostidentifier.properties file not found: ${hostidentifier_properties}"
    fi
}

function check_datastore_prerequisites() {
    log "INFO" "Checking installation prerequisites..."

    # Check if setup archive exists
    if [[ ! -f "$DATA_STORE_TARBALL_PATH" ]]; then
        log "ERROR" "ArcGIS DataStore setup archive not found: ${DATA_STORE_TARBALL_PATH}"
        exit 1
    fi
    log "INFO" "Found setup archive: ${DATA_STORE_TARBALL_PATH}"

    # Create required directories
    if [ -d "${SETUP_PATH}/ArcGISDataStore_Linux" ]; then
        log "INFO" "Setups directory already exists: $SETUP_PATH/ArcGISDataStore_Linux"
    else
        mkdir -p "$SETUP_PATH/ArcGISDataStore_Linux" || die "Failed to create setups directory: $SETUP_PATH/ArcGISDataStore_Linux"
        log "SUCCESS" "Created setups directory: $SETUP_PATH/ArcGISDataStore_Linux"
        chown -R "${RUN_AS_USER}:${RUN_AS_USER}" "$SETUP_PATH/ArcGISDataStore_Linux"
        log "INFO" "Created required directories"
    fi
    
}

function optimize_system_for_datastore() {
    log "INFO" "Optimizing system settings for DataStore..."

    # Configure vm.max_map_count for Elasticsearch (used by DataStore)
    local sysctl_conf="/etc/sysctl.conf"
    local VM_MAX_MAP_COUNT="262144"
    local VM_SWAPPINESS="1"

    # Backup original sysctl.conf
    if [[ ! -f "${sysctl_conf}.backup" ]]; then
        cp "$sysctl_conf" "${sysctl_conf}.backup"
        log "INFO" "Backed up original sysctl.conf"
    fi

    # Remove existing DataStore entries
    sed -i "/# ArcGIS DataStore system optimization/,/^$/d" "$sysctl_conf"

    # Add DataStore optimizations
    cat >> "$sysctl_conf" << EOF

# ArcGIS DataStore system optimization
vm.max_map_count = ${VM_MAX_MAP_COUNT}
vm.swappiness = ${VM_SWAPPINESS}
EOF

    # Apply sysctl settings
    sysctl -p
    log "INFO" "Applied system optimizations for DataStore"
}

function configure_datastore_system_limits() {
    log "INFO" "Configuring system limits for user: ${RUN_AS_USER}"

    local limits_file="/etc/security/limits.conf"
    local limits_config="
# ArcGIS DataStore limits
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
    sed -i "/# ArcGIS DataStore limits/,/^$/d" "$limits_file"

    # Add new limits
    echo "$limits_config" >> "$limits_file"
    log "INFO" "Updated system limits for ${RUN_AS_USER}"
}

function configure_datastore_rhel_firewall() {
    log "INFO" "Configuring RHEL firewall for DataStore..."
    # DataStore ports (for firewall configuration)
    local DATASTORE_PORTS="2443,4369,9220,9320,9820,9828,9829,9830,9831,9840,9850,9876,9900,25672,44369,45671,45672,29079-29090"


    # Check if firewalld is active
    if systemctl is-active firewalld > /dev/null 2>&1; then
        log "INFO" "Configuring firewalld rules..."
        
        # Parse and add DataStore ports
        IFS=',' read -ra PORTS <<< "$DATASTORE_PORTS"
        for port_range in "${PORTS[@]}"; do
            if [[ "$port_range" == *"-"* ]]; then
                # Port range
                firewall-cmd --permanent --add-port="$port_range/tcp" || log "WARNING" "Failed to add port range $port_range"
            else
                # Single port
                firewall-cmd --permanent --add-port="$port_range/tcp" || log "WARNING" "Failed to add port $port_range"
            fi
        done
        
        # Reload firewall
        firewall-cmd --reload
        log "INFO" "Firewall configuration completed"
    else
        log "WARNING" "firewalld is not active, skipping firewall configuration"
    fi
}

function user_exists() {
    local username="$1"
    getent passwd "$username" > /dev/null 2>&1
}

function install_components() {
    log "INFO" "Installing software components..."

    case "$1" in
      "portal")
        log "INFO" "Starting Portal for ArcGIS installation"
		install_portal
        ;;
      "server")
        log "INFO" "Starting ArcGIS Server installation"
        install_server 
        ;;
      "datastore")
        log "INFO" "Starting ArcGIS Data Store installation"
        install_datastore
        ;;
      "webadaptor")
        log "INFO" "Starting ArcGIS Web Adaptor for portal installation"
        install_webadaptor
        ;;
      "enterprise")
        log "INFO" "Starting ArcGIS Enterprise installation"
        install_portal
        install_server
        install_datastore
        install_webadaptor
        ;;
      *)
        log "Unknown component: $1"
        exit 1
        ;;
    esac
}

function run_download_s3() {
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

    # Data store
    DATA_STORE_INSTALL_PATH=$(echo "$config_json" | jq -r '.arcgis.data_store.install_path // empty')
    DATA_STORE_S3_URI=$(echo "$config_json" | jq -r '.arcgis.data_store.s3_uri // empty')
    DATA_STORE_TARBALL_PATH=$(echo "$config_json" | jq -r '.arcgis.data_store.tarball_path // empty')
    DATASTORE_DATA_DIR=$(echo "$config_json" | jq -r '.arcgis.data_store.data_dir // empty')
    DATASTORE_PREFERRED_IDENTIFIER=$(echo "$config_json" | jq -r '.arcgis.data_store.preferred_identifier // "hostname"')
    
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
    install_datastore
    log "RHEL AMI setup completed successfully"
    #cleanup_installer_files
    exit 0
}

# Testability guard: only invoke main when script is executed directly, not when sourced.
# Main execution
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi