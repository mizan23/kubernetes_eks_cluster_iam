############################################
# 13-metrics-server.tf
############################################

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"

  values = [
    yamlencode({
      args = [
        "--kubelet-insecure-tls",
        "--kubelet-preferred-address-types=InternalIP"
      ]
    })
  ]

  depends_on = [
    kubernetes_cluster_role_v1.manager_role,
    aws_eks_cluster.eks,
    aws_eks_node_group.general
  ]
}