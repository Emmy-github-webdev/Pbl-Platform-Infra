variable "tags" {
  description = "Global resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "The private subnet ids"
  type = string
}

variable "kms_key_arn" {
  description = "KMS key"
  type = string
}

