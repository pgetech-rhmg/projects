#!/bin/bash

# TERRAFORM VERSION
# Do not run this script as part of a CloudFormation run. It doesn't work with cfn!

#   This script will identify the env tags that do not have cloud formation
# stacks at the matching commits. Then stand up the database portion of the
# stack. Then it outputs the CFN stack names as a json artifact for the next
# step to pick up

#   This file will be executed by the build step of the base pipeline. The
# execution context for this file is within a git repo that has been fully
# cloned.

# TODO:
# The git blame for this will say it's me, but get ready for another Chris Reed original:
# If we find stacks with different commits for the same tag name, delete the old ones… except prod

case "$SWAP_ENV" in
  swapdev)
    NODE_ENV="dev"
    SHORT_ENV="dev"
    SECRET_ARN="arn:aws:secretsmanager:us-west-2:990878119577:secret:swap-pass-R898rE"
    PIPELINE_STACK_NAME="dev-tag-deployment-stack-seed-upload-sg"
    ENVIRONMENT_TAGS=$(git tag | grep "env-" | grep -v "prod")
    ;;
  swapqa)
    NODE_ENV="qa"
    SHORT_ENV="qa"
    SECRET_ARN="arn:aws:secretsmanager:us-west-2:925741509387:secret:swapqa-pass-plaintext-JNToHv"
    PIPELINE_STACK_NAME="qa-tag-deployment-stack-seed-upload-sg"
    ENVIRONMENT_TAGS=$(git tag | grep "env-" | grep -v "prod")
    ;;
  swapprd)
    NODE_ENV="production"
    SHORT_ENV="prod"
    SECRET_ARN="arn:aws:secretsmanager:us-west-2:925741509387:secret:swapprd-pass-plaintext-Eowywx"
    PIPELINE_STACK_NAME="prod-tag-deployment-stack-seed-upload-sg"
    ENVIRONMENT_TAGS=$(git tag | grep "env-prod-")
    ;;
esac

echo "NODE_ENV is $NODE_ENV"
echo "SHORT_ENV is $SHORT_ENV"
echo "SECRET_ARN is $SECRET_ARN"
echo "PIPELINE_STACK_NAME is $PIPELINE_STACK_NAME"
echo "ENVIRONMENT_TAGS is $ENVIRONMENT_TAGS"
echo $(git tag)

# IDK I'm bad at bash. I should have used hash maps for all these strings. Maybe this should just be a js function
REPO_NAME=$(git config --get remote.origin.url | sed -e "s/https:\/\/github.com\/PGEDigitalCatalyst\///g" -e "s/.git//g")
CFN_NAMES=$(for TAG in $ENVIRONMENT_TAGS; do echo "cfn-$REPO_NAME-tag-$TAG-commit-$(git rev-list -n1 $TAG)-stack"; done)
# STACK_IDS=()
echo "CFN_NAMES is $CFN_NAMES"
