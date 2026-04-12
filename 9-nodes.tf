data "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-nodes"
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general"
  node_role_arn   = data.aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }
}
