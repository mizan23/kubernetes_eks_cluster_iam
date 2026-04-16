############################
# CLUSTER AUTOSCALER IAM ROLE (IRSA)
############################

resource "aws_iam_role" "cluster_autoscaler" {
  name = "eks-cluster-autoscaler"

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
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  })
}

############################
# IAM POLICY FOR AUTOSCALER
############################

# resource "aws_iam_policy" "cluster_autoscaler_policy" {
#   name = "ClusterAutoscalerPolicy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "autoscaling:DescribeAutoScalingGroups",
#           "autoscaling:DescribeAutoScalingInstances",
#           "autoscaling:DescribeLaunchConfigurations",
#           "autoscaling:DescribeTags",
#           "autoscaling:SetDesiredCapacity",
#           "autoscaling:TerminateInstanceInAutoScalingGroup",
#           "ec2:DescribeLaunchTemplateVersions"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

############################
# IAM POLICY FOR AUTOSCALER
############################

data "aws_iam_policy" "cluster_autoscaler_policy" {
  name = "ClusterAutoscalerPolicy"
}


############################
# ATTACH POLICY
############################

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  role       = aws_iam_role.cluster_autoscaler.name
#  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  policy_arn = data.aws_iam_policy.cluster_autoscaler_policy.arn
}

############################
# K8s SERVICE ACCOUNT (IRSA)
############################

resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }
}

############################
# HELM INSTALL
############################

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = aws_eks_cluster.eks.name
      }

      awsRegion = "us-east-1"

      rbac = {
        serviceAccount = {
          create = false
          name   = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
        }
      }

      extraArgs = {
        skip-nodes-with-local-storage = "false"
        balance-similar-node-groups   = "true"
        expander                      = "least-waste"
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general,
    aws_iam_role_policy_attachment.cluster_autoscaler_attach,
    kubernetes_service_account_v1.cluster_autoscaler,
    aws_eks_node_group.general
    ]
}