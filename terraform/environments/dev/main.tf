# Tag module
module "tags" {
  source       = "../../modules/terraform-tags"
  project_name = var.project
  env_name     = var.environment
  region_name  = var.region
}

# Network module
# module "vpc" {
#   vpc_name        = "${var.project}-${var.environment}-vpc"
#   vpc_cidr        = "10.0.0.0/16"
#   source          = "../../modules/networking"
#   tags            = module.tags.common_tags
#   azs             = ["us-east-1a", "us-east-1b"]
#   public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
#   private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
# }