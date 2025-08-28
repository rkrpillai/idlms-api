#!/bin/bash

set -euo pipefail

ACTION="${1:-plan}"

# Load .env file if present
if [ -f "../../.env" ]; then
  echo "Loading environment variables from .env file..."
  export $(grep -v '^#' ../../.env | xargs)
fi

# Required environment variables
REQUIRED_VARS=("TF_BUCKET" "TF_REGION" "ENVIRONMENT")

for VAR in "${REQUIRED_VARS[@]}"; do
  if [ -z "${!VAR:-}" ]; then
    echo "❌ ERROR: Environment variable '$VAR' is not set."
    exit 1
  fi
done

# Paths and filenames
GLOBAL_TFVARS_FILE="../../environments/${ENVIRONMENT}/global.tfvars"
TFVARS_FILE="../../environments/${ENVIRONMENT}/services/ssm.tfvars"
TFSTATE_KEY="${ENVIRONMENT}/ssm/terraform.tfstate"

# Check if tfvars file exists
if [ ! -f "$TFVARS_FILE" ]; then
  echo "❌ ERROR: Variable file '$TFVARS_FILE' not found."
  exit 1
fi

# Check if global tfvars file exists
if [ ! -f "$GLOBAL_TFVARS_FILE" ]; then
  echo "❌ ERROR: Variable file '$GLOBAL_TFVARS_FILE' not found."
  exit 1
fi
# Terraform init
echo "🔧 Initializing Terraform with remote backend..."
terraform init \
  -backend-config="bucket=${TF_BUCKET}" \
  -backend-config="key=${TFSTATE_KEY}" \
  -backend-config="region=${TF_REGION}"

# Terraform apply
case "$ACTION" in 
 plan)
   echo "🧠 Running terraform plan..."
   terraform plan -var-file="$GLOBAL_TFVARS_FILE" -var-file="$TFVARS_FILE"
   ;;
 apply)
  echo "🚀 Running Terraform apply..."
  terraform apply -auto-approve -var-file="$GLOBAL_TFVARS_FILE" -var-file="$TFVARS_FILE"
  ;;
 destroy)  
  echo "💥 Running terraform destroy..."
  terraform destroy -auto-approve -var-file="$GLOBAL_TFVARS_FILE" -var-file="$TFVARS_FILE"
  ;;
 *)
  echo "❌ Unknown action: $ACTION"
  echo "Usage: $0 [plan|apply|destroy]"
  exit 1
  ;;
esac
