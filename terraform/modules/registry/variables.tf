variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "vpc" {
  description = "The VPC"
  type = string
}

variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Whether image tags are mutable or immutable"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "lifecycle_policy_enabled" {
  description = "Enable lifecycle policy"
  type        = bool
  default     = true
}

variable "eks_node_group_role" {
  description = "EKS Node group IAM role"
  type = string
}