resource "helm_release" "eks_helm_controller" {
  name       = "eks-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.16.0"
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]
}