# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "eu-west-s3-bucket"
    key    = "pbl-platform-infra/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
