#!/usr/bin/env bash
set -euo pipefail

# Plan AWS Infrastructure changes
# Usage: ./scripts/plan.sh

echo "========================================="
echo "  AWS Cloud Final - Terraform Plan"
echo "========================================="
echo ""

# Initialize if needed
if [ ! -d ".terraform" ]; then
    echo "📦 Initializing Terraform..."
    terraform init
fi

# Format and validate
echo "🎨 Formatting Terraform files..."
terraform fmt -recursive

echo "✅ Validating Terraform configuration..."
terraform validate

# Create plan
echo ""
echo "📋 Creating plan..."
terraform plan

echo ""
echo "💡 To apply these changes, run: ./scripts/deploy.sh"
echo ""
