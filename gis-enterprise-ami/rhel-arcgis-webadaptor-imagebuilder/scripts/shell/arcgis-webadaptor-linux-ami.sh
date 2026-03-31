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

function run_unpack_tar(){
    # Generic unpack tar helper (file)
    # Params / env vars:
    #   $1 / tarball_path : tar file path
    #   $2 / dest_path    : Destination file or directory path
    #   $3 / run_as_user  : run as user (optional)
    #   $4 / label        : Human friendly label (optional)

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

function cleanup_installer_files() {
    log "INFO" "Cleaning up installer files..."

    # Clean up setup files if requested
    if [[ -d "$SETUP_PATH" ]]; then
        rm -rf "$SETUP_PATH"
        log "INFO" "Removed setup directory: ${SETUP_PATH}"
    fi

    log "INFO" "Cleanup completed"
}

function install_rhel_packages_web_adaptor() {
    log "INFO" "Installing RHEL system packages..."
    # Install EPEL repository for additional packages
    install_epel_release

    # Required packages for ArcGIS Web Adaptor
    local packages=(
        "httpd"
        "mod_ssl"
        "java-1.8.0-openjdk"
        "which"
        "unzip"
        "wget"
    )

    for package in "${packages[@]}"; do
        log "INFO" "Installing package: $package"
        yum install -y "$package" || log "WARNING" "Failed to install $package"
    done

    log "INFO" "RHEL system packages installation completed"
}

function configure_rhel_firewall_web_adaptor() {

    log "INFO" "Configuring RHEL firewall for Web Adaptor..."

    # Check if firewalld is active
    if systemctl is-active firewalld > /dev/null 2>&1; then
        log "INFO" "Configuring firewalld rules..."

        # Add web service ports
        firewall-cmd --permanent --add-port="${HTTP_PORT}/tcp" || log "WARNING" "Failed to add HTTP port ${HTTP_PORT}"
        firewall-cmd --permanent --add-port="${HTTPS_PORT}/tcp" || log "WARNING" "Failed to add HTTPS port ${HTTPS_PORT}"

        # Reload firewall
        firewall-cmd --reload
        log "INFO" "Firewall configuration completed"
    else
        log "WARNING" "firewalld is not active, skipping firewall configuration"
    fi

}

function configure_system_limits_web_adaptor() {
    log "INFO" "Configuring system limits for users: ${RUN_AS_USER}, ${TOMCAT_USER}"

    local limits_file="/etc/security/limits.conf"
    local limits_config="
# ArcGIS Web Adaptor and Tomcat limits
${RUN_AS_USER}    hard    nofile     65536
${RUN_AS_USER}    soft    nofile     65536
${RUN_AS_USER}    hard    nproc      25059
${RUN_AS_USER}    soft    nproc      25059
${TOMCAT_USER}    hard    nofile     65536
${TOMCAT_USER}    soft    nofile     65536
${TOMCAT_USER}    hard    nproc      25059
${TOMCAT_USER}    soft    nproc      25059"

    # Backup original limits file
    if [[ ! -f "${limits_file}.backup" ]]; then
        cp "$limits_file" "${limits_file}.backup"
        log "INFO" "Backed up original limits.conf"
    fi

    # Remove existing ArcGIS entries
    sed -i "/# ArcGIS Web Adaptor and Tomcat limits/,/^$/d" "$limits_file"

    # Add new limits
    echo "$limits_config" >> "$limits_file"
    log "INFO" "Updated system limits for ${RUN_AS_USER} and ${TOMCAT_USER}"
}


function create_users_and_groups_web_adaptor() {
    log "INFO" "Creating ArcGIS and Tomcat users and groups..."

    # Create ArcGIS group if it doesn't exist
    if ! getent group "$RUN_AS_GROUP" > /dev/null 2>&1; then
        groupadd -g "$ARCGIS_GID" "$RUN_AS_GROUP"
        log "INFO" "Created group: ${RUN_AS_GROUP} (GID: ${ARCGIS_GID})"
    else
        log "INFO" "Group already exists: ${RUN_AS_GROUP}"
    fi

    # Create ArcGIS user if it doesn't exist
    if ! getent passwd "$RUN_AS_USER" > /dev/null 2>&1; then
        useradd -m -u "$ARCGIS_UID" -g "$ARCGIS_GID" \
                -d "/home/${RUN_AS_USER}" \
                -s "/bin/bash" \
                -c "ArcGIS user account" \
                "$RUN_AS_USER"
        log "INFO" "Created user: ${RUN_AS_USER} (UID: ${ARCGIS_UID})"
    else
        log "INFO" "User already exists: ${RUN_AS_USER}"
    fi

    # Create Tomcat group if it doesn't exist
    if ! getent group "$TOMCAT_GROUP" > /dev/null 2>&1; then
        groupadd "$TOMCAT_GROUP"
        log "INFO" "Created group: ${TOMCAT_GROUP}"
    else
        log "INFO" "Group already exists: ${TOMCAT_GROUP}"
    fi

    # Create Tomcat user if it doesn't exist
    if ! getent passwd "$TOMCAT_USER" > /dev/null 2>&1; then
        useradd -m -g "$TOMCAT_GROUP" \
                -d "/home/${TOMCAT_USER}" \
                -s "/bin/false" \
                -c "Tomcat user account" \
                "$TOMCAT_USER"
        log "INFO" "Created user: ${TOMCAT_USER}"
    else
        log "INFO" "User already exists: ${TOMCAT_USER}"
    fi

    # Ensure home directories have correct permissions
    for user in "$ARCGIS_USER" "$TOMCAT_USER"; do
        local home_dir="/home/${user}"
        if [[ -d "$home_dir" ]]; then
            chown -R "${user}:${user}" "$home_dir"
            chmod 755 "$home_dir"
            log "INFO" "Updated permissions for home directory: ${home_dir}"
        fi
    done
}

function configure_java_alternatives() {
    local java_dir="$1"

    log "INFO" "Configuring Java alternatives..."

    # Remove existing java alternatives if any
    update-alternatives --remove-all java 2>/dev/null || true
    update-alternatives --remove-all javac 2>/dev/null || true

    # Install new alternatives
    update-alternatives --install /usr/bin/java java "${java_dir}/bin/java" 10
    update-alternatives --install /usr/bin/javac javac "${java_dir}/bin/javac" 10

    # Set JAVA_HOME environment variable
    echo "export JAVA_HOME=${java_dir}" > /etc/profile.d/java.sh
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh
    chmod +x /etc/profile.d/java.sh

    # Verify Java installation
    local java_version
    java_version=$("${java_dir}/bin/java" -version 2>&1 | head -1)
    log "INFO" "Java version installed: ${java_version}"

    log "INFO" "Java alternatives configuration completed"
}

function install_openjdk() {
    log "INFO" "Installing OpenJDK ${JAVA_VERSION}..."

    local java_dir="${JAVA_INSTALL_PATH}/jdk-${JAVA_VERSION}"
    
    # Check if Java is already installed
    if [[ -d "$java_dir" ]] && [[ -f "${java_dir}/bin/java" ]]; then
        log "INFO" "OpenJDK ${JAVA_VERSION} already installed in: ${java_dir}"
        configure_java_alternatives "$java_dir"
        return 0
    fi

    # Download Java tarball if not exists
    run_download_s3 "$JAVA_S3_URI" "$JAVA_TARBALL_PATH" "OpenJDK ${JAVA_VERSION} tarball"

    # Create Java installation directory
    mkdir -p "$JAVA_INSTALL_PATH"

    # Extract Java tarball
    log "INFO" "Extracting OpenJDK tarball..."
    run_unpack_tar "$JAVA_TARBALL_PATH" "$JAVA_INSTALL_PATH" 

    # Verify installation
    if [[ ! -f "${java_dir}/bin/java" ]]; then
        log "ERROR" "OpenJDK installation verification failed"
        exit 1
    fi

    # Set ownership
    chown -R root:root "$java_dir"

    # Configure alternatives
    configure_java_alternatives "$java_dir"

    log "INFO" "OpenJDK ${JAVA_VERSION} installation completed"
}

function install_webadaptor(){

    log "INFO" "Starting ArcGIS Web Adaptor installation script"
    log "INFO" "ArcGIS Version: ${ARCGIS_VERSION}"
    log "INFO" "Java Version: ${JAVA_VERSION}"
    log "INFO" "Tomcat Version: ${TOMCAT_VERSION}"
    log "INFO" "Install Directory: ${WEB_ADAPTOR_INSTALL_PATH}"
    log "INFO" "Web App Directory: ${WEBAPP_DIR}"

    log "INFO" "=== SYSTEM REQUIREMENTS INSTALLATION ==="
    install_rhel_packages_web_adaptor
    configure_rhel_firewall_web_adaptor
    configure_system_limits_web_adaptor
    create_users_and_groups_web_adaptor

    # Java installation (equivalent to esri-tomcat::openjdk recipe)
    log "INFO" "=== OPENJDK INSTALLATION ==="
    install_openjdk

    log "INFO" "=== TOMCAT INSTALLATION ==="
    install_tomcat
    configure_tomcat
    create_tomcat_service

    log "INFO" "=== WEB ADAPTOR INSTALLATION ==="
    # Download Web Adaptor setup if not present or size is zero
    run_download_s3 "$WEB_ADAPTOR_S3_URI" "$WEB_ADAPTOR_TARBALL_PATH" "ArcGIS Web Adaptor tarball"

    # Create required directories
    mkdir -p "$SETUP_PATH" "$WEBAPP_DIR"
    log "INFO" "Created required directories"


    # Unpack setup if not already done
    log "INFO" "Extracting ${WEB_ADAPTOR_TARBALL_PATH} to ${SETUP_PATH}..."

    run_unpack_tar "$WEB_ADAPTOR_TARBALL_PATH" "$SETUP_PATH" "$RUN_AS_USER"


    # Verify extraction
    if [[ ! -f "${SETUP_PATH}/WebAdaptor/Setup" ]]; then
        log "ERROR" "Setup executable not found after extraction: ${SETUP_PATH}/WebAdaptor/Setup"
        exit 1
    fi
    
    # Make setup executable
    chmod +x "${SETUP_PATH}/WebAdaptor/Setup"
    log "INFO" "Successfully unpacked setup archive"

    # Create subdirectories with proper permissions

    mkdir -p "/opt/arcgis"
    chmod 700 "/opt/arcgis"
    chown "$RUN_AS_USER:$RUN_AS_GROUP" "/opt/arcgis"


    # Prepare installation command
    local install_cmd="${SETUP_PATH}/WebAdaptor/Setup -m silent -l yes -d '${WEB_ADAPTOR_INSTALL_PATH}'"
    log "INFO" "Running installation command: ${install_cmd}"

    # Running as non-root user
    if ! eval "$install_cmd"; then
        log "ERROR" "ArcGIS Web Adaptor installation failed"
        exit 1
    fi

    # Verify installation
    local wa_war_file="${WEB_ADAPTOR_INSTALL_PATH}/${WEBADAPTOR_INSTALL_SUBDIR}/java/arcgis.war"
    if [[ ! -f "$wa_war_file" ]]; then
        log "ERROR" "Installation verification failed - arcgis.war not found: ${wa_war_file}"
        exit 1
    fi

    log "INFO" "ArcGIS Web Adaptor installation completed successfully"
    deploy_webadaptor_to_tomcat "portal" # Deploy to ArcGIS Portal
    deploy_webadaptor_to_tomcat "server" # Deploy to ArcGIS Server

    # Validation and cleanup
    log "INFO" "=== VALIDATION AND CLEANUP ==="
    validate_webadaptor_installation

    log "INFO" "=== INSTALLATION SUMMARY ==="
    log "INFO" "ArcGIS Portal Web Adaptor ${ARCGIS_VERSION} installation completed successfully"
    log "INFO" "Java Installation: ${JAVA_INSTALL_PATH}/jdk-${JAVA_VERSION}"
    log "INFO" "Tomcat Installation: ${TOMCAT_INSTALL_PATH}"
    log "INFO" "Web Adaptor Installation: ${WEB_ADAPTOR_INSTALL_PATH}/${WEBADAPTOR_INSTALL_SUBDIR}"
    log "INFO" "Web Adaptor URL: http://$(hostname):${HTTP_PORT}/${PORTAL_WA_NAME}"
    log "INFO" "Tomcat Users: ${TOMCAT_USER}"
    log "INFO" "ArcGIS User: ${RUN_AS_USER}"
    log "INFO" "Service Management: systemctl {start|stop|status} tomcat-${TOMCAT_INSTANCE_NAME}"
    log "INFO" "Configuration Tool: ${WEB_ADAPTOR_INSTALL_PATH}/${WEBADAPTOR_INSTALL_SUBDIR}/java/tools/configurewebadaptor.sh"

    log "INFO" ""
    log "INFO" "Next Steps:"
    log "INFO" "1. Configure the Web Adaptor to connect to your Portal for ArcGIS"
    log "INFO" "2. Use the configuration tool or web interface to register the Web Adaptor"
    log "INFO" "3. Configure SSL/HTTPS if required for production use"
    log "INFO" "4. Monitor Tomcat logs: ${TOMCAT_INSTALL_PATH}/logs/"
    log "INFO" ""
    log "INFO" "Web Adaptor installation script completed successfully"

}

function validate_webadaptor_installation() {
    log "INFO" "Validating Web Adaptor installation..."

    local validation_errors=0

    # Check Java installation
    local java_dir="${JAVA_INSTALL_PATH}/jdk-${JAVA_VERSION}"
    if [[ ! -f "${java_dir}/bin/java" ]]; then
        log "ERROR" "Java installation not found: ${java_dir}"
        ((validation_errors++))
    else
        log "INFO" "✓ Java installation exists"
    fi

    # Check Tomcat installation
    if [[ ! -f "${TOMCAT_INSTALL_PATH}/bin/catalina.sh" ]]; then
        log "ERROR" "Tomcat installation not found: ${TOMCAT_INSTALL_PATH}"
        ((validation_errors++))
    else
        log "INFO" "✓ Tomcat installation exists"
    fi

    # Check Web Adaptor installation
    local wa_war_file="${WEB_ADAPTOR_INSTALL_PATH}/${WEBADAPTOR_INSTALL_SUBDIR}/java/arcgis.war"
    if [[ ! -f "$wa_war_file" ]]; then
        log "ERROR" "Web Adaptor WAR file not found: ${wa_war_file}"
        ((validation_errors++))
    else
        log "INFO" "✓ Web Adaptor WAR file exists"
    fi

    # Check users
    for user in "$RUN_AS_USER" "$TOMCAT_USER"; do
        if ! user_exists "$user"; then
            log "ERROR" "User not found: ${user}"
            ((validation_errors++))
        else
            log "INFO" "✓ User exists: ${user}"
        fi
    done
    
    if systemctl is-enabled "tomcat-${TOMCAT_INSTANCE_NAME}" > /dev/null 2>&1; then
        log "INFO" "✓ Tomcat service is enabled for autostart"
    else
        log "WARNING" "Tomcat service is not enabled for autostart"
    fi

    if systemctl is-active "tomcat-${TOMCAT_INSTANCE_NAME}" > /dev/null 2>&1; then
        log "INFO" "✓ Tomcat service is running"
    else
        log "WARNING" "Tomcat service is not running"
    fi
    

    # Test web service availability
    sleep 10  # Give Tomcat time to fully start
    local web_url="http://localhost:${HTTP_PORT}/portal"
    if curl -s --connect-timeout 10 "$web_url" > /dev/null; then
        log "INFO" "✓ Web Adaptor is accessible at: ${web_url}"
    else
        log "WARNING" "Web Adaptor may not be fully deployed yet at: ${web_url}"
    fi

    if [[ $validation_errors -gt 0 ]]; then
        log "ERROR" "Installation validation failed with ${validation_errors} error(s)"
        return 1
    else
        log "INFO" "✓ Installation validation passed"
        return 0
    fi
}

function user_exists() {
    local username="$1"
    getent passwd "$username" > /dev/null 2>&1
}

function deploy_webadaptor_to_tomcat() {
    log "INFO" "Deploying Web Adaptor to Tomcat..."

    local wa_name="$1"
    local wa_war_file="${WEB_ADAPTOR_INSTALL_PATH}/${WEBADAPTOR_INSTALL_SUBDIR}/java/arcgis.war"
    local deployed_war="${WEBAPP_DIR}/${wa_name}.war"
    local deployed_dir="${WEBAPP_DIR}/${wa_name}"

    # Check if WAR file exists
    if [[ ! -f "$wa_war_file" ]]; then
        log "ERROR" "Web Adaptor WAR file not found: ${wa_war_file}"
        exit 1
    fi

    # Remove existing deployment if it exists
    if [[ -f "$deployed_war" ]]; then
        rm -f "$deployed_war"
        log "INFO" "Removed existing WAR file: ${deployed_war}"
    fi

    if [[ -d "$deployed_dir" ]]; then
        rm -rf "$deployed_dir"
        log "INFO" "Removed existing deployment directory: ${deployed_dir}"
    fi

    # Copy WAR file to Tomcat webapps directory
    cp "$wa_war_file" "$deployed_war"
    chown "${TOMCAT_USER}:${TOMCAT_GROUP}" "$deployed_war"

    log "INFO" "Deployed Web Adaptor WAR file: ${deployed_war}"

    # Restart Tomcat to deploy the application
    if systemctl is-active "tomcat-${TOMCAT_INSTANCE_NAME}" > /dev/null; then
        log "INFO" "Restarting Tomcat to deploy Web Adaptor..."
        systemctl restart "tomcat-${TOMCAT_INSTANCE_NAME}"
        
        # Wait for deployment
        sleep 60
        
        # Check if deployment was successful
        if [[ -d "$deployed_dir" ]]; then
            log "INFO" "Web Adaptor deployed successfully to: ${deployed_dir}"
        else
            log "WARNING" "Web Adaptor deployment directory not found, may still be deploying"
        fi
    else
        log "INFO" "Tomcat is not running, Web Adaptor will deploy when Tomcat starts"
    fi

    log "INFO" "Web Adaptor deployment completed"
}


function create_tomcat_service() {
    log "INFO" "Creating Tomcat systemd service..."

    local service_file="/etc/systemd/system/tomcat-${TOMCAT_INSTANCE_NAME}.service"

    cat > "$service_file" << EOF
[Unit]
Description=Apache Tomcat ${TOMCAT_VERSION} (${TOMCAT_INSTANCE_NAME})
After=network.target

[Service]
Type=forking
User=${TOMCAT_USER}
Group=${TOMCAT_GROUP}

Environment=JAVA_HOME=${JAVA_INSTALL_PATH}/jdk-${JAVA_VERSION}
Environment=CATALINA_PID=${TOMCAT_INSTALL_PATH}/temp/tomcat.pid
Environment=CATALINA_HOME=${TOMCAT_INSTALL_PATH}
Environment=CATALINA_BASE=${TOMCAT_INSTALL_PATH}

ExecStart=${TOMCAT_INSTALL_PATH}/bin/startup.sh
ExecStop=${TOMCAT_INSTALL_PATH}/bin/shutdown.sh

TimeoutStartSec=300
TimeoutStopSec=60
RestartSec=10
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start Tomcat service if configured
    systemctl daemon-reload
    
    if [[ "${CONFIGURE_AUTOSTART}" == "true" ]]; then
        systemctl enable "tomcat-${TOMCAT_INSTANCE_NAME}"
        systemctl start "tomcat-${TOMCAT_INSTANCE_NAME}"
        
        # Wait for Tomcat to start
        sleep 30
        
        if systemctl is-active "tomcat-${TOMCAT_INSTANCE_NAME}" > /dev/null; then
            log "INFO" "Tomcat service started successfully"
        else
            log "WARNING" "Tomcat service may not have started properly"
        fi
    fi

    log "INFO" "Tomcat service configuration completed"
}

function configure_tomcat() {
    log "INFO" "Configuring Tomcat..."

    local server_xml="${TOMCAT_INSTALL_PATH}/conf/server.xml"
    local tomcat_users_xml="${TOMCAT_INSTALL_PATH}/conf/tomcat-users.xml"

    # Backup original configuration files
    cp "$server_xml" "${server_xml}.backup"
    cp "$tomcat_users_xml" "${tomcat_users_xml}.backup"

    # Update server.xml with custom ports and settings
    sed -i "s|port=\"8080\"|port=\"${HTTP_PORT}\"|g" "$server_xml"
    sed -i "s|port=\"8443\"|port=\"${HTTPS_PORT}\"|g" "$server_xml"
    sed -i "s|port=\"8009\"|port=\"${AJP_PORT}\"|g" "$server_xml"
    sed -i "s|port=\"8005\"|port=\"${SHUTDOWN_PORT}\"|g" "$server_xml"

    # Configure memory settings
    local setenv_sh="${TOMCAT_INSTALL_PATH}/bin/setenv.sh"
    cat > "$setenv_sh" << EOF
#!/bin/bash
# Tomcat memory and JVM settings
export CATALINA_OPTS="\$CATALINA_OPTS -Xms512m -Xmx2048m"
export CATALINA_OPTS="\$CATALINA_OPTS -XX:+UseG1GC"
export CATALINA_OPTS="\$CATALINA_OPTS -Djava.awt.headless=true"
export CATALINA_OPTS="\$CATALINA_OPTS -Djava.security.egd=file:/dev/./urandom"

# Set JAVA_HOME
export JAVA_HOME=${JAVA_INSTALL_PATH}/jdk-${JAVA_VERSION}
EOF

    chmod +x "$setenv_sh"
    chown "${TOMCAT_USER}:${TOMCAT_GROUP}" "$setenv_sh"

    # Set ownership of configuration files
    chown "${TOMCAT_USER}:${TOMCAT_GROUP}" "$server_xml" "$tomcat_users_xml"

    log "INFO" "Tomcat configuration completed"
}

function install_tomcat() {
    log "INFO" "Installing Apache Tomcat ${TOMCAT_VERSION}..."

    # Check if Tomcat is already installed
    if [[ -d "$TOMCAT_INSTALL_PATH" ]] && [[ -f "${TOMCAT_INSTALL_PATH}/bin/catalina.sh" ]]; then
        log "INFO" "Tomcat ${TOMCAT_VERSION} already installed in: ${TOMCAT_INSTALL_PATH}"
        return 0
    fi

    # Download Tomcat tarball if not exists
    run_download_s3 "$TOMCAT_S3_URI" "$TOMCAT_TARBALL_PATH" "Apache Tomcat ${TOMCAT_VERSION} tarball"

    # Create Tomcat installation directory
    mkdir -p "$(dirname "$TOMCAT_INSTALL_PATH")"

    # Extract Tomcat tarball
    log "INFO" "Extracting Tomcat tarball..."
    run_unpack_tar "$TOMCAT_TARBALL_PATH" "$(dirname "$TOMCAT_INSTALL_PATH")"

    # Rename extracted directory to final install path
    local extracted_dir="$(dirname "$TOMCAT_INSTALL_PATH")/apache-tomcat-${TOMCAT_VERSION}"
    if [[ "$extracted_dir" != "$TOMCAT_INSTALL_PATH" ]]; then
        mv "$extracted_dir" "$TOMCAT_INSTALL_PATH"
    fi

    # Verify installation
    if [[ ! -f "${TOMCAT_INSTALL_PATH}/bin/catalina.sh" ]]; then
        log "ERROR" "Tomcat installation verification failed"
        exit 1
    fi

    # Set ownership and permissions
    chown -R "${TOMCAT_USER}:${TOMCAT_GROUP}" "$TOMCAT_INSTALL_PATH"
    chmod +x "${TOMCAT_INSTALL_PATH}/bin/"*.sh

    # Create symlink if requested
    if [[ -n "$TOMCAT_SYMLINK_PATH" ]]; then
        rm -f "$TOMCAT_SYMLINK_PATH"
        ln -s "$TOMCAT_INSTALL_PATH" "$TOMCAT_SYMLINK_PATH"
        log "INFO" "Created symlink: ${TOMCAT_SYMLINK_PATH} -> ${TOMCAT_INSTALL_PATH}"
    fi

    # Remove default webapps (optional for security)
    for webapp in docs examples host-manager manager ROOT; do
        if [[ -d "${TOMCAT_INSTALL_PATH}/webapps/${webapp}" ]]; then
            rm -rf "${TOMCAT_INSTALL_PATH}/webapps/${webapp}"
            log "INFO" "Removed default webapp: ${webapp}"
        fi
    done

    log "INFO" "Tomcat ${TOMCAT_VERSION} installation completed"
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

    # Extract top-level Java configuration
    JAVA_VERSION=$(echo "$config_json" | jq -r '.java.version // empty')
    JAVA_S3_URI=$(echo "$config_json" | jq -r '.java.s3_uri // empty')
    JAVA_TARBALL_PATH=$(echo "$config_json" | jq -r '.java.tarball_path // empty')
    JAVA_DOWNLOAD_PATH=$(echo "$config_json" | jq -r '.java.download_path // empty')
    JAVA_INSTALL_PATH=$(echo "$config_json" | jq -r '.java.install_path // empty')

    # Tomcat configuration
    TOMCAT_VERSION=$(echo "$config_json" | jq -r '.tomcat.version // empty')
    TOMCAT_S3_URI=$(echo "$config_json" | jq -r '.tomcat.s3_uri // empty')
    TOMCAT_TARBALL_PATH=$(echo "$config_json" | jq -r '.tomcat.tarball_path // empty')
    TOMCAT_DOWNLOAD_PATH=$(echo "$config_json" | jq -r '.tomcat.download_path // empty')
    TOMCAT_INSTANCE_NAME=$(echo "$config_json" | jq -r '.tomcat.instance_name // "arcgis"')
    TOMCAT_USER=$(echo "$config_json" | jq -r '.tomcat.user // "tomcat_arcgis"')
    TOMCAT_GROUP=$(echo "$config_json" | jq -r '.tomcat.group // "tomcat_arcgis"')
    TOMCAT_INSTALL_PATH=$(echo "$config_json" | jq -r '.tomcat.install_path // empty')
    TOMCAT_SSL_ENABLED_PROTOCOLS=$(echo "$config_json" | jq -r '.tomcat.ssl_enabled_protocols // "TLSv1.2"')

    # ArcGIS common
    ARCGIS_VERSION=$(echo "$config_json" | jq -r '.arcgis.version // empty')
    RUN_AS_USER=$(echo "$config_json" | jq -r '.arcgis.run_as_user // "arcgis"')
    RUN_AS_GROUP=$(echo "$config_json" | jq -r '.arcgis.run_as_group // "arcgis"')
    DOWNLOAD_PATH=$(echo "$config_json" | jq -r '.arcgis.download_path // empty')
    SETUPS_PATH=$(echo "$config_json" | jq -r '.arcgis.setups_path // empty')

    # Web adaptor
    WEB_ADAPTOR_INSTALL_PATH=$(echo "$config_json" | jq -r '.arcgis.web_adaptor.install_path // empty')
    WEB_ADAPTOR_WEBAPP_DIR=$(echo "$config_json" | jq -r '.arcgis.web_adaptor.webapp_dir // empty')
    WEB_ADAPTOR_S3_URI=$(echo "$config_json" | jq -r '.arcgis.web_adaptor.s3_uri // empty')
    WEB_ADAPTOR_TARBALL_PATH=$(echo "$config_json" | jq -r '.arcgis.web_adaptor.tarball_path // empty')
    # Web Adaptor configuration
    WEBAPP_DIR="${TOMCAT_INSTALL_PATH}/webapps"
    WEBADAPTOR_INSTALL_SUBDIR="arcgis/webadaptor${ARCGIS_VERSION}"

    # Derived configuration
    SETUP_PATH="$SETUPS_PATH/$ARCGIS_VERSION"

    # Web service ports
    HTTP_PORT="8080"
    HTTPS_PORT="8443"
    AJP_PORT="8009"
    SHUTDOWN_PORT="8005"

    # Tomcat configuration
    TOMCAT_SYMLINK_PATH="/opt/tomcat_arcgis"

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
    parse_configuration "$2"
    install_webadaptor
    log "RHEL AMI setup completed successfully"
    #cleanup_installer_files
    exit 0
}

# Testability guard: only invoke main when script is executed directly, not when sourced.
# Main execution
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi