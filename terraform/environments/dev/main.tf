# Tag module
module "tags" {
  source       = "../../modules/terraform-tags"
  project_name = var.project
  env_name     = var.environment
  region_name  = var.region
}

# Network module
module "vpc" {
  vpc_name        = "${var.project}-${var.environment}-vpc"
  vpc_cidr        = "10.0.0.0/16"
  source          = "../../modules/networking"
  tags            = module.tags.common_tags
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
}

# Kubernetes module
module "eks" {
  source = "../../modules/kubernetes-cluster"
  tags = module.tags.common_tags
  private_subnet_ids = module.vpc.private_subnets
  kms_key_arn = module.vpc.kms_key
  capacity_type = var.instance_capacity_type
  instance_types = var.instance_types
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  ami_type = var.ami_type
  disk_size = var.disk_size
  vpc = module.vpc.vpc_id
  ssh_key_name = var.ssh_key
}

# ECR module
module "ecr" {
  source = "../../modules/registry"
  tags = module.tags.common_tags
  vpc = module.vpc.vpc_id
  eks_node_group_role = module.eks.node_group_role
  repository_name = var.repository_name
}