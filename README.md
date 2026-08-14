# TFG Multicloud Infrastructure (Terraform)

Infrastructure as Code for a University TFG: a progressive multicloud DevOps
architecture (AWS + Azure) hosting a monitored FastAPI stack
(Docker Compose: app, Prometheus, Grafana, cAdvisor, Alertmanager, Discord adapter).

## Layout

```
envs/                  one folder per environment, each with its own state
  aws-dev/             single instance on AWS (base IaC deployment)
  aws-ha/              two instances across AZs behind an ALB (high availability)
  azure-dev/           equivalent single-instance deployment on Azure
modules/
  networking/          AWS: VPC, multi-AZ public subnets, IGW, routes, hardened SG
  compute/             AWS: EC2 + cloud-init bootstrap (swap, Docker, optional stack)
  loadbalancer/        AWS: ALB, target group, health checks, SG chaining
  networking-azure/    Azure: RG, VNet, subnet, NSG (subnet-associated)
  compute-azure/       Azure: public IP, NIC, VM + cloud-init bootstrap
scripts/
  dr-recovery.ps1      disaster-recovery runbook: timed recovery on Azure (RTO)
```

## Authentication (no long-lived secrets)

- AWS: `aws login` (CLI v2 browser flow, temporary credentials). Requires provider >= 6.0.
- Azure: `az login`. `subscription_id` goes in `terraform.tfvars` (gitignored).

## Usage (any env)

```
cd envs/<env>
terraform init
terraform plan
terraform apply
```

`azure-dev` needs a `terraform.tfvars` first (see `terraform.tfvars.example`).
The admin IP for SSH/monitoring ports is auto-detected at plan time;
override with `admin_cidr` if needed.

## Security decisions baked in

- SSH (22), Prometheus (9090) and Alertmanager (9093) restricted to the admin IP.
- `admin_cidr` validated: must be a valid CIDR, never 0.0.0.0/0 (policy as code).
- AWS default security group adopted and stripped empty (fail-closed).
- In `aws-ha`, instances are not publicly reachable on the app port; traffic
  enters only through the ALB (SG-to-SG rule).
- No credentials or key material in code or state; SSH key referenced by name.
