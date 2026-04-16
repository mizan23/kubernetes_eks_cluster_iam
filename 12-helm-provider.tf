############################################
# 12-helm-provider.tf
############################################

provider "helm" {
  kubernetes = {
    host                   = aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority[0].data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        aws_eks_cluster.eks.name,
        "--region",
        "us-east-1",
        "--profile",
        "mizan-ostad"
      ]
    }
  }
}