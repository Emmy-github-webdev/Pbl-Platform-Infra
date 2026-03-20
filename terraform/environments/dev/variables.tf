variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed in dev"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "The project name"
  default     = "pbl-platform"
}

variable "environment" {
  type        = string
  description = "The Dev environment"
  default     = "dev"
}

variable "instance_capacity_type" {
  description = "Instance capacity type"
  type = string
  default = "ON_DEMAND"
}

variable "instance_types" {
  description = "Instance type"
  type = string
  default = ["m6i.large", "m6i.xlarge"]
}

variable "desired_size" {
  description = "The instance size"
  type = number
  default = 2
}

variable "min_size" {
  description = "The minimum instance size"
  type = number
  default = 1
}

variable "max_size" {
  description = "The minimum instance size"
  type = number
  default = 3
}

variable "ami_type" {
  description = "The AMI type"
  type = string
  default = "AL2_x86_64"
}

variable "disk_size" {
  description = "The size of the disk"
  type = number
  default = 100
}