#!/usr/bin/env bash
set -euo pipefail

# Initial Setup Script - Run this once before deployment
# Usage: ./scripts/setup.sh

echo "========================================="
echo "  AWS Cloud Final - Initial Setup"
echo "========================================="
echo ""

# Check for existing SSH key in configuration first
TFVARS_FILE="terraform.tfvars"
CURRENT_SSH_KEY=""
CURRENT_SSH_KEY_FULL=""

# Check if terraform.tfvars exists and is not empty
if [ -f "$TFVARS_FILE" ] && [ -s "$TFVARS_FILE" ]; then
    # File exists and has content
    if grep -q "^ssh_public_key" "$TFVARS_FILE" 2>/dev/null; then
        CURRENT_SSH_KEY_FULL=$(grep "^ssh_public_key" "$TFVARS_FILE" | sed 's/ssh_public_key = "\(.*\)"/\1/')
        if [ -n "$CURRENT_SSH_KEY_FULL" ]; then
            CURRENT_SSH_KEY=$(echo "$CURRENT_SSH_KEY_FULL" | cut -c 1-60)
        fi
    fi
fi

# If not found in tfvars, check variables.tf
if [ -z "$CURRENT_SSH_KEY_FULL" ] && [ -f "variables.tf" ]; then
    CURRENT_SSH_KEY_FULL=$(grep -A 1 'variable "ssh_public_key"' variables.tf 2>/dev/null | grep 'default' | sed 's/.*default.*=.*"\(.*\)".*/\1/' || echo "")
    if [ -n "$CURRENT_SSH_KEY_FULL" ]; then
        CURRENT_SSH_KEY=$(echo "$CURRENT_SSH_KEY_FULL" | cut -c 1-60)
    fi
fi

# If SSH key exists in config, ask if they want to use it
if [ -n "$CURRENT_SSH_KEY_FULL" ]; then
    echo "🔍 Found existing SSH key in configuration:"
    echo "   ${CURRENT_SSH_KEY}..."
    echo ""
    read -p "Do you want to keep using this SSH key? (yes/no): " KEEP_CURRENT
    
    if [ "$KEEP_CURRENT" = "yes" ]; then
        SSH_PUBLIC_KEY="$CURRENT_SSH_KEY_FULL"
        # Extract SSH key name from terraform.tfvars if it exists
        if grep -q "^ssh_key_name" "$TFVARS_FILE" 2>/dev/null; then
            SSH_KEY_FILENAME=$(grep "^ssh_key_name" "$TFVARS_FILE" | cut -d'"' -f2)
            SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_FILENAME"
        else
            # Default if not found
            DEFAULT_SSH_KEY=$(grep -A 3 'variable "ssh_key_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "aws-key")
            SSH_KEY_PATH="$HOME/.ssh/$DEFAULT_SSH_KEY"
        fi
        echo "✅ Using existing SSH key from configuration"
        SKIP_SSH_SELECTION=true
    else
        echo ""
        echo "🔍 Checking for SSH keys in ~/.ssh..."
        SKIP_SSH_SELECTION=false
    fi
else
    echo "🔍 Checking for existing SSH keys..."
    SKIP_SSH_SELECTION=false
fi

# Only scan for keys if user didn't keep the current one
if [ "$SKIP_SSH_SELECTION" != "true" ]; then
    echo ""
    EXISTING_KEYS=()
    SSH_DIR="$HOME/.ssh"

    if [ -d "$SSH_DIR" ]; then
        # Find all SSH private keys (files with corresponding .pub files)
        while IFS= read -r key; do
            if [ -f "${key}.pub" ]; then
                EXISTING_KEYS+=("$key")
            fi
        done < <(find "$SSH_DIR" -type f \( -name "id_*" -o -name "*_rsa" -o -name "*-key" \) ! -name "*.pub" 2>/dev/null)
    fi

    # Display existing keys if found
    if [ ${#EXISTING_KEYS[@]} -gt 0 ]; then
        echo "✅ Found existing SSH key(s) in ~/.ssh:"
        for i in "${!EXISTING_KEYS[@]}"; do
            echo "   [$((i+1))] ${EXISTING_KEYS[$i]}"
        done
        echo ""
        
        read -p "Do you want to use one of these keys? (yes/no): " USE_EXISTING
        
        if [ "$USE_EXISTING" = "yes" ]; then
            if [ ${#EXISTING_KEYS[@]} -eq 1 ]; then
                SSH_KEY_PATH="${EXISTING_KEYS[0]}"
                echo "✅ Using: $SSH_KEY_PATH"
            else
                echo ""
                read -p "Enter the number of the key to use [1-${#EXISTING_KEYS[@]}]: " KEY_NUM
                
                if [[ "$KEY_NUM" =~ ^[0-9]+$ ]] && [ "$KEY_NUM" -ge 1 ] && [ "$KEY_NUM" -le ${#EXISTING_KEYS[@]} ]; then
                    SSH_KEY_PATH="${EXISTING_KEYS[$((KEY_NUM-1))]}"
                    echo "✅ Using: $SSH_KEY_PATH"
                else
                    echo "❌ Invalid selection"
                    exit 1
                fi
            fi
        else
            echo ""
            read -p "Do you want to (1) specify a different key path or (2) create a new key? [1/2]: " CHOICE
            
            if [ "$CHOICE" = "1" ]; then
                # Specify custom path
                echo ""
                read -p "Enter the path to your SSH private key: " SSH_KEY_PATH
                SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"
                
                if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "${SSH_KEY_PATH}.pub" ]; then
                    echo "❌ SSH key or public key not found at: $SSH_KEY_PATH"
                    exit 1
                fi
                echo "✅ Using: $SSH_KEY_PATH"
            else
                # Create new key
                echo ""
                # Get default from variables.tf
                DEFAULT_KEY_NAME=$(grep -A 3 'variable "ssh_key_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "aws-key")
                read -p "Enter a name for your new SSH key [default: $DEFAULT_KEY_NAME]: " KEY_NAME
                KEY_NAME=${KEY_NAME:-$DEFAULT_KEY_NAME}
                
                SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"
                
                if [ -f "$SSH_KEY_PATH" ]; then
                    echo "⚠️  SSH key already exists at: $SSH_KEY_PATH"
                    read -p "Do you want to overwrite it? (yes/no): " OVERWRITE
                    
                    if [ "$OVERWRITE" != "yes" ]; then
                        echo "❌ Setup cancelled."
                        exit 0
                    fi
                fi
                
                echo "🔑 Generating SSH key..."
                mkdir -p "$HOME/.ssh"
                ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "aws-$KEY_NAME"
                echo "✅ SSH key generated at: $SSH_KEY_PATH"
            fi
        fi
    else
        # No existing keys found
        echo "ℹ️  No existing SSH keys found in $SSH_DIR"
        echo ""
        read -p "Do you want to (1) specify a key path or (2) create a new key? [1/2]: " CHOICE
        
        if [ "$CHOICE" = "1" ]; then
            # Specify custom path
            echo ""
            read -p "Enter the path to your SSH private key: " SSH_KEY_PATH
            SSH_KEY_PATH="${SSH_KEY_PATH/#\~/$HOME}"
            
            if [ ! -f "$SSH_KEY_PATH" ] || [ ! -f "${SSH_KEY_PATH}.pub" ]; then
                echo "❌ SSH key or public key not found at: $SSH_KEY_PATH"
                exit 1
            fi
            echo "✅ Using: $SSH_KEY_PATH"
        else
            # Create new key
            echo ""
            # Get default from variables.tf
            DEFAULT_KEY_NAME=$(grep -A 3 'variable "ssh_key_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "aws-key")
            read -p "Enter a name for your new SSH key [default: $DEFAULT_KEY_NAME]: " KEY_NAME
            KEY_NAME=${KEY_NAME:-$DEFAULT_KEY_NAME}
            
            SSH_KEY_PATH="$HOME/.ssh/$KEY_NAME"
            
            if [ -f "$SSH_KEY_PATH" ]; then
                echo "⚠️  SSH key already exists at: $SSH_KEY_PATH"
                read -p "Do you want to overwrite it? (yes/no): " OVERWRITE
                
                if [ "$OVERWRITE" != "yes" ]; then
                    echo "❌ Setup cancelled."
                    exit 0
                fi
            fi
            
            echo "🔑 Generating SSH key..."
            mkdir -p "$HOME/.ssh"
            ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N "" -C "aws-$KEY_NAME"
            echo "✅ SSH key generated at: $SSH_KEY_PATH"
        fi
    fi
    
    echo ""
    echo "📋 Your SSH public key:"
    echo "========================================="
    cat "${SSH_KEY_PATH}.pub"
    echo "========================================="
    echo ""
    
    # Get the public key
    SSH_PUBLIC_KEY=$(cat "${SSH_KEY_PATH}.pub")
fi

# Check if terraform.tfvars exists
TFVARS_FILE="terraform.tfvars"

if [ ! -f "$TFVARS_FILE" ]; then
    echo "📝 Creating terraform.tfvars for secure configuration..."
    # Extract default values from variables.tf (source of truth)
    DEFAULT_PROJECT=$(grep -A 3 'variable "project_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "cloudfinal")
    DEFAULT_DB_NAME=$(grep -A 3 'variable "db_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "webapp_db")
    DEFAULT_DB_USER=$(grep -A 3 'variable "db_username"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "admin")
    DEFAULT_DB_TABLE=$(grep -A 3 'variable "db_table_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "users")
    # Extract SSH key name from the selected SSH key path
    SSH_KEY_FILENAME=$(basename "$SSH_KEY_PATH")
    
    # Extract SSH key name from the selected SSH key path
    SSH_KEY_FILENAME=$(basename "$SSH_KEY_PATH")
    
    cat > "$TFVARS_FILE" << EOF
# ============================================
# PROJECT CONFIGURATION
# ============================================
project_name = "$DEFAULT_PROJECT"

# ============================================
# SSH CONFIGURATION
# ============================================
ssh_key_name   = "$SSH_KEY_FILENAME"
ssh_public_key = "$SSH_PUBLIC_KEY"

# ============================================
# DATABASE CONFIGURATION
# ============================================
db_name       = "$DEFAULT_DB_NAME"
db_username   = "$DEFAULT_DB_USER"
db_password   = "ChangeMe123!SecurePassword"
db_table_name = "$DEFAULT_DB_TABLE"
# ============================================
EOF
    echo "✅ Created terraform.tfvars with your SSH key"
else
    echo "📝 Updating terraform.tfvars with your SSH key..."
    
    # Extract SSH key name from the key path (if set)
    if [ -n "$SSH_KEY_PATH" ]; then
        SSH_KEY_FILENAME=$(basename "$SSH_KEY_PATH")
    else
        # If SSH_KEY_PATH not set (keeping existing), extract from terraform.tfvars
        DEFAULT_KEY_NAME=$(grep -A 3 'variable "ssh_key_name"' variables.tf 2>/dev/null | grep 'default' | cut -d'"' -f2 || echo "aws-key")
        SSH_KEY_FILENAME=$(grep "^ssh_key_name" "$TFVARS_FILE" 2>/dev/null | cut -d'"' -f2 || echo "$DEFAULT_KEY_NAME")
    fi
    
    # Check if ssh_public_key already exists in the file
    if grep -q "^ssh_public_key" "$TFVARS_FILE"; then
        # Update existing entry
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^ssh_public_key.*|ssh_public_key = \"$SSH_PUBLIC_KEY\"|" "$TFVARS_FILE"
        else
            sed -i "s|^ssh_public_key.*|ssh_public_key = \"$SSH_PUBLIC_KEY\"|" "$TFVARS_FILE"
        fi
    else
        # Add new entry
        echo "" >> "$TFVARS_FILE"
        echo "# SSH Configuration" >> "$TFVARS_FILE"
        echo "ssh_public_key = \"$SSH_PUBLIC_KEY\"" >> "$TFVARS_FILE"
    fi
    
    # Also update/add ssh_key_name
    if grep -q "^ssh_key_name" "$TFVARS_FILE"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|^ssh_key_name.*|ssh_key_name = \"$SSH_KEY_FILENAME\"|" "$TFVARS_FILE"
        else
            sed -i "s|^ssh_key_name.*|ssh_key_name = \"$SSH_KEY_FILENAME\"|" "$TFVARS_FILE"
        fi
    else
        # Add ssh_key_name before ssh_public_key if it doesn't exist
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^ssh_public_key/i\\
ssh_key_name   = \"$SSH_KEY_FILENAME\"
" "$TFVARS_FILE"
        else
            sed -i "/^ssh_public_key/i ssh_key_name   = \"$SSH_KEY_FILENAME\"" "$TFVARS_FILE"
        fi
    fi
    
    echo "✅ SSH key added to terraform.tfvars"
fi
echo ""

# Get current database password from terraform.tfvars (local config)
CURRENT_DB_PASSWORD=""
if [ -f "$TFVARS_FILE" ] && [ -s "$TFVARS_FILE" ]; then
    if grep -q "^db_password" "$TFVARS_FILE" 2>/dev/null; then
        CURRENT_DB_PASSWORD=$(grep "^db_password" "$TFVARS_FILE" | sed 's/.*"\(.*\)".*/\1/' || echo "")
    fi
fi

# If not found, use a strong default (variables.tf has empty default for security)
if [ -z "$CURRENT_DB_PASSWORD" ]; then
    CURRENT_DB_PASSWORD="ChangeMe123!SecurePassword"
fi

# Get current SSH key for display (check tfvars first, then variables.tf)
DISPLAY_SSH_KEY=""
if [ -f "$TFVARS_FILE" ] && [ -s "$TFVARS_FILE" ]; then
    if grep -q "^ssh_public_key" "$TFVARS_FILE" 2>/dev/null; then
        DISPLAY_SSH_KEY=$(grep "^ssh_public_key" "$TFVARS_FILE" | sed 's/.*"\(.*\)".*/\1/' | cut -c 1-50 || echo "")
    fi
fi

if [ -z "$DISPLAY_SSH_KEY" ] && [ -f "variables.tf" ]; then
    DISPLAY_SSH_KEY=$(grep -A 3 'variable "ssh_public_key"' variables.tf 2>/dev/null | grep 'default' | sed 's/.*"\(.*\)".*/\1/' | cut -c 1-50 || echo "")
fi

# Show current configuration
if [ -n "$DISPLAY_SSH_KEY" ]; then
    echo "ℹ️  Current SSH key in config: ${DISPLAY_SSH_KEY}..."
fi

# Prompt for database password
echo ""
echo "🔐 Database Password Setup"
echo "Current password: $CURRENT_DB_PASSWORD"
echo ""
read -p "Do you want to change the database password? (yes/no): " CHANGE_PASSWORD

if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo ""
    read -sp "Enter new database password (min 8 characters): " DB_PASSWORD
    echo ""
    read -sp "Confirm password: " DB_PASSWORD_CONFIRM
    echo ""
    
    if [ "$DB_PASSWORD" != "$DB_PASSWORD_CONFIRM" ]; then
        echo "❌ Passwords don't match!"
        exit 1
    fi
    
    if [ ${#DB_PASSWORD} -lt 8 ]; then
        echo "❌ Password must be at least 8 characters!"
        exit 1
    fi
else
    # Use default password
    DB_PASSWORD="$CURRENT_DB_PASSWORD"
fi

# Update password in terraform.tfvars (always, whether changed or default)
if grep -q "^db_password" "$TFVARS_FILE"; then
    # Update existing entry
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^db_password.*|db_password = \"$DB_PASSWORD\"|" "$TFVARS_FILE"
    else
        sed -i "s|^db_password.*|db_password = \"$DB_PASSWORD\"|" "$TFVARS_FILE"
    fi
else
    # Add new entry
    echo "" >> "$TFVARS_FILE"
    echo "# Database Configuration" >> "$TFVARS_FILE"
    echo "db_password = \"$DB_PASSWORD\"" >> "$TFVARS_FILE"
fi

if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo "✅ Database password updated in terraform.tfvars!"
else
    echo "✅ Default password added to terraform.tfvars!"
fi

echo ""
echo "========================================="
echo "  ✅ Setup Complete!"
echo "========================================="
echo ""
echo "📝 Configuration Summary:"
if [ -n "$SSH_KEY_PATH" ]; then
    echo "  - SSH Key: $SSH_KEY_PATH"
else
    echo "  - SSH Key: Existing key from configuration"
fi
echo "  - Configuration saved to: terraform.tfvars"
if [ "$CHANGE_PASSWORD" = "yes" ]; then
    echo "  - Database password: Custom (updated)"
else
    echo "  - Database password: $CURRENT_DB_PASSWORD (default - CHANGE THIS!)"
fi
echo ""
echo "🔒 Security Note:"
echo "  - terraform.tfvars is in .gitignore (won't be committed)"
echo "  - Your sensitive data stays on your machine only"
echo ""
echo "🚀 Next step: Deploy your infrastructure"
echo "   ./scripts/deploy.sh"
echo ""
