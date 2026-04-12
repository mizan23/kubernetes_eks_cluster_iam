############################
# IAM Role for Worker Nodes
############################
resource "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

############################
# Attach required policies
############################
resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################
# GENERAL (ON-DEMAND)
############################
resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = ["t3.micro"]
  disk_size      = 20
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.ssm,

    aws_internet_gateway.igw,
    aws_eip.nat,
    aws_nat_gateway.nat,
    aws_route.nat,
    aws_route_table_association.private1,
    aws_route_table_association.private2
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}

############################
# SPOT NODE GROUP
############################
resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "spot"
  node_role_arn   = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private_zone1.id,
    aws_subnet.private_zone2.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.micro", "t3.micro"]
  disk_size      = 20
  ami_type       = "AL2023_x86_64_STANDARD"

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "spot"
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.ssm,

    aws_internet_gateway.igw,
    aws_eip.nat,
    aws_nat_gateway.nat,
    aws_route.nat,
    aws_route_table_association.private1,
    aws_route_table_association.private2
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}