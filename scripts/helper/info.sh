#!/usr/bin/env bash
set -euo pipefail

# Show useful information about the deployment
# Usage: ./scripts/helper/info.sh

echo "========================================="
echo "  AWS Cloud Final - Deployment Info"
echo "========================================="
echo ""

# Check if infrastructure is deployed
if [ ! -f "terraform.tfstate" ] && [ ! -d ".terraform" ]; then
    echo "❌ Infrastructure not deployed yet."
    echo "   Run: ./scripts/deploy.sh"
    exit 1
fi

# Get outputs
echo "📊 Infrastructure Details:"
echo ""
terraform output

echo ""
echo "========================================="
echo "  Quick Commands"
echo "========================================="
echo ""

BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null | cut -d: -f1)
LB_URL=$(terraform output -raw load_balancer_url 2>/dev/null)
ASG_NAME=$(terraform output -raw autoscaling_group_name 2>/dev/null)
SSH_KEY_NAME=$(terraform output -raw ssh_key_name 2>/dev/null)
SSH_KEY="${HOME}/.ssh/${SSH_KEY_NAME}"
DB_USER=$(terraform output -raw db_username 2>/dev/null)

if [ -n "$BASTION_IP" ]; then
    echo "🔐 SSH to Bastion:"
    echo "   ssh -i ${SSH_KEY} ec2-user@${BASTION_IP}"
    echo ""
fi

if [ -n "$RDS_ENDPOINT" ]; then
    echo "💾 Connect to Database (from bastion):"
    echo "   mysql -h ${RDS_ENDPOINT} -u ${DB_USER} -p"
    echo ""
fi

if [ -n "$LB_URL" ]; then
    echo "🌐 Web Application:"
    echo "   ${LB_URL}"
    echo ""
fi

if [ -n "$ASG_NAME" ]; then
    echo "📈 Check Auto Scaling Group:"
    echo "   aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names ${ASG_NAME}"
    echo ""
    
    echo "📋 List Running Instances:"
    echo "   aws ec2 describe-instances --filters \"Name=tag:aws:autoscaling:groupName,Values=${ASG_NAME}\" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIpAddress]' --output table"
    echo ""
fi

echo "🔄 Refresh this info:"
echo "   ./scripts/helper/info.sh"
echo ""
