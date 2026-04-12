############################
# 4-subnets.tf
############################


# PRIVATE (for nodes)
resource "aws_subnet" "private_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}



resource "aws_subnet" "public_zone1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "ap-south-1a"

  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_zone2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.102.0/24"
  availability_zone = "ap-south-1b"

  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${local.env}-${local.eks_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}