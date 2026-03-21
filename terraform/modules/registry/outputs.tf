output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.pbl_ecr.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.pbl_ecr.arn
}

output "eks_access_policy" {
  description = "ECR EKS Access policy"
  value = aws_ecr_repository_policy.eks_access.id
}
