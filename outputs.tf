output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "load_balancer_dns" {
  description = "Load balancer DNS name"
  value       = module.alb.alb_dns_name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.database.db_endpoint
}

output "bastion_public_ip" {
  description = "Bastion public IP"
  value       = module.web.bastion_public_ip
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = module.asg.asg_name
}

output "ssh_command_bastion" {
  description = "SSH command for bastion"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name} ec2-user@${module.web.bastion_public_ip}"
}

output "ssh_key_name" {
  description = "SSH key name"
  value       = var.ssh_key_name
}

output "db_name" {
  description = "Database name"
  value       = var.db_name
}

output "db_username" {
  description = "Database username"
  value       = var.db_username
  sensitive   = true
}

output "db_password" {
  description = "Database password"
  value       = var.db_password
  sensitive   = true
}

output "db_table_name" {
  description = "Database table name"
  value       = var.db_table_name
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}
