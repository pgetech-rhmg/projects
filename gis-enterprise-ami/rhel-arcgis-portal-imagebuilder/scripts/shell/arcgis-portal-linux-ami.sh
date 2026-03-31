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
# This function downloads the arcgis 
# cookbooks for Linux x86_64 architecture
############################################
function update_cookbook() {
    
    get_contents "https://arcgisstore.s3.amazonaws.com/1150/cookbooks/arcgis-5.2.0-cookbooks.tar.gz" > "/tmp/cookbook.tar.gz"
    exec_cmd "tar -xf /tmp/cookbook.tar.gz -C /opt/cinc"
    exec_cmd "rm /tmp/cookbook.tar.gz"
}

############################################
# This function downloads the latest Cinc client
# for Linux x86_64 architecture
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

function install_system_requirements() {
    log "INFO" "Installing system requirements"
    
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

        # Set system limits for the user (equivalent to limits cookbook)
        cat > "/etc/security/limits.d/$RUN_AS_USER.conf" << EOF
# ArcGIS Portal system limits
$RUN_AS_USER soft nofile 65536
$RUN_AS_USER hard nofile 65536
$RUN_AS_USER soft nproc 25059
$RUN_AS_USER hard nproc 25059
$RUN_AS_USER soft memlock unlimited
$RUN_AS_USER hard memlock unlimited
$RUN_AS_USER soft fsize unlimited
$RUN_AS_USER hard fsize unlimited
$RUN_AS_USER soft as unlimited
$RUN_AS_USER hard as unlimited
EOF
        chmod 0644 "/etc/security/limits.d/$RUN_AS_USER.conf"
        log "SUCCESS" "Configured system limits for $RUN_AS_USER"
    fi

    # Detect package manager and install required packages
    if command -v yum > /dev/null 2>&1; then
        # RHEL/CentOS - Install system requirements
        yum install -y dos2unix fontconfig freetype gettext
        
        # Configure firewall
        if systemctl is-active --quiet firewalld; then
            firewall-cmd --zone=public --permanent --add-port=5701/tcp
            firewall-cmd --zone=public --permanent --add-port=5702/tcp  
            firewall-cmd --zone=public --permanent --add-port=5703/tcp
            firewall-cmd --zone=public --permanent --add-port=7080/tcp
            firewall-cmd --zone=public --permanent --add-port=7443/tcp
            firewall-cmd --zone=public --permanent --add-port=7005/tcp
            firewall-cmd --zone=public --permanent --add-port=7099/tcp
            firewall-cmd --zone=public --permanent --add-port=7120/tcp
            firewall-cmd --zone=public --permanent --add-port=7220/tcp
            firewall-cmd --zone=public --permanent --add-port=7654/tcp
            firewall-cmd --zone=public --permanent --add-port=7820/tcp
            firewall-cmd --zone=public --permanent --add-port=7830/tcp
            firewall-cmd --zone=public --permanent --add-port=7840/tcp
            firewall-cmd --reload
            log "SUCCESS" "Configured firewall rules for Portal"
        fi
    elif command -v dnf > /dev/null 2>&1; then
        # Fedora/newer RHEL
        dnf install -y dos2unix fontconfig freetype gettext
    else
        log "WARNING" "Unknown package manager. Please install dos2unix, fontconfig, freetype, and gettext manually"
    fi
    
    # Create directories if they don't exist
    if [ -d "$DOWNLOAD_PATH" ]; then
        log "INFO" "Directory exists: $DOWNLOAD_PATH"
    else
        mkdir -p "$DOWNLOAD_PATH"
        log "SUCCESS" "Created directory: $DOWNLOAD_PATH"
    fi

    # Ensure download and setups parent directories exist (create only if missing)
    if [ -d "$SETUP_PATH" ]; then
        log "INFO" "Directory exists: $SETUP_PATH"
    else
        mkdir -p "$SETUP_PATH"
        log "SUCCESS" "Created directory: $SETUP_PATH"
    fi

    chown -R "$RUN_AS_USER:$RUN_AS_GROUP" "$DOWNLOAD_PATH" "$SETUP_PATH"
    
    log "SUCCESS" "System requirements install complete"
}

function configure_localhost_resolution() {
	# Goal: make first resolved address for 'localhost' be 127.0.0.1
	local hosts_file="/etc/hosts"
	local backup="/etc/hosts.bak.$(date +%s)"
	local ipv4_line="127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain4"
	# Do NOT include plain 'localhost' on IPv6 line (prevents ::1 from winning precedence in glibc)
	local ipv6_line="::1 localhost6 localhost6.localdomain6"

	# Fast path
	local first_ip
	first_ip="$(getent hosts localhost 2>/dev/null | awk 'NR==1{print $1}')"
	if [ "$first_ip" = "127.0.0.1" ]; then
		echo "localhost already resolves first to 127.0.0.1"
		return 0
	fi

	echo "Adjusting $hosts_file so localhost resolves first to 127.0.0.1 (was: ${first_ip:-UNRESOLVED})"
	cp "$hosts_file" "$backup" || die "Failed to backup $hosts_file"

	# Rebuild hosts file:
	#  - Keep all non-localhost lines unchanged
	#  - Remove any existing lines containing 'localhost'
	#  - Append desired IPv4 then IPv6 lines
	awk -v v4="$ipv4_line" -v v6="$ipv6_line" '
		/^[[:space:]]*#/ {print; next}
		/[[:space:]]localhost([[:space:]]|$)/ {next}
		{print}
		END {
			print v4
			print v6
		}
	' "$backup" > /tmp/hosts.$$ || die "Failed to construct new hosts file"

	mv /tmp/hosts.$$ "$hosts_file" || die "Failed to install new $hosts_file"
	chmod 0644 "$hosts_file" || true

	# Re-verify
	first_ip="$(getent hosts localhost 2>/dev/null | awk 'NR==1{print $1}')"
	if [ "$first_ip" != "127.0.0.1" ]; then
		echo "First resolution still $first_ip. Retrying by forcing IPv4 tools check."

		# Fallback test with ping -4; most ArcGIS components just need IPv4 to work
		if ping -4 -c1 -W1 localhost >/dev/null 2>&1; then
			echo "IPv4 localhost works (ping -4 succeeded) despite getent order. Proceeding."
			return 0
		fi

		echo "DEBUG getent hosts localhost:"
		getent hosts localhost || true
		die "Failed to ensure localhost prefers 127.0.0.1 (restored backup at $backup)"
	fi

	if ! ping -c1 -W1 localhost >/dev/null 2>&1; then
		die "Ping to localhost failed after update (backup at $backup)"
	fi

	echo "localhost now resolves first to 127.0.0.1"
}

# Function to check if Portal is already installed
function is_portal_installed() {
    local esri_properties_file
    esri_properties_file=$(find "/home/$RUN_AS_USER" -name ".ESRI.properties.*.$ARCGIS_VERSION" 2>/dev/null | head -1)
    
    if [[ -n "$esri_properties_file" ]] && [[ -f "$esri_properties_file" ]]; then
        if grep -q "Z_ArcGISPortal_INSTALL_DIR" "$esri_properties_file" 2>/dev/null; then
            return 0  # Installed
        fi
    fi
    return 1  # Not installed
}

#####################################################################
# install_portal - Installs ArcGIS Portal for ArcGIS on RHEL system
#
# This function handles the installation of ArcGIS Portal components
# on a Red Hat Enterprise Linux (RHEL) based Amazon Machine Image (AMI).
# It configures the portal software as part of the GIS enterprise
# infrastructure setup process.
#
# Usage:
#   install_portal
#
# Prerequisites:
#   - RHEL system with appropriate permissions
#   - ArcGIS Portal installation media available
#   - Required system dependencies installed
#
# Returns:
#   0 on successful installation
#   Non-zero exit code on failure
######################################################################
function install_portal(){
    log "INFO" "Timestamp: $TIMESTAMP"

    if is_portal_installed; then
        log "INFO" "Portal for ArcGIS is already installed"
        return 0
    fi
    
    # Check if running as root
    if [[ "$EUID" -ne 0 ]]; then
        log "WARNING" "This script should typically be run as root for full functionality"
    fi
    # install system requirements and configure OS
    install_system_requirements
    
    # configure localhost resolution
    configure_localhost_resolution

    # Download portal setup if not present or size is zero
	if [ ! -s "$tarball_path" ]; then
        run_download_s3 "$PORTAL_S3_URI" "$PORTAL_TARBALL_PATH" "Portal tarball"
	else
		echo "Portal tarball already present: $tarball_path"
	fi

    # Unpack setup if not already done
    run_unpack_tar "$PORTAL_TARBALL_PATH" "$SETUP_PATH" "$RUN_AS_USER"

    # Create installation directory structure 
    log "INFO" "Creating installation directory structure..."
    if [ ! -d "$PORTAL_INSTALL_PATH" ]; then
        mkdir -p "$PORTAL_INSTALL_PATH"	
	fi
    # Create subdirectories with proper permissions
    IFS='/' read -ra SUBDIR_PARTS <<< "arcgis/portal"
    current_path="/opt"
    for part in "${SUBDIR_PARTS[@]}"; do
        if [[ -n "$part" ]]; then
            current_path="$current_path/$part"
            chmod 700 "$current_path"
            chown "$RUN_AS_USER:$RUN_AS_GROUP" "$current_path"
        fi
    done
    # Run Portal installation (equivalent to :install action)
    log "INFO" "Installing Portal for ArcGIS..."
    log "INFO" "Install directory: $PORTAL_INSTALL_PATH"
    # Build installation command
    local setup_executable="${SETUP_PATH}/PortalForArcGIS/Setup"
    local install_cmd="$setup_executable -m silent -l yes -d \"$PORTAL_INSTALL_PATH\""
    
    # Execute installation as non-root user
    if [[ "$EUID" -eq 0 ]]; then
        # Running as root, switch to arcgis user
        su - "$RUN_AS_USER" -c "$install_cmd"
    else
        # Running as non-root user  
        eval "$install_cmd"
    fi
    
    # Verify installation
    if is_portal_installed; then
        log "SUCCESS" "Portal for ArcGIS installed successfully"
    else
        log "ERROR" "Portal installation verification failed"
        exit 1
    fi
    
    log "SUCCESS" "Portal installation completed"
    
    # start portal service 
    start_portal_service
    # install additional portal web styles
    install_webstyles
}

# Function to configure autostart and start Portal service
function start_portal_service() {

    log "INFO" "Configuring Portal autostart service..."
    
    # Detect init system and configure accordingly
    if systemctl --version >/dev/null 2>&1; then
        # Systemd
        configure_systemd_service
    elif [[ -d /etc/init.d ]]; then
        # SysV Init
        configure_sysv_service
    else
        log "WARNING" "Unknown init system. Manual service configuration required."
    fi
    
    
    # Start Portal service (equivalent to :start action)
    log "INFO" "Starting Portal for ArcGIS service..."
    
    if systemctl --version >/dev/null 2>&1 && [[ -f /etc/systemd/system/arcgisportal.service ]]; then
        # Direct start using Portal scripts
        log "INFO" "Starting Portal directly using systemctl arcgisportal.service..."
        systemctl start arcgisportal.service
        #systemctl status arcgisportal.service --no-pager
    elif [[ -f /etc/init.d/arcgisportal ]]; then
        log "INFO" "Starting Portal directly using service arcgisportal start..."
        service arcgisportal start
    else
        # Direct start using Portal scripts
        log "INFO" "Starting Portal directly using startportal.sh..."
        su - "$RUN_AS_USER" -c "$PORTAL_INSTALL_PATH/startportal.sh"
    fi

    log "SUCCESS" "Portal service started"
}

# Function to configure systemd service
function configure_systemd_service() {
    log "INFO" "Configuring systemd service..."
    
    local service_file="/etc/systemd/system/arcgisportal.service"
    
    cat > "$service_file" << EOF
[Unit]
Description=Portal for ArcGIS Service
After=network.target

[Service]
Type=forking
User=$RUN_AS_USER
Group=$RUN_AS_GROUP
ExecStart=$PORTAL_INSTALL_PATH/startportal.sh
ExecStop=$PORTAL_INSTALL_PATH/stopportal.sh
TimeoutStartSec=300
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
EOF

    # Set proper permissions
    chmod 644 "$service_file"
    
    # Reload systemd and enable service
    systemctl daemon-reload
    systemctl enable arcgisportal.service
    
    log "SUCCESS" "Systemd service configured and enabled"
}

# Function to configure SysV init service
function configure_sysv_service() {
    log "INFO" "Configuring SysV init service..."
    
    local init_script="/etc/init.d/arcgisportal"
    
    cat > "$init_script" << EOF
#!/bin/sh
### BEGIN INIT INFO
# Provides: arcgisportal
# Required-Start: \$ALL
# Required-Stop: 
# Default-Start: 3 5
# Default-Stop: 0 1 2 4 6
# chkconfig: 35 99 01
# Description: Portal for ArcGIS Service
# Short-Description: Portal for ArcGIS
### END INIT INFO

invoker=\`id | cut -f 2 -d '(' | cut -f 1 -d ')'\`

# Portal installation path
portalhome="$PORTAL_INSTALL_PATH"
portalowner=\`stat -c %U \$portalhome/framework/etc/arcgisportal 2>/dev/null || echo "$RUN_AS_USER"\`
MAX_SLEEP_COUNT=30

if [ -f /etc/init.d/functions ] ; then
   . /etc/init.d/functions
elif [ -f /etc/rc.d/init.d/functions ] ; then
   . /etc/rc.d/init.d/functions
fi

# Wait for network interface to be available (before starting Portal)
count=0
while [ 1 ]; do
  myip=\`ip addr show | grep 'inet ' | grep 'brd ' | grep -v '127.0.0.1' | head -1\`
  if [ "x\$myip" != "x" ]; then
    break
  fi
  count=\`expr \$count + 1\`
  if [ \$count -gt \$MAX_SLEEP_COUNT ]; then
    exit 1
  fi
  sleep 1
done

if [ "\$invoker" != "\$portalowner" ]; then
  echo "Invoking user (\$invoker) is not owner of Portal for ArcGIS (\$portalowner). Switching to account \$portalowner"
  su - \$portalowner -c "\$portalhome/framework/etc/agsportal.sh \$1"
  echo ""
else
   \$portalhome/framework/etc/agsportal.sh \$1
fi
EOF

    # Set proper permissions
    chmod 755 "$init_script"
    
    # Enable service for appropriate runlevels
    if command -v chkconfig > /dev/null 2>&1; then
        chkconfig --add arcgisportal
        chkconfig arcgisportal on
    elif command -v update-rc.d > /dev/null 2>&1; then
        update-rc.d arcgisportal defaults
    fi
    
    log "SUCCESS" "SysV init service configured and enabled"
}

# Function to install additional portal web styles
function install_webstyles() {
    log "INFO" "Installing Portal web styles "
    
    # Check if Portal is installed and running
    if ! is_portal_installed; then
        log "WARNING" "Portal not installed, skipping web styles installation"
        return 0
    fi
    
    # Download Portal WebStyles from s3 bucket 
    run_download_s3 "$PORTAL_WEBSTYLES_S3_URI" "$PORTAL_WEBSTYLES_TARBALL_PATH" "Portal WebStyles"

    # Web styles are typically installed as part of Portal setup

    local webstyles_path="$PORTAL_INSTALL_PATH/webapps/arcgis/css"

    run_unpack_tar "$PORTAL_WEBSTYLES_TARBALL_PATH" "$webstyles_path" "$RUN_AS_USER"
    
    log "SUCCESS" "Web styles installation completed"

    validate_portal_installation
    log "SUCCESS" "Portal for ArcGIS installation completed successfully!"
    portal_display_summary

}


# Function to display installation summary
function portal_display_summary() {
    cat << EOF

${GREEN}============================================${NC}
${GREEN}  Portal for ArcGIS Installation Summary  ${NC}
${GREEN}============================================${NC}

Configuration:
  Version:              $ARCGIS_VERSION
  Installation Path:    $PORTAL_INSTALL_PATH
  Data Directory:       $PORTAL_INSTALL_PATH/usr/arcgisportal
  Run-as User:          $RUN_AS_USER
  Run-as Group:         $RUN_AS_GROUP

Portal URLs:
  Direct:               https://$(hostname):7443/arcgis
  
Service Management:
EOF

    if systemctl --version >/dev/null 2>&1; then
        cat << EOF
  Start:                systemctl start arcgisportal.service
  Stop:                 systemctl stop arcgisportal.service
  Status:               systemctl status arcgisportal.service
  Restart:              systemctl restart arcgisportal.service
EOF
    elif [[ -f /etc/init.d/arcgisportal ]]; then
        cat << EOF
  Start:                service arcgisportal start
  Stop:                 service arcgisportal stop
  Status:               service arcgisportal status
  Restart:              service arcgisportal restart
EOF
    else
        cat << EOF
  Start:                su - $ARCGIS_USER -c '$PORTAL_INSTALL_PATH/startportal.sh'
  Stop:                 su - $ARCGIS_USER -c '$PORTAL_INSTALL_PATH/stopportal.sh'
EOF
    fi

    cat << EOF

Configuration Files:
  Portal Config:        $PORTAL_INSTALL_PATH/framework/etc/portal-config.properties
  Hostname Config:      $PORTAL_INSTALL_PATH/framework/etc/hostname.properties

Log Files:
  Installation Log:     $LOG_FILE
  Portal Logs:          $PORTAL_INSTALL_PATH/usr/arcgisportal/logs/

Next Steps:
1. Access Portal at https://$(hostname):7443/arcgis
2. Complete the initial site creation and configuration
3. Configure SSL certificates if needed
4. Set up Portal for production use

${GREEN}============================================${NC}

EOF
}
###########################################################
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

# Function to validate portal installation
function validate_portal_installation() {
    log "INFO" "Validating Portal for ArcGIS installation..."
    
    # Check if Portal is installed
    if ! is_portal_installed; then
        log "ERROR" "Portal installation validation failed - not detected as installed"
        return 1
    fi
    
    # Check critical files and directories
    local critical_paths=(
        "$PORTAL_INSTALL_PATH/startportal.sh"
        "$PORTAL_INSTALL_PATH/stopportal.sh"
        "$PORTAL_INSTALL_PATH/framework/etc/arcgisportal"
        "$PORTAL_INSTALL_PATH/usr/arcgisportal"
    )
    
    for path in "${critical_paths[@]}"; do
        if [[ ! -e "$path" ]]; then
            log "ERROR" "Critical path missing: $path"
            return 1
        fi
    done
    
    
    if systemctl --version >/dev/null 2>&1; then
        if ! systemctl is-enabled arcgisportal.service >/dev/null 2>&1; then
            log "WARNING" "Portal service is not enabled for autostart"
        fi
    fi

    
    log "SUCCESS" "Portal for ArcGIS installation validation completed"
    return 0
}

function check_root() {
    if [[ $EUID -ne 0 ]]; then
        log "ERROR" "This script must be run as root (use sudo)"
        exit 1
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



function cleanup_installer_files() {
    log "INFO" "Cleaning up installer files..."

    # Clean up setup files if requested
    if [[ -d "$SETUP_PATH" ]]; then
        rm -rf "$SETUP_PATH"
        log "INFO" "Removed setup directory: ${SETUP_PATH}"
    fi

    log "INFO" "Cleanup completed"
}

############################################################################
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
############################################################################

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

    # Portal
    PORTAL_S3_URI=$(echo "$config_json" | jq -r '.arcgis.portal.s3_uri // empty')
    PORTAL_INSTALL_PATH=$(echo "$config_json" | jq -r '.arcgis.portal.install_path // empty')
    PORTAL_TARBALL_PATH=$(echo "$config_json" | jq -r '.arcgis.portal.tarball_path // empty')
    PORTAL_WEBSTYLES_S3_URI=$(echo "$config_json" | jq -r '.arcgis.portal.s3_webstyles_uri // empty')
    PORTAL_WEBSTYLES_TARBALL_PATH=$(echo "$config_json" | jq -r '.arcgis.portal.webstyles_tarball_path // empty')

    # Portal patches
    mapfile -t PORTAL_PATCH_NAMES < <(echo "$config_json" | jq -r '.arcgis.portal.patches[]?.name')
    mapfile -t PORTAL_PATCH_S3_URIS < <(echo "$config_json" | jq -r '.arcgis.portal.patches[]?.s3_uri')
    mapfile -t PORTAL_PATCH_DOWNLOAD_PATHS < <(echo "$config_json" | jq -r '.arcgis.portal.patches[]?.download_path')
    mapfile -t PORTAL_PATCH_APPLY < <(echo "$config_json" | jq -r '.arcgis.portal.patches[]?.apply')
    PORTAL_PATCH_COUNT=${#PORTAL_PATCH_NAMES[@]}

    
    # Derived configuration
    SETUP_PATH="$SETUPS_PATH/$ARCGIS_VERSION"

    # Web service ports
    HTTP_PORT="8080"
    HTTPS_PORT="8443"
    AJP_PORT="8009"
    SHUTDOWN_PORT="8005"

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
    # Install arcgis portal
    install_portal
    log "RHEL AMI setup completed successfully"
    cleanup_installer_files
    exit 0
}

# Testability guard: only invoke main when script is executed directly, not when sourced.
# Main execution
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi