# EKS Cluster security group
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.tags.project}-${var.tags.environment}-eks-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc

  # Allow node groups to communicate with cluster API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EKS node group security group
resource "aws_security_group" "eks_nodes_sg" {
  name        = "${var.tags.project}-${var.tags.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc

  # Allow nodes to receive traffic from control plane
  ingress {
    from_port        = 1025
    to_port          = 65535
    protocol         = "tcp"
    security_groups  = [aws_security_group.eks_cluster_sg.id]
  }

  # Allow nodes to communicate with each other
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}