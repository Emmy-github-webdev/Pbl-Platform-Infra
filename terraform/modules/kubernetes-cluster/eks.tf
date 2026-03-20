resource "aws_eks_cluster" "pbl_cluster" {
  name     = "${var.tags.project}-${var.tags.environment}-eks"
  role_arn = aws_iam_role.cluster_role.arn
  version = "1.29"

  vpc_config {
    subnet_ids              = "${var.private_subnet_ids}"
    endpoint_public_access  = false
    endpoint_private_access = true
  }

  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = var.kms_key_arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = "${var.tags.project}-${var.tags.environment}-eks"
  }
}

# Cluster IAM role
resource "aws_iam_role" "cluster_role" {
  name = "${var.tags.project}-${var.tags.environment}-eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}