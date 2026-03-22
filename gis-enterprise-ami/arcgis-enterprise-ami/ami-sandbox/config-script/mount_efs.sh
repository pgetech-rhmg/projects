#!/bin/bash
# mount and initialize EFS on the EC2 instance

set -e

# Setup logging
LOG_FILE="/var/log/efs_mount.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting EFS mount script"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] EFS_ID is set to ${EFS_ID}"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] MNT_DIR is set to ${MNT_DIR}"

# Install required packages
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing required packages..."
yum update -y
yum install -y jq curl
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Required packages installed successfully"

# Building efs-utils from Source
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Building and Installing efs-utils from source..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source /root/.cargo/env
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing efs-utils dependencies..."
yum -y install golang git rpm-build make rust cargo openssl-devel cmake wget perl
if [ ! -d "efs-utils" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cloning efs-utils repository..."
    git clone https://github.com/aws/efs-utils
    cd efs-utils
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Building efs-utils RPM..."
    make rpm
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installing efs-utils..."
    yum -y install build/amazon-efs-utils*rpm
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] efs-utils installed successfully"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] efs-utils directory already exists, skipping clone"
fi

# Mount EFS share
if [ -n "${EFS_ID}" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mounting EFS share"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting SSM agent..."
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SSM agent started"
    
    if [[ -d "${MNT_DIR}" ]]
    then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Directory ${MNT_DIR} already exists"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Creating directory ${MNT_DIR}"
        mkdir -p "${MNT_DIR}" # Create mount point
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Directory created successfully"
    fi
    
    # Add EFS mount to fstab (avoid duplicates)
    if ! grep -q "${EFS_ID}:/" /etc/fstab; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Adding EFS mount to /etc/fstab"
        if echo "${EFS_ID}:/ ${MNT_DIR} efs _netdev,tls,iam 0 0" >> /etc/fstab; then
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Successfully added EFS mount to /etc/fstab"
            # Test mount
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Testing mount configuration..."
            if mount -a; then
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] EFS mounted successfully"
            else
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: Mount test failed" >&2
            fi
        else
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to add EFS mount to /etc/fstab" >&2
            exit 1
        fi
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] EFS mount already exists in /etc/fstab"
    fi
    
    # Mount the share
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Mounting all filesystems..."
    mount -fav
    
    # Verify EFS mount
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Verifying EFS mount..."
    if mountpoint -q "${MNT_DIR}"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] EFS share mounted successfully at ${MNT_DIR}"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: Failed to mount EFS share at ${MNT_DIR}"
        exit 1
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: EFS_ID not provided"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] EFS setup completed successfully"