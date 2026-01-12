module "vpc" {
  source = "./modules/vpc"

  name                 = var.name
  vpc_cidr             = var.vpc_cidr
  az_count             = var.az_count
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}

module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
  subdomain   = var.subdomain
  ttl         = var.ttl
  zone_id     = var.cloudflare_zone_id
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

  name = var.name
}

module "ecr" {
  source = "./modules/ecr"

  name = var.name
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name          = var.cluster_name
  ecs_launch_type       = var.ecs_launch_type
  desired_count         = var.desired_count
  container_port        = var.container_port
  cpu                   = var.cpu
  memory                = var.memory
  vpc_id                = module.vpc.vpc_id
  image_url             = "${module.ecr.repository_url}:${var.image_tag}"
  http_listener_arn     = module.alb.http_listener_arn
  https_listener_arn    = module.alb.https_listener_arn
  iam_role_arn          = module.iam.task_execution_role_arn
  private_subnet_ids    = module.vpc.private_subnet_ids
  target_group_arn      = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
}

module "domain" {
  source = "./modules/domain"

  alb_dns            = module.alb.alb_dns_name
  cloudflare_zone_id = var.cloudflare_zone_id
  subdomain          = var.subdomain
}
 