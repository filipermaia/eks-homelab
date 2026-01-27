# EKS Homelab

Terraform repository to provision an AWS EKS cluster with networking, managed node groups, and the AWS Load Balancer Controller (ALB Controller).

## Project Structure

```
├── modules.tf              # Module wiring
├── provider.tf             # Provider config (AWS, Kubernetes, Helm)
├── variables.tf            # Input variable definitions
├── terraform.tfvars        # Variable values
└── modules/
        ├── network/            # VPC, subnets, gateways
        ├── cluster/            # EKS cluster, OIDC
        ├── managed-ng/         # Managed node groups
        └── alb-controller/     # ALB controller (IAM, Helm chart)
```

## Architecture

- **Network**: VPC (default 10.0.0.0/16), public and private subnets, NAT Gateway
- **Cluster**: EKS (configured in `modules/cluster`), OIDC for IRSA, optional public/private API endpoint access
- **Nodes**: Managed Node Group(s) in private subnets (configured in `modules/managed-ng`)
- **Load Balancer**: AWS Load Balancer Controller deployed via Helm (module `modules/alb-controller`)

## Requirements / Providers

- Terraform-compatible providers used (see `provider.tf` for provider configuration and pinning):
    - AWS provider: 6.2.0
    - Kubernetes provider: 2.37.1
    - Helm provider: 3.1.1

## Modules

- `./modules/cluster` — EKS cluster, OIDC provider, IAM roles for service accounts
- `./modules/alb-controller` — IAM policy + Helm release for AWS Load Balancer Controller
- `./modules/managed-ng` — Managed Node Group(s)
- `./modules/network` — VPC, subnets, route tables, gateways

## Inputs (key variables)

- `cidr_block` (string, required) — VPC CIDR block (example: "10.0.0.0/16")
- `project_name` (string, required) — Project/name tag prefix for resources
- `region` (string, required) — AWS region to deploy (example: "us-east-1")
- `tags` (map(string), required) — Map of tags applied to resources

See `variables.tf` and `terraform.tfvars` for the full list and defaults.

## Outputs

- `cluster_name` — EKS cluster name
- `cluster_endpoint` — Kubernetes API endpoint

## Prerequisites

- AWS CLI configured with credentials and appropriate permissions
- Terraform >= 1.0
- kubectl (for interacting with the cluster)
- Helm (for working with Helm charts, optional if using module-managed Helm)

## Quick Start (consume as remote module via an overlay)

This repository is intended to be used as a remote "super-module". Create a small overlay directory that defines the backend/provider, common locals (tags), and a `main.tf` that invokes the module. Below are minimal example files you can place in your overlay.

`provider.tf` (S3 remote state backend):

```terraform
terraform {
    backend "s3" {
        bucket = "<your-state-bucket>"
        key    = "path/to/terraform.tfstate"
        region = "us-east-1"
    }
}
```

`locals.tf` (example common tags):

```terraform
locals {
    tags = {
        Department   = "SRE"
        Organization = "Infra"
        Project      = "EKS"
        Environment  = "Staging"
    }
}
```

`main.tf` (invoke the module from the remote repository):

```terraform
module "eks" {
    source = "git@github.com:filipermaia/eks-homelab.git?ref=master"
    cidr_block   = "10.0.0.0/16"
    project_name = "homelab"
    region       = "us-east-1"
    tags         = local.tags
}
```

Usage:

```bash
mkdir my-eks-overlay
cd my-eks-overlay
# create the three files above (provider.tf, locals.tf, main.tf)
aws configure                      # ensure AWS creds are available
terraform init
terraform plan
terraform apply

# configure kubectl (example)
aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region us-east-1
kubectl get nodes
```

Adjust the backend bucket, key, region, tags and module input variables as needed for your environment.

## Configuration

Edit `terraform.tfvars` to set your values, for example:

```hcl
cidr_block   = "10.0.0.0/16"
project_name = "eks-homelab"
region       = "us-east-1"
tags         = {}
```

## Common Tasks

- Scale nodes: edit `modules/managed-ng/mng.tf`, change `desired_size`, then `terraform apply`
- Deploy a simple app:

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## Notes

- State: configure an S3 backend for remote state storage (not included by default)
- Provider versions shown above are the ones referenced in the project; confirm `provider.tf` for exact pins

## License

See [LICENSE](LICENSE).
