module "vpc" {
  source          = "./modules/vpc"
  cidr_block      = var.vpc_cidr_block
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  certificate_arn = var.certificate_arn
}

module "iam" {
  source = "./modules/iam"
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = var.repo_name
}

module "ecs" {
  source                      = "./modules/ecs"
  cluster_name                = "my-cluster"
  service_name                = "my-app"
  alb_sg_id                   = module.alb.alb_sg_id
  container_image             = module.ecr.repository_url
  vpc_id                      = module.vpc.vpc_id
  private_subnets             = module.vpc.private_subnets
  target_group_arn            = module.alb.target_group_arn
  ecs_task_execution_role_arn = module.iam.execution_role_arn

}
