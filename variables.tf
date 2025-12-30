# ============================================
# TERRAFORM VARIABLES
# ============================================
# These are DEFAULT values that work out of the box.
#
# 🔒 SECURITY: For sensitive data (passwords, keys), create a terraform.tfvars file
# to override these defaults. The terraform.tfvars file is excluded from git.
#
# Example terraform.tfvars:
#   db_password = "YourSecurePassword123!"
#   db_username = "admin"
#   ssh_public_key = "ssh-rsa AAAA...your-key..."
#
# Values in terraform.tfvars will OVERRIDE the defaults below.
# ============================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "heracleo"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "192.168.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 (application)"
  type        = string
  default     = "192.168.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 (application)"
  type        = string
  default     = "192.168.4.0/24"
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for private subnet 3 (database)"
  type        = string
  default     = "192.168.5.0/24"
}

variable "private_subnet_4_cidr" {
  description = "CIDR block for private subnet 4 (database)"
  type        = string
  default     = "192.168.6.0/24"
}

# ============================================
# DATABASE CONFIGURATION
# ============================================
# SECURITY: Override these in terraform.tfvars (not committed to git)
# Example terraform.tfvars:
#   db_password = "YourSecurePassword123!"
#   db_username = "admin"
#   db_name = "webapp_db"
#   db_table_name = "users"
# ============================================

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "webapp_db"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password (MUST be at least 8 characters)"
  type        = string
  sensitive   = true
  default     = "" # SECURITY: Create terraform.tfvars with your actual password
  # This keeps sensitive data out of version control
}

variable "db_table_name" {
  description = "Database table name"
  type        = string
  default     = "users"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t2.micro"
}

# ============================================
# SSH CONFIGURATION
# ============================================
# SECURITY: Override in terraform.tfvars with your actual public key
# Example:
#   ssh_public_key = "ssh-rsa AAAA...your-key..."
# ============================================

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = "ssh-rsa AAAA...your-key..." # SECURITY: setup.sh will update this, or override in terraform.tfvars
}

variable "ssh_key_name" {
  description = "Name of the SSH key file (without path, e.g., 'myproject-key')"
  type        = string
  default     = "aws-key"
}

# ============================================
# AUTO SCALING CONFIGURATION
# ============================================

variable "asg_min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 6
}
