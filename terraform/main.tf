module "vpc" {
  source = "./modules/vpc"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  az_count             = var.az_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "acm" {
  source = "./modules/acm"

  domain_name               = var.domain_name
  subdomain                 = var.subdomain
  ttl                       = var.ttl
  cloudflare_zone_id        = var.cloudflare_zone_id
  zone_name                 = var.zone_name
  manage_validation_records = var.manage_validation_records
}


module "alb" {
  source = "./modules/alb"

  name                = var.name
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  http_listener_port  = var.http_listener_port
  https_listener_port = var.https_listener_port
  certificate_arn     = module.acm.acm_certificate_arn
  container_port      = var.container_port
}

module "iam" {
  source = "./modules/iam"

  aws_region               = var.aws_region
  github_repo              = var.github_repo
  github_actions_role_name = var.github_actions_role_name
  state_bucket_name        = var.state_bucket_name
  lock_table_name          = var.lock_table_name
}

module "ecr" {
  source = "./modules/ecr"

  name = var.name
}

module "ecs" {
  source = "./modules/ecs"

  aws_region            = var.aws_region
  cluster_name          = var.cluster_name
  ecs_launch_type       = var.ecs_launch_type
  desired_count         = var.desired_count
  cpu                   = var.cpu
  memory                = var.memory
  container_port        = var.container_port
  container_name        = var.container_name
  task_family           = var.task_family
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_sg_id
  image_url             = "${module.ecr.repository_url}:${var.image_tag}"
  execution_role_arn    = module.iam.task_execution_role_arn
  execution_role_name   = module.iam.task_execution_role_name
}

data "aws_ssm_parameter" "ecs_secrets" {
  name = "ecs_secrets"
}

module "domain" {
  source = "./modules/domain"

  alb_dns            = module.alb.alb_dns_name
  cloudflare_zone_id = var.cloudflare_zone_id
  subdomain          = var.subdomain
  zone_name          = var.zone_name
}
 