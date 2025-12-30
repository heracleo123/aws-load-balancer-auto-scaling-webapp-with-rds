variable "project_name" {
  description = "Project name"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key"
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name for AWS key pair"
  type        = string
}

variable "web_sg_id" {
  description = "Web security group ID"
  type        = string
}

variable "bastion_sg_id" {
  description = "Bastion security group ID"
  type        = string
}

variable "bastion_subnet_id" {
  description = "Bastion subnet ID"
  type        = string
}

variable "db_endpoint" {
  description = "Database endpoint"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_table_name" {
  description = "Database table name"
  type        = string
}
