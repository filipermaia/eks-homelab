# EKS Homelab

Terraform mono-repo for provisioning an EKS cluster on AWS with networking, managed node groups, and AWS Load Balancer Controller.

## Project Structure

```
├── modules.tf              # Module wiring
├── provider.tf             # Provider config (AWS, Kubernetes, Helm)
├── variables.tf            # Variables
├── terraform.tfvars        # Variable values
└── modules/
    ├── network/            # VPC, subnets, gateways
    ├── cluster/            # EKS cluster, OIDC
    ├── managed-ng/         # Managed node groups
    └── alb-controller/     # ALB controller
```

## Architecture

- **Network**: VPC (10.0.0.0/16), public/private subnets (us-east-1a/b), NAT gateway
- **Cluster**: EKS 1.31, OIDC for IRSA, public and private endpoint access
- **Nodes**: Managed node group in private subnets (default: 1 node)
- **Load Balancer**: AWS ALB controller via Helm
- **State**: S3 backend (`homelab-filipe/homelab/terraform.tfstate`)

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl
- Helm

## Quick Start

```bash
git clone https://github.com/filipermaia/eks-homelab.git
cd eks-homelab

aws configure
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars

# Configure kubectl
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region us-east-1
kubectl get nodes
```

## Configuration

Edit `terraform.tfvars`:
```hcl
cidr_block   = "10.0.0.0/16"
project_name = "eks-homelab"
region       = "us-east-1"
tags         = {}
```

## Outputs

- `cluster_name`: EKS cluster name
- `cluster_endpoint`: Kubernetes API endpoint
- `cluster_ca_data`: CA certificate
- `oidc`: OIDC issuer URL

## Common Tasks

**Scale nodes**: Edit `modules/managed-ng/mng.tf`, change `desired_size`, then `terraform apply`

**Deploy app**: 
```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

**Provider versions**: AWS 6.2.0, Kubernetes 2.37.1, Helm 3.1.1 (in `provider.tf`)

## License

See [LICENSE](LICENSE).