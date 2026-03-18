variable "region" {
  type = string
  description = "The AWS region where resources will be deployed in dev"
  default = "us-east-1"
}

variable "project" {
  type = string
  description = "The project name"
  default = "pbl-platform"
}

variable "environment" {
  type = string
  description = "The Dev environment"
  default = "dev"
}