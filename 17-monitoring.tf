resource "helm_release" "monitoring" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"

  namespace        = "monitoring"
  create_namespace = true

  timeout = 900
  wait    = true

  values = [
    yamlencode({
      grafana = {

        # 🔥 CRITICAL FIX (this was missing)
        sidecar = {
          dashboards = {
            enabled = false
          }
          datasources = {
            enabled = false
          }
        }

        # resources
        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }
          limits = {
            cpu    = "300m"
            memory = "512Mi"
          }
        }

        # probes
        readinessProbe = {
          httpGet = {
            path = "/api/health"
            port = 3000
          }
          initialDelaySeconds = 30
          timeoutSeconds      = 5
          periodSeconds       = 10
        }

        livenessProbe = {
          httpGet = {
            path = "/api/health"
            port = 3000
          }
          initialDelaySeconds = 60
          timeoutSeconds      = 5
          periodSeconds       = 10
        }
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.general,
    helm_release.metrics_server
  ]
}