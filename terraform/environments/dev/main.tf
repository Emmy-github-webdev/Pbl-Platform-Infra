module "tags" {
  source          = "../modules/terraform-tags"
  project_name    = var.project
  env_name        = var.environment
  region_name     = var.region
}