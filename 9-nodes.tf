# =========================
# EXISTING IAM ROLE (DO NOT CREATE AGAIN)
# =========================
data "aws_iam_role" "nodes" {
  name = "${local.env}-${local.eks_name}-nodes"
}

# =========================
# ATTACH REQUIRED POLICIES
# =========================

# Worker node permissions
resource "aws_iam_role_policy_attachment" "worker_node" {
  role       = data.aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Networking (CNI)
resource "aws_iam_role_policy_attachment" "cni" {
  role       = data.aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Pull images from ECR
resource "aws_iam_role_policy_attachment" "ecr" {
  role       = data.aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 🔥 CRITICAL FIX (EBS CSI DRIVER PERMISSIONS)
resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = data.aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# =========================
# EKS NODE GROUP
# =========================
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
    min_size     = 1
  }

  instance_types = ["t3.medium"]
  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"

  depends_on = [
    aws_iam_role_policy_attachment.worker_node,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}