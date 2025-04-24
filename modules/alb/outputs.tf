output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb_sg.id
}
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}