data "aws_iam_role" "eks" {
  name = "${local.env}-${local.eks_name}-cluster"
}

resource "aws_security_group" "eks_cluster_sg" {
  name   = "${local.env}-${local.eks_name}-cluster-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-${local.eks_name}"
  version  = local.eks_version
  role_arn = data.aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_zone1.id,
      aws_subnet.private_zone2.id
    ]

    security_group_ids = [aws_security_group.eks_cluster_sg.id]

    endpoint_public_access  = true
    endpoint_private_access = true
  }
}
