############################################
# 15-alb-controller.tf (FINAL WORKING)
############################################

############################
# OIDC PROVIDER (AUTO CREATE)
############################

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]
}

############################
# IAM POLICY (EXISTING)
############################

data "aws_iam_policy" "alb" {
  arn = "arn:aws:iam::366403523501:policy/AWSLoadBalancerControllerIAMPolicy"
}

############################
# IAM ROLE
############################

resource "aws_iam_role" "alb_controller" {
  name = "AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

############################
# ATTACH POLICY
############################

resource "aws_iam_role_policy_attachment" "alb_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = data.aws_iam_policy.alb.arn
}

############################
# SERVICE ACCOUNT
############################

resource "kubernetes_service_account_v1" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

############################
# HELM INSTALL (FIXED)
############################

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = aws_eks_cluster.eks.name
      region      = "us-east-1"
      vpcId       = aws_vpc.main.id

      serviceAccount = {
        create = false
        name   = kubernetes_service_account_v1.alb_sa.metadata[0].name
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general,
    aws_iam_role_policy_attachment.alb_attach,
    kubernetes_service_account_v1.alb_sa
  ]
}