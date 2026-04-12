############################
# IAM Role for Worker Nodes
############################
data "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-nodes"
}

############################
# GENERAL NODE GROUP
############################
resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general"
  node_role_arn   = data.aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }
}

############################
# SPOT NODE GROUP
############################
resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "spot"
  node_role_arn   = data.aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.micro"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }
}