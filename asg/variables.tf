variable "project_name" {
  description = "Project name"
  type        = string
}

variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}

variable "min_size" {
  description = "Minimum size"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity"
  type        = number
}

variable "max_size" {
  description = "Maximum size"
  type        = number
}
