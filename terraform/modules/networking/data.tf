data "aws_region" "current" {
  name = "us-east-1"
}

data "aws_caller_identity" "current" {}