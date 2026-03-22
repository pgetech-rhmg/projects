#!/bin/bash
# build-custom-component.sh

yum update -y

#check if yum update is completed 

YumProcess=`ps -ef | grep 'yum' | grep -v 'grep' | wc`

while [[ YumProcess -gt 0 ]]
do
     sleep 5;
done


STAGING=/elevate-image-builder-staging
echo "Staging directory is ${STAGING}"

############# place Arcgis installation steps here #############

## Input parameters
S3_BUCKET="s3://elevate-installer"
DEPLOY_SCRIPT_KEY="rhel-imagebuilder/deployscripts/11-5/"
LOCAL_SCRIPT_DIR="arcgis/11-5/deployscripts"

# Copy arcgis enterprise deploy scripts from S3 bucket folder

echo "Copying scripts from S3 bucket ${S3_BUCKET} to ${STAGING}/${LOCAL_SCRIPT_DIR}"
aws s3 cp "${S3_BUCKET}/${DEPLOY_SCRIPT_KEY}" "${STAGING}/${LOCAL_SCRIPT_DIR}" --recursive

echo "Setting execute permissions for scripts in ${STAGING}/${LOCAL_SCRIPT_DIR}"
chmod +x "${STAGING}/${LOCAL_SCRIPT_DIR}"/*

# call the enterprise install script
echo "Calling the enterprise install script"
"${STAGING}/${LOCAL_SCRIPT_DIR}/arcgis-portal-linux-ami.sh" "${STAGING}/${LOCAL_SCRIPT_DIR}/arcgis-portal-115.json"




#################################################################################


## file created to skip cleanup of ssh keys by imagebuilder autocleanup script

touch /tmp/skip_cleanup_ssh_files

# Clean up for ssh key files
SSH_FILES=(
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
    "/etc/ssh/ssh_host_ecdsa_key"
    "/etc/ssh/ssh_host_ecdsa_key.pub"
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
    "/root/.ssh/authorized_keys"
    "/home/ec2-user/.ssh/authorized_keys"
)
    echo "Cleaning up ssh key files"
    for keysfile in "${SSH_FILES[@]}"; do
        echo "Deleting $keysfile keys file";
        rm $keysfile;
    done
