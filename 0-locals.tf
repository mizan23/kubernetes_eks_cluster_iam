############################
# 0-locals.tf
############################
locals {
  env        = "dev"
  eks_name   = "eks-cluster"
  eks_version = "1.30"
}