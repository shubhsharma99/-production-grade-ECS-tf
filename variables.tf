variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "repo_name" {
  description = "ECR repository name"
  type        = string
}

variable "certificate_arn" {
  description = "ACM SSL Certificate ARN for HTTPS listener"
  type        = string
}
