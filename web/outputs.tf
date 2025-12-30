output "launch_template_id" {
  value = aws_launch_template.web.id
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "key_pair_name" {
  value = aws_key_pair.main.key_name
}
