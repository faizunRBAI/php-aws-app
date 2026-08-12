output "instance_ip" {
  description = "Public Elastic IP of the EC2 instance"
  value       = aws_eip.web.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}
