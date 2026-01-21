module "eks_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = var.tags
}

module "eks_cluster" {
  source           = "./modules/cluster"
  project_name     = var.project_name
  tags             = var.tags
  public_subnet_1a = module.eks_network.subnet_pub_1a.id
  public_subnet_1b = module.eks_network.subnet_pub_1b.id
}

module "eks_managed_node_group" {
  source            = "./modules/managed-ng"
  project_name      = var.project_name
  subnet_private_1a = module.eks_network.subnet_priv_1a
  subnet_private_1b = module.eks_network.subnet_priv_1b
  cluster_name      = module.eks_cluster.cluster_name
  tags              = var.tags
}

module "eks_controller_policy" {
  source       = "./modules/alb-controller"
  project_name = var.project_name
  tags         = var.tags
  oidc         = module.eks_cluster.oidc
  cluster_name = module.eks_cluster.cluster_name
  vpc_id       = module.eks_network.vpc_id
}