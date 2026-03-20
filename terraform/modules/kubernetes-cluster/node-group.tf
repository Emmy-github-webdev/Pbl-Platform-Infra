resource "aws_eks_node_group" "pbl_nodes" {
  cluster_name    = aws_eks_cluster.pbl_cluster.name
  node_group_name = "${var.tags.project}-${var.tags.environment}-node-group"
  node_role_arn   = aws_iam_role.pbl_nodes_role.arn
  subnet_ids      = "${var.private_subnet_ids}"

  capacity_type  = "${var.capacity_type}"
  instance_types = "${var.instance_types}"

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = var.min_size
  }

  labels = {
    environment = "${var.tags.environment}"
    workload    = "${var.tags.project}"
  }

  taint {
    key    = "environment"
    value  = "${var.tags.environment}"
    effect = "NO_SCHEDULE"
  }

  ami_type       = "${var.ami_type}"
  disk_size      = "${var.disk_size}"

  version = aws_eks_cluster.pbl_cluster.version

  tags = {
    Name        = "${var.tags.project}-${var.tags.environment}-node-group"
    Environment = "${var.tags.environment}"
    Terraform   = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_iam_role" "pbl_nodes_role" {
  name = "${var.tags.project}-${var.tags.environment}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}




resource "aws_iam_role_policy_attachment" "worker_node_policies" {
  role       = aws_iam_role.pbl_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.pbl_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  role       = aws_iam_role.pbl_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}