variable "cluster_name" {}
variable "service_name" {}
variable "container_image" {}
variable "vpc_id" {}
variable "private_subnets" { type = list(string) }
variable "target_group_arn" {}
variable "ecs_task_execution_role_arn" {}
variable "alb_sg_id" {}
