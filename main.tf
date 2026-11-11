data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# ---------- Security Groups ----------
resource "aws_security_group" "jenkins" {
  name        = "tf-jenkins-sg"
  description = "Jenkins server"
  vpc_id      = data.aws_vpc.default.id
  tags        = { Name = "tf-jenkins-sg" }
}

resource "aws_security_group" "app" {
  name        = "tf-app-sg"
  description = "App server"
  vpc_id      = data.aws_vpc.default.id
  tags        = { Name = "tf-app-sg" }
}

# Jenkins rules
resource "aws_vpc_security_group_ingress_rule" "jenkins_ssh" {
  security_group_id = aws_security_group.jenkins.id
  cidr_ipv4         = var.my_ip
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "jenkins_web" {
  security_group_id = aws_security_group.jenkins.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
}

# App rules
resource "aws_vpc_security_group_ingress_rule" "app_ssh_from_jenkins" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.jenkins.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_http" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# Egress (allow all outbound)
resource "aws_vpc_security_group_egress_rule" "jenkins_all_out" {
  security_group_id = aws_security_group.jenkins.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------- EC2 Instances ----------
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.jenkins_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.jenkins.id]
  user_data                   = file("${path.module}/user_data/jenkins.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = { Name = "tf-jenkins-server" }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.app_instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app.id]
  user_data                   = file("${path.module}/user_data/app.sh")
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = { Name = "tf-app-server" }
}

# ---------- Elastic IPs ----------
resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"
  tags     = { Name = "tf-jenkins-eip" }
}

resource "aws_eip" "app" {
  instance = aws_instance.app.id
  domain   = "vpc"
  tags     = { Name = "tf-app-eip" }
}