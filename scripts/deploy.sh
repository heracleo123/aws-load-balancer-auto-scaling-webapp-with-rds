#!/usr/bin/env bash
set -euo pipefail

# Deploy AWS Infrastructure
# Usage: ./scripts/deploy.sh

echo "========================================="
echo "  AWS Cloud Final - Terraform Deploy"
echo "========================================="
echo ""

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install it first:"
    echo "   brew install terraform"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "⚠️  AWS CLI is not installed. Install for better management:"
    echo "   brew install awscli"
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Format Terraform files
echo "🎨 Formatting Terraform files..."
terraform fmt -recursive

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

if [ $? -ne 0 ]; then
    echo "❌ Validation failed. Please fix errors above."
    exit 1
fi

# Create plan
echo ""
echo "📋 Creating deployment plan..."
# Get project name from terraform for dynamic plan filename
PROJECT_NAME=$(grep '^project_name' terraform.tfvars 2>/dev/null | cut -d'"' -f2 || echo "terraform")
PLAN_FILE="${PROJECT_NAME}.plan"
terraform plan -out="${PLAN_FILE}"

# Ask for confirmation
echo ""
read -p "Do you want to apply this plan? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Deployment cancelled."
    rm -f "${PLAN_FILE}"
    exit 0
fi

# Apply plan
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply "${PLAN_FILE}"

# Clean up plan file
rm -f "${PLAN_FILE}"

# Show outputs
echo ""
echo "========================================="
echo "  ✅ Deployment Complete!"
echo "========================================="
echo ""

# Wait for instances to be ready
echo "⏳ Waiting 30 seconds for instances to initialize..."
sleep 30

# Setup database table automatically
echo ""
echo "🗄️  Setting up database table..."
./scripts/helper/setup-db.sh

echo ""
terraform output

echo ""
echo "📝 All Done! Your infrastructure is ready."
echo "   Open the load_balancer_url in your browser"
echo ""
