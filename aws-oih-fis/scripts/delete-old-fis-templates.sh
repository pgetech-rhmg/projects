#!/bin/bash

# Delete old FIS experiment templates that were created via CLI scripts
# Once CloudFormation manages the templates, these manual ones are obsolete

set -e

echo "=========================================="
echo "Deleting Old FIS Experiment Templates"
echo "=========================================="
echo ""

# List all experiment templates
echo "Current FIS experiment templates:"
echo ""
aws fis list-experiment-templates \
    --query 'experimentTemplates[].[id,description,tags.Name]' \
    --output table

echo ""
echo "This will DELETE ALL experiment templates not managed by CloudFormation."
echo ""
read -p "Are you sure you want to delete ALL existing templates? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

# Get all template IDs
TEMPLATE_IDS=$(aws fis list-experiment-templates \
    --query 'experimentTemplates[].id' \
    --output text)

if [ -z "$TEMPLATE_IDS" ]; then
    echo "No templates found to delete."
    exit 0
fi

# Delete each template
for template_id in $TEMPLATE_IDS; do
    echo "Deleting template: ${template_id}..."
    aws fis delete-experiment-template --id "${template_id}" || echo "  Failed to delete ${template_id}"
done

echo ""
echo "=========================================="
echo "✓ Old templates deleted!"
echo "=========================================="
echo ""
echo "Now run ./scripts/update-fis-stack.sh to create new CloudFormation-managed templates."
echo ""
