#!/bin/bash
# PGE ArcGIS Installation Script
# Developed by: Adrien H. and Austin M. - Esri AES Team
set -e

# Ensure the script is running with root privileges
if [[ "$EUID" -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Script configuration
SCRIPT_NAME="$(basename "$0")"

# Global Variables
# EFS Mount Variables
EFS_ID="fs-040fa4fca6e40f54e"
MOUNT_POINT="/mnt/gisdata"

# Local Machine Directories for downloads, setups, cookbooks, attributes, cache, and temp files
DOWNLOAD_PATH="/opt/software/downloads"
SETUP_PATH="/opt/software/setups"
CINC_COOKBOOK_PATH="/opt/cinc/cookbooks"
CINC_ATTRIBUTES_PATH="/opt/cinc/attributes"
CINC_CACHE_PATH="/opt/cinc/cache"
CINC_TEMP_PATH="/opt/cinc/temp"
LOCAL_PATCH_BASE="$DOWNLOAD_PATH/patches"

# S3 bucket url and folders - any changes to the names within the bucket will require updates to these variables
BASE_S3_URI="${BASE_S3_URI:-"s3://elevate-installer/esri/esri-aes-pge-sftwr/"}"
SOFTWARE_FOLDER="software/"
COOKBOOK_FOLDER="cookbooks/"
PATCH_FOLDER="patches/"
ARCGIS_COOKBOOKS="arcgis-cookbook-main"
CONFIG_FOLDER="amiShellFiles/Install/"

# Files to be downloaded from S3 - install files are version specific - updated versions will require changes to names of files
ARCGIS_COOKBOOK_ZIP="arcgis-cookbook-main.zip"
CINC_RPM_FILE="cinc-18.5.0-1.amazon2023.x86_64.rpm"
PORTAL_CONFIG_FILE="arcgis-install-portal.json"
PORTAL_PATCHES_FILE="arcgis-portal-patches-apply.json"
PORTAL_INSTALL_FILE="Portal_for_ArcGIS_Linux_115_195451.tar.gz"
WEBSTYLES_FILE="Portal_for_ArcGIS_Web_Styles_Linux_115_195200.tar.gz"
SERVER_CONFIG_FILE="arcgis-install-server.json"
SERVER_PATCHES_FILE="arcgis-server-patches-apply.json"
SERVER_INSTALL_FILE="ArcGIS_Server_Linux_115_195440.tar.gz"
DATASTORE_CONFIG_FILE="arcgis-install-datastore.json"
DATASTORE_PATCHES_FILE="arcgis-datastore-patches-apply.json"
DATASTORE_INSTALL_FILE="ArcGIS_DataStore_Linux_115_195461.tar.gz"

# Web Adaptor has multiple configs for different WA's - install files are version specific - updated versions will require changes to names of files
WEBADAPTOR_HOSTING_CONFIG_FILE="arcgis-install-hosting-webadaptor.json"
WEBADAPTOR_GO_CONFIG_FILE="arcgis-install-go-webadaptor.json"
WEBADAPTOR_PORTAL_CONFIG_FILE="arcgis-install-portal-webadaptor.json"
WEBADAPTOR_PATCHES_FILE="arcgis-webadaptor-patches-apply.json"
WEBADAPTOR_INSTALL_FILE="ArcGIS_Web_Adaptor_Java_Linux_115_195462.tar.gz"
TOMCAT_INSTALL_FILE="apache-tomcat-9.0.106.tar.gz"
OPENJDK_INSTALL_FILE="OpenJDK17U-jdk_x64_linux_hotspot_17.0.17_10.tar.gz"

# ARCGIS CINC Related Vars - these names are used in the cookbook so changing these names would cause cinc-client based component install to fail
ARCGIS_VERSION="11.5"
PORTAL_SETUP_SUBDIR="PortalForArcGIS"
WEBSTYLES_SETUP_SUBDIR="WebStyles"
SERVER_SETUP_SUBDIR="ArcGISServer"
DS_SETUP_SUBDIR="ArcGISDataStore_Linux"
WEBADAPTOR_SETUP_SUBDIR="WebAdaptor"
OPENJDK_SETUP_SUBDIR="java_17.0.17+10"
TOMCAT_SETUP_SUBDIR="apache-tomcat-9.0.106"



LOG_FILE="/var/log/arcgis-install.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
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
        echo -e "${LIGHTBLUE}INFO: $2${NC}"
    fi
}

log "INFO" "Linux shell environment initialized."

# Function to check if AWS CLI is installed, if not log an error and exit as it is needed for the script to run successfully
function aws_cli_installed() {
    if command -v aws &> /dev/null; then
        log "SUCCESS" "AWS CLI is already installed."
        return 0
    else
        log "ERROR" "AWS CLI is not installed. Please install AWS CLI to proceed."
        return 1
    fi
}

# Function to mount the EFS volume, if not log an error and exit as it is needed for the script to run successfully
function mount_efs_volume() {
    log "INFO" "Starting EFS mount process..."
    # Ensure amazon-efs-utils is installed
    if ! rpm -q amazon-efs-utils &>/dev/null; then
        log "INFO" "Installing amazon-efs-utils..."
        if ! yum install -y amazon-efs-utils; then
            log "ERROR" "Failed to install amazon-efs-utils."
            return 1
        fi
    else
        log "SUCCESS" "amazon-efs-utils already installed."
    fi

    # Create mount point
    if [ ! -d "$MOUNT_POINT" ]; then
        log "INFO" "Creating mount point $MOUNT_POINT"
        if ! mkdir -p "$MOUNT_POINT"; then
            log "ERROR" "Failed to create mount point."
            return 1
        fi
    fi

    # Mount if not already mounted
    if mountpoint -q "$MOUNT_POINT"; then
        log "SUCCESS" "EFS already mounted at $MOUNT_POINT"
    else
        log "INFO" "Mounting EFS $EFS_ID to $MOUNT_POINT"
        if ! mount -t efs -o tls,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,noresvport,_netdev "${EFS_ID}:/" "$MOUNT_POINT"; then
            log "ERROR" "EFS mount command failed."
            return 1
        fi
    fi

    # Verify mount
    if ! mountpoint -q "$MOUNT_POINT"; then
        log "ERROR" "Mount verification failed."
        return 1
    fi
    log "SUCCESS" "EFS successfully mounted."

    # Add to /etc/fstab if not already present
    if ! grep -qs "$EFS_ID:/" /etc/fstab; then
        log "INFO" "Adding EFS entry to /etc/fstab"
        echo "${EFS_ID}:/ ${MOUNT_POINT} efs nofail,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,noresvport,_netdev,tls 0 0" >> /etc/fstab || {
            log "ERROR" "Failed to update /etc/fstab"
            return 1
        }
    else
        log "SUCCESS" "fstab entry already exists."
    fi

    log "SUCCESS" "EFS mount configuration complete."
    return 0
}


# Function to check if CINC is installed, if not proceed with installation
function cinc_installed() {
    if command -v cinc-client &> /dev/null; then
        log "SUCCESS" "CINC is already installed."
        return 0
    else
        install_cinc
    fi
}

# Function to install Cinc client using the rpm package provided in the S3 bucket - also adds cinc to the PATH and validates the installation was successful
function install_cinc() {
    # Install Cinc client
    log "WARNING" "CINC is not installed. Installing CINC to proceed."
    log "INFO" "Downloading CINC installation package from S3..."
    aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${CINC_RPM_FILE}" "$DOWNLOAD_PATH/$CINC_RPM_FILE"
    log "INFO" "CINC installation package downloaded: $CINC_RPM_FILE"

    log "INFO" "Installing CINC..."
    sudo rpm -Uvh "$DOWNLOAD_PATH/$CINC_RPM_FILE"

    # Check if /opt/cinc/bin is in PATH, if not add it
    if [[ ":$PATH:" != *":/opt/cinc/bin:"* ]]; then
        log "INFO" "Exporting CINC to PATH..."
        export PATH=$PATH:/opt/cinc/bin
        log "INFO" "Path updated to include CINC: $PATH"
    else
        log "INFO" "/opt/cinc/bin is already in PATH"
    fi

    # Validate the cinc-client command is available after installation
    if command -v cinc-client &> /dev/null; then
        log "INFO" "CINC client is successfully installed and available in PATH."
    else
        log "ERROR" "CINC client installation failed or is not in PATH. Please check the installation."
        exit 1
    fi

    log "SUCCESS" "CINC installation completed."
}

# Function to configure CINC client by creating the client.rb file with the appropriate cookbook path - this is needed for the cinc-client commands to run successfully
function configure_cinc() {
    log "INFO" "Configuring CINC client..."
    
    CLIENT_CONFIG='/etc/cinc/client.rb'
    sudo touch $CLIENT_CONFIG
    sudo sed -i /^cookbook_path/d $CLIENT_CONFIG
    echo "cookbook_path ['/opt/cinc/cookbooks']" | sudo tee -a $CLIENT_CONFIG
    echo "All future cinc-client commands should use -c /etc/cinc/client.rb"
    log "SUCCESS" "CINC client configured"

}

# Function to create necessary directories
function mkdir_if_not_exists() {
    local mkdir_portal=false
    local mkdir_server=false
    local mkdir_datastore=false
    local mkdir_webadaptor=false

    # Determine which directories to create based on the arguments passed to the function
    for arg in "$@"; do
        case "$arg" in
            "portal") mkdir_portal=true ;;
            "server") mkdir_server=true ;;
            "datastore") mkdir_datastore=true ;;
            "webadaptor") mkdir_webadaptor=true ;;
        esac
    done

    # These directories are needed regardless of which component is being installed so they are created outside of the conditional statements
    log "INFO" "Creating necessary directories..."
    mkdir -p "$DOWNLOAD_PATH"
    mkdir -p "$CINC_COOKBOOK_PATH" 
    mkdir -p "$CINC_ATTRIBUTES_PATH" 
    mkdir -p "$CINC_CACHE_PATH" 
    mkdir -p "$CINC_TEMP_PATH"

    # Component specific directories are created based on the flags set by the arguments passed to the function
    log "INFO" "Ensuring setup directories for ArcGIS components exist..."
    if [ "$mkdir_portal" = true ]; then
        mkdir -p "$SETUP_PATH/$ARCGIS_VERSION/$PORTAL_SETUP_SUBDIR"
        mkdir -p "$SETUP_PATH/$ARCGIS_VERSION/$WEBSTYLES_SETUP_SUBDIR"
        mkdir -p "$LOCAL_PATCH_BASE/portal"
        log "INFO" "Portal directories created."
    fi
    if [ "$mkdir_server" = true ]; then
        mkdir -p "$SETUP_PATH/$ARCGIS_VERSION/$SERVER_SETUP_SUBDIR"
        mkdir -p "$LOCAL_PATCH_BASE/server"
        log "INFO" "Server directories created."
    fi
    if [ "$mkdir_datastore" = true ]; then
        mkdir -p "$SETUP_PATH/$ARCGIS_VERSION/$DS_SETUP_SUBDIR"
        mkdir -p "$LOCAL_PATCH_BASE/datastore"
        log "INFO" "Data Store directories created."
    fi
    if [ "$mkdir_webadaptor" = true ]; then
        mkdir -p "$SETUP_PATH/$ARCGIS_VERSION/$WEBADAPTOR_SETUP_SUBDIR"
        mkdir -p "/opt/$TOMCAT_SETUP_SUBDIR"
        mkdir -p "/opt/$OPENJDK_SETUP_SUBDIR"
        mkdir -p "$LOCAL_PATCH_BASE/webadaptor"
        log "INFO" "Web Adaptor directories created."
    fi

    log "SUCCESS" "Directory creation completed."
}

# Function to download necessary resources from S3, extract them to the appropriate locations, and clean up the downloaded files
function download_s3_resources() {
    local install_portal=false
    local install_server=false
    local install_datastore=false
    local install_webadaptor=false

    # Determine which components based on the arguments passed to the function are being installed and downloads the necessary resources for those components from S3
    for arg in "$@"; do
        case "$arg" in
            "portal") install_portal=true ;;
            "server") install_server=true ;;
            "datastore") install_datastore=true ;;
            "webadaptor") install_webadaptor=true ;;
        esac
    done

    log "INFO" "Downloading necessary resources from s3..."

    if [ "$install_portal" = true ]; then
        # Portal JSON Config file Download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${PORTAL_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$PORTAL_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$PORTAL_CONFIG_FILE"
        log "INFO" "Download completed: $PORTAL_CONFIG_FILE"
        # Portal Patches JSON Config File download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${PORTAL_PATCHES_FILE}" "$CINC_ATTRIBUTES_PATH/$PORTAL_PATCHES_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$PORTAL_PATCHES_FILE"
        log "INFO" "Download completed: $PORTAL_PATCHES_FILE"		        
        # Portal Enterprise Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${PORTAL_INSTALL_FILE}" "$DOWNLOAD_PATH/$PORTAL_INSTALL_FILE"
        log "INFO" "Download completed: $PORTAL_INSTALL_FILE"
        # Extract the installation file to the setup path
        log "INFO" "Extracting $PORTAL_INSTALL_FILE to $SETUP_PATH/$ARCGIS_VERSION/$PORTAL_SETUP_SUBDIR..."
        tar -xzf "$DOWNLOAD_PATH/$PORTAL_INSTALL_FILE" -C "$SETUP_PATH/$ARCGIS_VERSION/$PORTAL_SETUP_SUBDIR" --strip-components=1
        log "INFO" "Extraction completed"
        # Remove the downloaded installation file
        rm -f "$DOWNLOAD_PATH/$PORTAL_INSTALL_FILE"
        log "INFO" "Removed $PORTAL_INSTALL_FILE"

        # Portal WebStyles Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${WEBSTYLES_FILE}" "$DOWNLOAD_PATH/$WEBSTYLES_FILE"
        log "INFO" "Download completed: $WEBSTYLES_FILE"
        # Extract the web styles file to the setup path
        log "INFO" "Extracting $WEBSTYLES_FILE to $SETUP_PATH/$ARCGIS_VERSION/$WEBSTYLES_SETUP_SUBDIR..."
        tar -xzf "$DOWNLOAD_PATH/$WEBSTYLES_FILE" -C "$SETUP_PATH/$ARCGIS_VERSION/$WEBSTYLES_SETUP_SUBDIR" --strip-components=1
        log "INFO" "Extraction completed"
        # Remove the downloaded web styles file
        rm -f "$DOWNLOAD_PATH/$WEBSTYLES_FILE"
        log "INFO" "Removed $WEBSTYLES_FILE"		
        # Portal Patches download
        log "INFO" "Downloading all Portal patches from S3..."
        aws s3 cp "${BASE_S3_URI}${PATCH_FOLDER}portal/" "$LOCAL_PATCH_BASE/portal/" --recursive
        log "SUCCESS" "Portal patches downloaded."		
    fi

    if [ "$install_server" = true ]; then
        log "INFO" "Installing ArcGIS Server..."
        # Server JSON Config file Download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${SERVER_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$SERVER_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$SERVER_CONFIG_FILE"
        log "INFO" "Download completed: $SERVER_CONFIG_FILE"
        # Server Patches JSON file Download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${SERVER_PATCHES_FILE}" "$CINC_ATTRIBUTES_PATH/$SERVER_PATCHES_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$SERVER_PATCHES_FILE"
        log "INFO" "Download completed: $SERVER_PATCHES_FILE"
        # Server Enterprise Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${SERVER_INSTALL_FILE}" "$DOWNLOAD_PATH/$SERVER_INSTALL_FILE"
        log "INFO" "Download completed: $SERVER_INSTALL_FILE"
        # Extract the installation file to the setup path
        log "INFO" "Extracting $SERVER_INSTALL_FILE to $SETUP_PATH/$ARCGIS_VERSION/$SERVER_SETUP_SUBDIR..."
        tar -xzf "$DOWNLOAD_PATH/$SERVER_INSTALL_FILE" -C "$SETUP_PATH/$ARCGIS_VERSION/$SERVER_SETUP_SUBDIR" --strip-components=1
        log "INFO" "Extraction completed"
        # Remove the downloaded installation file
        rm -f "$DOWNLOAD_PATH/$SERVER_INSTALL_FILE"
        log "INFO" "Removed $SERVER_INSTALL_FILE"
        # Server Patches download
        log "INFO" "Downloading all Server patches from S3..."
        aws s3 cp "${BASE_S3_URI}${PATCH_FOLDER}server/" "$LOCAL_PATCH_BASE/server/" --recursive
        log "SUCCESS" "Server patches downloaded."
    fi

    if [ "$install_datastore" = true ]; then
        log "INFO" "Installing ArcGIS Data Store..."
        # Datastore JSON Config file Download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${DATASTORE_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$DATASTORE_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$DATASTORE_CONFIG_FILE"
        log "INFO" "Download completed: $DATASTORE_CONFIG_FILE"
        # Datastore Patches JSON Config file Download
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${DATASTORE_PATCHES_FILE}" "$CINC_ATTRIBUTES_PATH/$DATASTORE_PATCHES_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$DATASTORE_PATCHES_FILE"
        log "INFO" "Download completed: $DATASTORE_PATCHES_FILE"
        # Datastore Enterprise Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${DATASTORE_INSTALL_FILE}" "$DOWNLOAD_PATH/$DATASTORE_INSTALL_FILE"
        log "INFO" "Download completed: $DATASTORE_INSTALL_FILE"
        # Extract the installation file to the setup path
        log "INFO" "Extracting $DATASTORE_INSTALL_FILE to $SETUP_PATH/$ARCGIS_VERSION/$DS_SETUP_SUBDIR..."
        tar -xzf "$DOWNLOAD_PATH/$DATASTORE_INSTALL_FILE" -C "$SETUP_PATH/$ARCGIS_VERSION/$DS_SETUP_SUBDIR" --strip-components=1
        log "INFO" "Extraction completed"
        # Remove the downloaded installation file
        rm -f "$DOWNLOAD_PATH/$DATASTORE_INSTALL_FILE"
        log "INFO" "Removed $DATASTORE_INSTALL_FILE"
        # Data Store Patches download
        log "INFO" "Downloading all Data Store patches from S3..."
        aws s3 cp "${BASE_S3_URI}${PATCH_FOLDER}datastore/" "$LOCAL_PATCH_BASE/datastore/" --recursive
        log "SUCCESS" "Data Store patches downloaded."
    fi

    if [ "$install_webadaptor" = true ]; then
        log "INFO" "Installing ArcGIS Web Adaptor..."
        # Web Adaptor JSON Config file Downloads
        log "INFO" "Downloading Web Adaptor HOSTING JSON config file..."
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${WEBADAPTOR_HOSTING_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_HOSTING_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_HOSTING_CONFIG_FILE"
        log "INFO" "Download completed: $WEBADAPTOR_HOSTING_CONFIG_FILE"

        log "INFO" "Downloading Web Adaptor GO JSON config file..."
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${WEBADAPTOR_GO_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_GO_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_GO_CONFIG_FILE"
        log "INFO" "Download completed: $WEBADAPTOR_GO_CONFIG_FILE"

        log "INFO" "Downloading Web Adaptor PORTAL JSON config file..."
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${WEBADAPTOR_PORTAL_CONFIG_FILE}" "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_PORTAL_CONFIG_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_PORTAL_CONFIG_FILE"
        log "INFO" "Download completed: $WEBADAPTOR_PORTAL_CONFIG_FILE"
		
		# Web Adaptor Patches JSON Config file Downloads
        log "INFO" "Downloading Web Adaptor Patches JSON config file..."
        aws s3 cp "${BASE_S3_URI}${CONFIG_FOLDER}${WEBADAPTOR_PATCHES_FILE}" "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_PATCHES_FILE"
        chmod 777 "$CINC_ATTRIBUTES_PATH/$WEBADAPTOR_PATCHES_FILE"
        log "INFO" "Download completed: $WEBADAPTOR_PATCHES_FILE"

        # OpenJDK Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${OPENJDK_INSTALL_FILE}" "$DOWNLOAD_PATH/$OPENJDK_INSTALL_FILE"
        log "INFO" "Download completed: $OPENJDK_INSTALL_FILE"
        # Cookbook will handle extract

        # Tomcat Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${TOMCAT_INSTALL_FILE}" "$DOWNLOAD_PATH/$TOMCAT_INSTALL_FILE"
        log "INFO" "Download completed: $TOMCAT_INSTALL_FILE"
        # Cookbook will handle extract

        # Web Adaptor Installation file Download
        aws s3 cp "${BASE_S3_URI}${SOFTWARE_FOLDER}${WEBADAPTOR_INSTALL_FILE}" "$DOWNLOAD_PATH/$WEBADAPTOR_INSTALL_FILE"
        log "INFO" "Download completed: $WEBADAPTOR_INSTALL_FILE"
        # Extract the installation file to the setup path
        log "INFO" "Extracting $WEBADAPTOR_INSTALL_FILE to $SETUP_PATH/$ARCGIS_VERSION/$WEBADAPTOR_SETUP_SUBDIR..."
        tar -xzf "$DOWNLOAD_PATH/$WEBADAPTOR_INSTALL_FILE" -C "$SETUP_PATH/$ARCGIS_VERSION/$WEBADAPTOR_SETUP_SUBDIR" --strip-components=1
        log "INFO" "Extraction completed"
        # Remove the downloaded installation file
        rm -f "$DOWNLOAD_PATH/$WEBADAPTOR_INSTALL_FILE"
        log "INFO" "Removed $WEBADAPTOR_INSTALL_FILE"
        # Web Adaptor Patches download
        log "INFO" "Downloading all Web Adaptor patches from S3..."
        aws s3 cp "${BASE_S3_URI}${PATCH_FOLDER}webadaptor/" "$LOCAL_PATCH_BASE/webadaptor/" --recursive
        log "SUCCESS" "Web Adaptor patches downloaded."
    fi

    # Cookbooks Download
    aws s3 cp "${BASE_S3_URI}${COOKBOOK_FOLDER}" "$CINC_COOKBOOK_PATH" --recursive
    log "INFO" "Cookbooks downloaded to tmp location: $CINC_COOKBOOK_PATH"

    # UNZIP the main arcgis cookbook zip file to the final location
    unzip -o "$CINC_COOKBOOK_PATH/$ARCGIS_COOKBOOK_ZIP" -d /opt/cinc/
    # Copy contents of the unzipped folder to the cookbooks directory
    cp -rf /opt/cinc/$ARCGIS_COOKBOOKS/cookbooks/* /opt/cinc/cookbooks/
    # Remove the unzipped folder after copying
    rm -rf /opt/cinc/$ARCGIS_COOKBOOKS/
    log "INFO" "Cookbook unzipped to final location: /opt/cinc/cookbooks"

    # Cleanup the zip file after extraction
    rm -rf "$CINC_COOKBOOK_PATH/$ARCGIS_COOKBOOK_ZIP" || true
    log "INFO" "Removed cookbook zip file: $CINC_COOKBOOK_PATH/$ARCGIS_COOKBOOK_ZIP"

    # Adjust privs on the cookbooks folder
    chown -R root:root /opt/cinc/cookbooks/*
    chmod -R 755 /opt/cinc/cookbooks/*
    log "INFO" "Cookbook permissions set to 755 and ownership set to root:root"

    log "SUCCESS" "All necessary resources downloaded and prepared from S3."
}

function install_component() {
    local install_portal=false
    local install_server=false
    local install_datastore=false
    local install_webadaptor=false

    # Determine which components to install based on the arguments passed to the function
    for arg in "$@"; do
        case "$arg" in
            "portal") install_portal=true ;;
            "server") install_server=true ;;
            "datastore") install_datastore=true ;;
            "webadaptor") install_webadaptor=true ;;
        esac
    done

    log "INFO" "Downloading necessary resources from s3..."

    # Use CINC client to install the portal based on the flags set by the arguments
    if [ "$install_portal" = true ]; then
        log "INFO" "Installing ArcGIS Portal..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-portal.json

        log "SUCCESS" "Portal installation completed."


        # Run patch if config exists
        if [ -f "$CINC_ATTRIBUTES_PATH/arcgis-portal-patches-apply.json" ]; then
            log "INFO" "Applying Portal patches..."
            cinc-client -z -c /etc/cinc/client.rb -j "$CINC_ATTRIBUTES_PATH/arcgis-portal-patches-apply.json"
            log "SUCCESS" "Portal patches applied."
        else
            log "WARNING" "No Portal patch config found. Skipping patch step."
        fi
    fi


    # Use CINC client to install the server based on the flags set by the arguments
    if [ "$install_server" = true ]; then
        log "INFO" "Installing ArcGIS Server..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-server.json
        log "SUCCESS" "Server installation completed."

        # Run patch if config exists
        if [ -f "$CINC_ATTRIBUTES_PATH/arcgis-server-patches-apply.json" ]; then
            log "INFO" "Applying Server patches..."
            cinc-client -z -c /etc/cinc/client.rb -j "$CINC_ATTRIBUTES_PATH/arcgis-server-patches-apply.json"
            log "SUCCESS" "Server patches applied."
        else
            log "WARNING" "No Server patch config found. Skipping patch step."
        fi
    fi

    # Use CINC client to install the datastore based on the flags set by the arguments
    if [ "$install_datastore" = true ]; then
        log "INFO" "Installing ArcGIS Data Store..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-datastore.json
        log "SUCCESS" "Data Store installation completed."

        # Run patch if config exists
        if [ -f "$CINC_ATTRIBUTES_PATH/arcgis-datastore-patches-apply.json" ]; then
            log "INFO" "Applying Data Store patches..."
            cinc-client -z -c /etc/cinc/client.rb -j "$CINC_ATTRIBUTES_PATH/arcgis-datastore-patches-apply.json"
            log "SUCCESS" "Data Store patches applied."
        else
            log "WARNING" "No Data Store patch config found. Skipping patch step."
        fi
    fi

    # Use CINC client to install the web adaptor based on the flags set by the arguments - this installs all 3 WA as PGE has all of them on the same machine...
    if [ "$install_webadaptor" = true ]; then
        log "INFO" "Installing ArcGIS Portal Web Adaptor..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-portal-webadaptor.json
        log "INFO" "ArcGIS Portal Web Adaptor installation completed. Proceeding with other Web Adaptors..."

        log "INFO" "Installing ArcGIS Hosting Web Adaptor..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-hosting-webadaptor.json
        log "INFO" "ArcGIS Hosting Web Adaptor installation completed. Proceeding with GO Web Adaptor..."

        log "INFO" "Installing ArcGIS GO Web Adaptor..."
        cinc-client -z -c /etc/cinc/client.rb -j /opt/cinc/attributes/arcgis-install-go-webadaptor.json
        log "INFO" "ArcGIS GO Web Adaptor installation completed."

        log "INFO" "All Web Adaptor installations completed."

        # Run patch if config exists
        if [ -f "$CINC_ATTRIBUTES_PATH/arcgis-webadaptor-patches-apply.json" ]; then
            log "INFO" "Applying Web Adaptor patches..."
            cinc-client -z -c /etc/cinc/client.rb -j "$CINC_ATTRIBUTES_PATH/arcgis-webadaptor-patches-apply.json"
            log "SUCCESS" "Web Adaptor patches applied."
        else
            log "WARNING" "No Web Adaptor patch config found. Skipping patch step."
        fi
    fi

    log "SUCCESS" "Installation process for specified components completed."
}

function main() {
    log "INFO" "Starting ArcGIS installation process..."

    # Check prerequisites
    aws_cli_installed || exit 1

    # Mount EFS volume
    # mount_efs_volume || exit 1

    # Install CINC if not already installed
    cinc_installed || exit 1

    # Configure CINC client
    configure_cinc

    # Create necessary directories
    mkdir_if_not_exists "$@"

    # Download resources
    download_s3_resources "$@"

    # Install ArcGIS Components and Patches using CINC
    install_component "$@"

    log "SUCCESS" "Installation for "$@" finished successfully."
}

# Allows direct execution while sitll being able to source for testing helper  functions
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi