# ---------------------------------------------------------------------------
# Data sources — reuse the default VPC and its subnets
# ---------------------------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---------------------------------------------------------------------------
# AMI — Ubuntu 22.04 LTS (latest)
# ---------------------------------------------------------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------------------------
# Key pair
# ---------------------------------------------------------------------------
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-keypair"
  public_key = var.ssh_public_key

  tags = {
    Name      = "${var.project_name}-keypair"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# ---------------------------------------------------------------------------
# Security group — allow SSH (22), HTTP (80), HTTPS (443)
# ---------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, HTTP, HTTPS"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-sg"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# ---------------------------------------------------------------------------
# EC2 instance
# ---------------------------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true
  }

  tags = {
    Name      = "${var.project_name}-web"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}

# ---------------------------------------------------------------------------
# Elastic IP — stable public address that survives stop/start
# ---------------------------------------------------------------------------
resource "aws_eip" "web" {
  instance = aws_instance.web.id
  domain   = "vpc"

  tags = {
    Name      = "${var.project_name}-eip"
    Project   = var.project_name
    ManagedBy = "udap"
  }
}
