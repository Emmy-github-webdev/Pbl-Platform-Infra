output "eks_cluster" {
  value = aws_eks_cluster.pbl_cluster.name
}

output "node_group_name" {
  value = aws_eks_node_group.pbl_nodes.id
}

output "node_group_role" {
  value = aws_iam_role.pbl_nodes_role.arn
}