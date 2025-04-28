variable "vpc_id" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" {type = list(string)}

# variable "certificate_arn" {
#   description = "ACM SSL Certificate ARN for HTTPS listener"
#   type        = string
# }
