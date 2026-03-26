#!/bin/bash
set -euxo pipefail

FUNCTION_NAME="$PROJECT_NAME-$BRANCH"
BUCKET_NAME=$(echo "$FUNCTION_NAME-source" | tr '[:upper:]' '[:lower:]')
SOURCE_NAME="source.zip"

# Discover the Lambda directory with the "Lambda" suffix
LAMBDA_DIR=""
for dir in */; do
	if [[ $dir == *Lambda/ ]]; then
		LAMBDA_DIR="$dir"
		break
	fi
done
if [ -z "$LAMBDA_DIR" ]; then
	echo "Lambda directory not found"
	pwd
	ls -la
	exit 1
fi

echo "Updating Lambda function on $(date)"

(
	cd "$LAMBDA_DIR"
	zip -r "$SOURCE_NAME" .
	aws s3 cp "$SOURCE_NAME" "s3://$BUCKET_NAME/$SOURCE_NAME"
)

PUBLISH_RESPONSE=$(
	aws lambda update-function-code --publish \
		--function-name "$FUNCTION_NAME" \
		--s3-bucket "$BUCKET_NAME" \
		--s3-key "$SOURCE_NAME"
)
FUNCTION_VERSION=$(echo "$PUBLISH_RESPONSE" | jq -r '.Version')

aws lambda update-alias \
	--name "$PROJECT_NAME-latest-$BRANCH" \
	--function-name "$FUNCTION_NAME" \
	--function-version "$FUNCTION_VERSION"

echo "Lambda function updated on $(date)"
