# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "my-fullstack-tfstate"
    key    = "pbl-platform-infra/dev/terraform.tfstate"
    region = "us-east-1"
  }
}
