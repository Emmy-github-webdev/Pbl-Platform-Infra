# -------------------
# VPC
# -------------------
resource "aws_vpc" "pbl_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tags.project}-${var.tag.environment}-vpc"
  }
}