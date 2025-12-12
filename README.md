# EKS Homelab

A Terraform-based infrastructure-as-code project for deploying an Amazon EKS (Elastic Kubernetes Service) homelab environment. This mono-repo provisions a complete EKS cluster with networking, managed node groups, and AWS Load Balancer Controller integration.

## Architecture

The project uses a modular Terraform structure:

- **Network Module** (`modules/network/`): Creates VPC, public/private subnets, internet gateway, and NAT gateways
- **Cluster Module** (`modules/cluster/`): Provisions EKS cluster with OIDC provider for IAM roles
- **Managed Node Group Module** (`modules/managed-ng/`): Deploys EC2 instances as worker nodes
- **ALB Controller Module** (`modules/alb-controller/`): Sets up IAM permissions and Helm deployment for AWS Load Balancer Controller

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- kubectl (for cluster interaction)
- Helm (for Kubernetes package management)

### Required AWS Permissions

Your AWS user/role needs permissions for:
- EKS cluster creation and management
- VPC, subnet, and networking resources
- IAM roles and policies
- EC2 instances and security groups
- S3 (for Terraform state backend)

## Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/filipermaia/homelab.git
   cd homelab
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   # or set environment variables
   export AWS_ACCESS_KEY_ID=your-key
   export AWS_SECRET_ACCESS_KEY=your-secret
   ```

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the plan**
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

5. **Apply the infrastructure**
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```

6. **Configure kubectl**
   ```bash
   aws eks update-kubeconfig --name $(terraform output -raw cluster_name)
   ```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `cidr_block` | VPC CIDR block | `10.0.0.0/16` |
| `project_name` | Project name for resource tagging | `eks-homelab` |

### Outputs

| Output | Description |
|--------|-------------|
| `cluster_name` | EKS cluster name |
| `cluster_endpoint` | Kubernetes API server endpoint |
| `cluster_ca_data` | Cluster certificate authority data |
| `oidc` | OIDC issuer URL for IAM roles |

## Usage

### Scaling Node Groups

To modify node group size, update the desired/min/max counts in `modules/managed-ng/mng.tf` and reapply.

### Adding Applications

After deployment, use kubectl or Helm to deploy applications:

```bash
# Example: Deploy nginx
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

The ALB Controller will automatically provision an Application Load Balancer.

### Updating the Cluster

```bash
# Update Kubernetes version (modify in modules/cluster/cluster.tf)
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Development

### Code Structure

```
.
├── modules/                 # Reusable Terraform modules
│   ├── network/            # VPC and networking
│   ├── cluster/            # EKS cluster
│   ├── managed-ng/         # Node groups
│   └── alb-controller/     # Load balancer controller
├── .github/                # GitHub configuration
│   └── copilot-instructions.md  # AI coding guidance
├── provider.tf             # Provider configurations
├── modules.tf              # Module instantiations
├── variables.tf            # Input variables
├── terraform.tfvars        # Variable values
├── outputs.tf              # Root outputs
└── README.md               # This file
```

### Terraform Workflow

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan -var-file=terraform.tfvars

# Apply changes
terraform apply -var-file=terraform.tfvars

# Destroy infrastructure
terraform destroy -var-file=terraform.tfvars
```

### State Management

State is stored in S3 bucket `homelab-filipe` with key `homelab/terraform.tfstate`. Ensure your AWS credentials have access to this bucket.

## Troubleshooting

### Common Issues

1. **Backend access denied**: Verify AWS credentials and S3 bucket permissions
2. **Provider version conflicts**: Check `provider.tf` for pinned versions
3. **Kubernetes provider errors**: Ensure cluster is fully provisioned before using kubernetes provider
4. **ALB Controller failures**: Check pod logs and verify IAM permissions

### Logs and Debugging

```bash
# View Terraform logs
export TF_LOG=DEBUG
terraform apply -var-file=terraform.tfvars

# Check cluster status
kubectl get nodes
kubectl get pods -A

# ALB Controller logs
kubectl logs -n kube-system deployment/eks-load-balancer-controller
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the existing patterns
4. Test with `terraform validate` and `terraform plan`
5. Submit a pull request

See [.github/copilot-instructions.md](.github/copilot-instructions.md) for AI-assisted development guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Resources

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)