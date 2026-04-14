
############################
# 12-outputs.tf
############################
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "update_kubeconfig" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks.name}"
}

output "alb_dns" {
  value = "Check via kubectl get ingress"
}