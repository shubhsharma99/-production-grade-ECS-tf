output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.this.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of the Bastion Host"
  value       = aws_instance.this.public_dns
}
