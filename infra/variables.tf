variable "project_name" {
  description = "Project name — used as resource prefix and tag"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key" {
  description = "SSH public key material for the EC2 key pair"
  type        = string
}
