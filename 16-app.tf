resource "helm_release" "app" {
  name  = "app"
  chart = "${path.module}/../3-tier-app-terraform-jenkins/helm/app"

  namespace        = "default"
  create_namespace = false

  values = [
    yamlencode({
      backend = {
        image = "mizan23/backend"
        tag   = var.image_tag
      }
      frontend = {
        image = "mizan23/frontend"
        tag   = var.image_tag
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general,
    helm_release.alb_controller,
    helm_release.metrics_server
  ]
}