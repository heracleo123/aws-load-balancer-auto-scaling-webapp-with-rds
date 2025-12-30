terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Network Layer - VPC, Subnets, NAT Gateways, Routes
module "network" {
  source = "./network"

  project_name          = var.project_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_1_cidr  = var.public_subnet_1_cidr
  public_subnet_2_cidr  = var.public_subnet_2_cidr
  private_subnet_1_cidr = var.private_subnet_1_cidr
  private_subnet_2_cidr = var.private_subnet_2_cidr
  private_subnet_3_cidr = var.private_subnet_3_cidr
  private_subnet_4_cidr = var.private_subnet_4_cidr
  availability_zones    = data.aws_availability_zones.available.names
}

# Security Layer - Security Groups
module "security" {
  source = "./security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
}

# Database Layer - RDS MySQL
module "database" {
  source = "./database"

  project_name   = var.project_name
  db_subnet_ids  = [module.network.private_subnet_3_id, module.network.private_subnet_4_id]
  database_sg_id = module.security.database_sg_id
  instance_class = var.db_instance_class
  db_name        = var.db_name
  db_username    = var.db_username
  db_password    = var.db_password
}

# ALB Layer - Application Load Balancer
module "alb" {
  source = "./alb"

  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = [module.network.public_subnet_1_id, module.network.public_subnet_2_id]
  alb_sg_id         = module.security.alb_sg_id
}

# Web Layer - Launch Template and Bastion
module "web" {
  source = "./web"

  project_name      = var.project_name
  instance_type     = var.instance_type
  ssh_public_key    = var.ssh_public_key
  ssh_key_name      = var.ssh_key_name
  web_sg_id         = module.security.web_sg_id
  bastion_sg_id     = module.security.bastion_sg_id
  bastion_subnet_id = module.network.public_subnet_1_id
  db_endpoint       = module.database.db_address
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_table_name     = var.db_table_name
}

# ASG Layer - Auto Scaling Group
module "asg" {
  source = "./asg"

  project_name       = var.project_name
  launch_template_id = module.web.launch_template_id
  private_subnet_ids = [module.network.private_subnet_1_id, module.network.private_subnet_2_id]
  target_group_arn   = module.alb.target_group_arn
  min_size           = var.asg_min_size
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
}
