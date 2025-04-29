region          = "us-east-1"

vpc_cidr_block  = "10.0.0.0/16"

public_subnets  = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

repo_name       = "my-ecs-app"
certificate_arn = "arn:aws:acm:us-east-1:986129559431:certificate/28d11fcb-b8bc-4d5f-91de-3abd4b600050"
ssh_key_name = "bastion-key"