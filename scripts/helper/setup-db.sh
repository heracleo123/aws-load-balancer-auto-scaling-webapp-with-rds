#!/usr/bin/env bash
set -euo pipefail

# Setup database on RDS instance - RUN ONCE after deployment
# Usage: ./scripts/helper/setup-db.sh

echo "========================================="
echo "  Database Setup Script"
echo "========================================="
echo ""

# Get configuration from Terraform outputs
RDS_ENDPOINT=$(terraform output -raw rds_endpoint 2>/dev/null | cut -d: -f1)
BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)
DB_NAME=$(terraform output -raw db_name 2>/dev/null)
DB_USER=$(terraform output -raw db_username 2>/dev/null)
DB_PASS=$(terraform output -raw db_password 2>/dev/null)
DB_TABLE=$(terraform output -raw db_table_name 2>/dev/null)
SSH_KEY_NAME=$(terraform output -raw ssh_key_name 2>/dev/null)
SSH_KEY="${HOME}/.ssh/${SSH_KEY_NAME}"
if [ -z "$RDS_ENDPOINT" ] || [ -z "$BASTION_IP" ] || [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_TABLE" ] || [ -z "$SSH_KEY_NAME" ]; then
    echo "❌ Could not get outputs. Make sure infrastructure is deployed."
    echo "   Run: terraform output"
    exit 1
fi

echo "RDS Endpoint: $RDS_ENDPOINT"
echo "Bastion IP: $BASTION_IP"
echo "Database: $DB_NAME"
echo "Table: $DB_TABLE"
echo ""
echo "Setting up SSH key on bastion..."

# Copy private key to bastion for accessing other instances
scp -o StrictHostKeyChecking=no -i $SSH_KEY $SSH_KEY ec2-user@$BASTION_IP:/home/ec2-user/.ssh/$SSH_KEY_NAME
ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$BASTION_IP "chmod 600 /home/ec2-user/.ssh/$SSH_KEY_NAME"

echo "✅ SSH key configured on bastion"
echo ""
echo "Creating database table via bastion host..."
echo ""

# SSH to bastion and create table
ssh -o StrictHostKeyChecking=no -i $SSH_KEY ec2-user@$BASTION_IP << ENDSSH

# Install MySQL client if not present
sudo yum install -y mariadb105 2>/dev/null || echo "MariaDB client already installed"

# Create the table
mysql -h $RDS_ENDPOINT -u $DB_USER -p'$DB_PASS' $DB_NAME << 'EOSQL'
CREATE TABLE IF NOT EXISTS $DB_TABLE (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO $DB_TABLE (name, email) VALUES 
    ('user', 'user@example.com')
ON DUPLICATE KEY UPDATE name=name;

SELECT COUNT(*) as total_rows FROM $DB_TABLE;
EOSQL

echo ""
echo "✅ Database table created successfully!"
ENDSSH

echo "📝 SQL script created at /tmp/setup_db.sql"
echo ""
echo "To execute on the database:"
echo ""
echo "1. Copy script to bastion:"
echo "   scp -i ${SSH_KEY} /tmp/setup_db.sql ec2-user@${BASTION_IP}:~/"
echo ""
echo "2. SSH to bastion:"
echo "   ssh -i ${SSH_KEY} ec2-user@${BASTION_IP}"
echo ""
echo "3. Run interactively:"
echo "   mysql -h ${RDS_ENDPOINT} -u ${DB_USER} -p"
echo ""
