resource "aws_ecr_repository" "pbl_ecr" {
  name                 = "${var.tags.project}-${var.tags.environment}/${var.repository_name}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.tags.project}-${var.tags.environment}/${var.repository_name}"
  }
}

# Lifecycle policy (cleanup old images)
resource "aws_ecr_lifecycle_policy" "pbl_ecr_lp" {
  count      = var.lifecycle_policy_enabled ? 1 : 0
  repository = aws_ecr_repository.pbl_ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 images",
        selection = {
          tagStatus     = "any",
          countType     = "imageCountMoreThan",
          countNumber   = 10
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Repository policy for EKS access
resource "aws_ecr_repository_policy" "eks_access" {
  repository = aws_ecr_repository.pbl_ecr.name

  policy = jsonencode({
    Version = "2008-10-17",
    Statement = [
      {
        Sid    = "AllowEKSNodesPull",
        Effect = "Allow",
        Principal = {
          AWS = var.eks_node_group_role
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.vpc
          }
        }
      }
    ]
  })
}