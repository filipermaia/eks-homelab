output "cluster_name" {
  value = module.eks_cluster.cluster_name
}

output "cluster_ca_data" {
  value = module.eks_cluster.cluster_ca_data
}

output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

output "oidc" {
  value = module.eks_cluster.oidc
}