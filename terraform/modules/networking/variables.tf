# variable "region" {
#   default = "us-east-1"
# }

variable "vpc_name" {
  type        = string
  description = "VPC name"
}

variable "tags" {
  description = "Global resources"
  type        = string
}

variable "vpc_cidr" {
  description = "The network VPC"
  type        = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}