# Web Server (Bastion + Launch Template) Module

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key

  tags = {
    Name = var.ssh_key_name
  }
}

# Launch Template for Web Servers
resource "aws_launch_template" "web" {
  name_prefix   = "${var.project_name}-web-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.main.key_name

  vpc_security_group_ids = [var.web_sg_id]

  # Allow metadata service access
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional" # Allow both IMDSv1 and IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  user_data = base64encode(templatefile("${path.root}/user-data.sh", {
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    table_name  = var.db_table_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-web-server"
    }
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t2.micro"
  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql
              EOF

  tags = {
    Name = "${var.project_name}-bastion"
  }
}
