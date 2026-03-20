variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "The private subnet ids"
  type = list(string)
}

variable "kms_key_arn" {
  description = "KMS key"
  type = string
}

variable "capacity_type" {
  description = "The instance capacity"
  type = string
}

variable "instance_types" {
  description = "The instance type"
  type = list(string)
}

variable "desired_size" {
  description = "The instance size"
  type = number
}

variable "min_size" {
  description = "The minimum instance size"
  type = number
}

variable "max_size" {
  description = "The minimum instance size"
  type = number
}

variable "ami_type" {
  description = "The AMI type"
  type = string
}

variable "disk_size" {
  description = "The size of the disk"
  type = number
}

variable "vpc" {
  description = "The VPC"
  type = string
}

variable "ssh_key_name" {
  type = string
  description = "The SSH Key name"
}