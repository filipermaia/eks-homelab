resource "aws_eks_cluster" "eks_cluster" {
  name = "${var.project_name}-cluster"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  vpc_config {
    subnet_ids = [
      var.public_subnet_1a,
      var.public_subnet_1b
    ]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment,
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-cluster"
    }
  )
}
