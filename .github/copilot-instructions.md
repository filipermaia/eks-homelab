<!-- Copilot / AI agent instructions for the homelab Terraform repo -->
# Copilot instructions — homelab (Terraform)

Purpose
- Help an AI code agent be productive editing this Terraform mono-repo that builds an EKS homelab.

Big picture
- Root contains orchestration files: `modules.tf`, `provider.tf`, `variables.tf`, `terraform.tfvars`, `locals.tf`.
- Reusable modules live under `modules/`:
  - `modules/network` — VPC, subnets (see [modules/network/vpc.tf](modules/network/vpc.tf)).
  - `modules/cluster` — EKS cluster (see [modules/cluster/cluster.tf](modules/cluster/cluster.tf)).
  - `modules/managed-ng` — managed node group resources.
  - `modules/alb-controller` — IAM policy and OIDC setup for AWS Load Balancer Controller.
- Cross-module wiring is done via module outputs and inputs in `modules.tf` (example: `module.eks_network.subnet_pub_1a` passed into `module.eks_cluster`).

State and provider
- Backend: S3 backend is configured in `provider.tf` (bucket `homelab-filipe`, key `homelab/terraform.tfstate`). Ensure AWS credentials and access to that bucket before `terraform init`.
- AWS region is set to `us-east-1` in `provider.tf`.
- Kubernetes provider block is present but commented out — enabling it requires cluster outputs (endpoint/ca) to be available and valid kube auth (see `provider.tf`).

Conventions & patterns to follow
- Naming: resources are tagged using `var.project_name` and `local.tags` (see `locals.tf`). Keep tag merges consistent (modules use `merge(var.tags, { Name = ... })`).
- Module inputs/outputs: modules expose specific outputs consumed by others (e.g., `module.eks_cluster.oidc` used by `modules/alb-controller`). When adding outputs, follow existing naming style and export only what's necessary.
- Version pinning: providers are pinned in `provider.tf` (aws 6.2.0, kubernetes 2.37.1). Do not upgrade without explicit verification.

Typical developer workflow (examples)
- Initialize + download providers:
```bash
terraform init
```
- Validate configuration:
```bash
terraform validate
```
- Create a plan (uses `terraform.tfvars` by default):
```bash
terraform plan -var-file=terraform.tfvars -out=homelab.plan
```
- Apply the plan (or `terraform apply -auto-approve` for quick runs):
```bash
terraform apply homelab.plan
```
- If interacting with the EKS cluster, update kubeconfig locally with AWS CLI:
```bash
aws eks update-kubeconfig --name $(terraform output -raw module.eks_cluster.cluster_name)
```

Important files to inspect when making changes
- Root: [modules.tf](modules.tf), [provider.tf](provider.tf), [terraform.tfvars](terraform.tfvars), [locals.tf](locals.tf)
- Modules: [modules/cluster/cluster.tf](modules/cluster/cluster.tf), [modules/network/vpc.tf](modules/network/vpc.tf), [modules/alb-controller/iam.tf](modules/alb-controller/iam.tf)

Common gotchas
- The S3 backend requires correct AWS credentials and permissions; if you see backend errors, check `aws sts get-caller-identity` and S3 bucket ACLs/region.
- The `kubernetes` provider is commented out; attempting to use it before the cluster exists or without proper auth will fail.
- Keep provider versions consistent with `provider.tf` to avoid subtle provider API changes.

If you need more context
- Ask for the AWS account/credentials method (profile, env vars, or role) used for state/backend access.
- If editing modules, request outputs you expect to consume; prefer minimal outputs.

Next step after edits
- Run `terraform validate` then `terraform plan -var-file=terraform.tfvars` and share the plan for review.
- Update [README.md](README.md) if necessary when project structure, modules, or workflows change to keep documentation current.

Feedback
- If any section is unclear or you want additional automation examples (CI, pre-commit hooks, or example `make` targets), tell me where to expand.
