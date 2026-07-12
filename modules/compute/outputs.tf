output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app.id
}

output "public_ip" {
  description = "Public IP of the instance"
  value       = aws_instance.app.public_ip
}

output "ami_id" {
  description = "AMI the instance was launched from"
  value       = data.aws_ami.ubuntu.id
}
