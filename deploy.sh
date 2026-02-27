#!/bin/bash

PROFILE="$AWS_PROFILE"
BUCKET="$DEPLOY_BUCKET"
FILE="audit.yml"

echo "Checking AWS SSO credentials for profile: $PROFILE"

if ! aws sts get-caller-identity --profile "$PROFILE" &>/dev/null; then
  echo "SSO credentials missing or expired. Starting login..."
  aws sso login --profile "$PROFILE"
fi

echo "Uploading $FILE to $BUCKET"
aws s3 cp "$FILE" "$BUCKET" --profile "$PROFILE"
echo "Done."
