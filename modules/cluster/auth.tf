# resource "kubernetes_config_map" "aws_auth" {
#   depends_on = [aws_eks_cluster.eks_cluster]

#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data = {
#     mapRoles = yamlencode([
#       {
#         rolearn  = aws_iam_role.eks_cluster_role.arn
#         username = "system:node:{{EC2PrivateDNSName}}"
#         groups   = ["system:bootstrappers", "system:nodes"]
#       }
#     ])
#     mapUsers = yamlencode([
#       {
#         userarn  = "arn:aws:iam::342163604472:user/filipe-lab"
#         username = "filipe"
#         groups   = ["system:masters"]
#       }
#     ])
#   }
# }
