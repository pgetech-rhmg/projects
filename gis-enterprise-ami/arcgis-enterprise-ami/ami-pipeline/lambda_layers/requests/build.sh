#!/bin/bash
set -e

echo "Building the requests layer for AWS Lambda (prepare python/ directory)..."

# Clean and recreate the 'python' directory
rm -rf python
mkdir -p python

# Use pip to install dependencies into the layer directory
python3 -m pip install -r requirements.txt -t python

# Remove __pycache__ directories to shrink package
find python -type d -name "__pycache__" -exec rm -rf {} + || true

# Leave the 'python' directory in place for the terraform module to archive
echo "Layer content prepared in python/ directory. The terraform module will create the zip."

