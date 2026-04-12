############################
# 7-eks.tf
############################

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_name}-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach EKS policy
resource "aws_iam_role_policy_attachment" "eks" {
  role       = aws_iam_role.eks.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  name   = "${local.env}-${local.eks_name}-cluster-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Allow HTTPS from anywhere (for testing)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env}-${local.eks_name}-cluster-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_version
  role_arn = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_zone1.id,
      aws_subnet.private_zone2.id
    ]

    security_group_ids = [aws_security_group.eks_cluster_sg.id]

    endpoint_public_access = true
    endpoint_private_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks
  ]
}
