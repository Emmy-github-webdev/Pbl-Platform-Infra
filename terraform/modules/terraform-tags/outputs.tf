output "common_tags" {
  value = {
    Project     = var.project_name
    Environment = var.env_name
    Region      = var.region_name
  }
}