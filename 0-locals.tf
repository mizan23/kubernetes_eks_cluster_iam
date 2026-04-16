############################
# 0-locals.tf
############################
locals {
  env        = "dev"
  eks_name   = "eks-cluster"
  eks_version = "1.30"
}

terraform {
  backend "s3" {
    bucket  = "mizan-eks-tfstate-bucket"
    key     = "eks/dev/terraform.tfstate"
    region  = "ap-south-1"
    profile = "mizan-ostad"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}