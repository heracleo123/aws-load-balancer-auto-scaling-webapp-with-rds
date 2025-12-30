#!/usr/bin/env bash
set -euo pipefail

# Destroy AWS Infrastructure
# Usage: ./scripts/destroy.sh

echo "========================================="
echo "  AWS Cloud Final - Terraform Destroy"
echo "========================================="
echo ""

echo "⚠️  WARNING: This will destroy all infrastructure!"
echo ""
read -p "Are you sure you want to destroy everything? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Destroy cancelled."
    exit 0
fi

echo ""
read -p "Type 'destroy' to confirm: " CONFIRM2

if [ "$CONFIRM2" != "destroy" ]; then
    echo "❌ Destroy cancelled."
    exit 0
fi

echo ""
echo "🗑️  Destroying infrastructure..."
terraform destroy -auto-approve

echo ""
echo "✅ Infrastructure destroyed successfully!"
echo ""
