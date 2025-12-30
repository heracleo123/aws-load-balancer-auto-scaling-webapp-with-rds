variable "project_name" {
  description = "Project name"
  type        = string
}

variable "db_subnet_ids" {
  description = "Database subnet IDs"
  type        = list(string)
}

variable "database_sg_id" {
  description = "Database security group ID"
  type        = string
}

variable "instance_class" {
  description = "RDS instance class"
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
