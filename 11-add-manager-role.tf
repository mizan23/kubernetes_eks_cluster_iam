############################################
# 11-add-manager-role.tf
############################################

resource "kubernetes_cluster_role_v1" "manager_role" {
  metadata {
    name = "manager-role"
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "manager_binding" {
  metadata {
    name = "manager-binding"
  }

  subject {
    kind      = "User"
    name      = "manager"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.manager_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}