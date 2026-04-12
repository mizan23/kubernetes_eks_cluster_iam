############################################
# 9-add-developer-user.tf
############################################

############################################
# 10-add-developer-users.tf
############################################

resource "kubernetes_namespace_v1" "dev" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_role_v1" "developer_role" {
  metadata {
    name      = "developer-role"
    namespace = kubernetes_namespace_v1.dev.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "delete"]
  }
}

resource "kubernetes_role_binding_v1" "developer_binding" {
  metadata {
    name      = "developer-binding"
    namespace = kubernetes_namespace_v1.dev.metadata[0].name
  }

  subject {
    kind      = "User"
    name      = "developer"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role_v1.developer_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}