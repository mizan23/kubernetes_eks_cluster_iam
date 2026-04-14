resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"

  namespace        = "monitoring"
  create_namespace = true

  depends_on = [
    aws_eks_node_group.general,
    helm_release.metrics_server
  ]
}