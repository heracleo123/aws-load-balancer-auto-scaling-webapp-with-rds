variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "public_subnet_1_cidr" {
  description = "Public subnet 1 CIDR"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "Public subnet 2 CIDR"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "Private subnet 1 CIDR"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2 CIDR"
  type        = string
}

variable "private_subnet_3_cidr" {
  description = "Private subnet 3 CIDR"
  type        = string
}

variable "private_subnet_4_cidr" {
  description = "Private subnet 4 CIDR"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}
