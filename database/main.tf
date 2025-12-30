# Database Module - RDS MySQL

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql" {
  identifier             = "${var.project_name}-mysql-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.database_sg_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  tags = {
    Name = "${var.project_name}-mysql-db"
  }
}
