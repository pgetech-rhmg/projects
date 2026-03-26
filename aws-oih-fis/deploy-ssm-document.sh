#!/bin/bash

# Deploy SSM Document for SQL Server DAG Primary Discovery
# This script creates or updates the SSM document in your AWS account

set -e

DOCUMENT_NAME="OIH-Discover-SQL-DAG-Primary"
DOCUMENT_FILE="ssm-documents/discover-sql-dag-primary.yaml"

echo "Deploying SSM Document: ${DOCUMENT_NAME}"
echo "Using file: ${DOCUMENT_FILE}"
echo ""

# Check if document exists
if aws ssm describe-document --name "${DOCUMENT_NAME}" &>/dev/null; then
    echo "Document exists. Updating to latest version..."
    aws ssm update-document \
      --name "${DOCUMENT_NAME}" \
      --document-format YAML \
      --content "file://${DOCUMENT_FILE}" \
      --document-version '$LATEST'

    # Set the new version as default
    LATEST_VERSION=$(aws ssm describe-document --name "${DOCUMENT_NAME}" --query 'Document.LatestVersion' --output text)
    aws ssm update-document-default-version \
      --name "${DOCUMENT_NAME}" \
      --document-version "${LATEST_VERSION}"

    echo "✓ SSM Document updated successfully to version ${LATEST_VERSION}!"
else
    echo "Document does not exist. Creating new document..."
    aws ssm create-document \
      --name "${DOCUMENT_NAME}" \
      --document-type "Command" \
      --document-format YAML \
      --content "file://${DOCUMENT_FILE}" \
      --tags "Key=Application,Value=OIH" "Key=Purpose,Value=HA-DR-Testing"

    echo "✓ SSM Document created successfully!"
fi

echo ""
echo "To execute the document, run:"
echo "aws ssm send-command \\"
echo "  --document-name \"${DOCUMENT_NAME}\" \\"
echo "  --instance-ids \"i-INSTANCE1\" \"i-INSTANCE2\""
