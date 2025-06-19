# Terraform GKE & VPC Provisioning

This directory contains Terraform code to provision:

- VPC: `yugabyte-secure-vpc`
- Subnet: `yugabyte-subnet-us-central1`
- DEV GKE cluster: `codet-dev-gke` with baseline, surge, and spot node pools

## Prerequisites

1. Install Terraform (v1.0+)
2. Have a Google Cloud service account JSON key with appropriate permissions
3. Enable the following APIs in your project:
   - Compute Engine API
   - Kubernetes Engine API
   - IAM API

## Usage

```bash
# Export your GCP project and credentials
export TF_VAR_project_id="<YOUR_GCP_PROJECT_ID>"
export GOOGLE_APPLICATION_CREDENTIALS="<PATH_TO_SERVICE_ACCOUNT_KEY>.json"

# Initialize Terraform
terraform init
# Plan and apply for DEV cluster
gcloud container clusters get-credentials codet-dev-gke --region us-central1 --project $TF_VAR_project_id
terraform plan -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"
terraform apply -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"
```

## Deploying to Multiple Environments

Switch your GKE context and re-apply Terraform for each environment:

```bash
# DEV
gcloud container clusters get-credentials codet-dev-gke --region us-central1 --project $TF_VAR_project_id
terraform apply -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"

# STAGE
gcloud container clusters get-credentials codet-stage-gke --region us-central1 --project $TF_VAR_project_id
terraform apply -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"

# PROD
gcloud container clusters get-credentials codet-prod-gke --region us-central1 --project $TF_VAR_project_id
terraform apply -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"

# DR (warm standby)
gcloud container clusters get-credentials codet-dr-gke --region us-east1 --project $TF_VAR_project_id
terraform apply -var="gitops_repo_url=<YOUR_GITOPS_REPO_URL>"
```

## Variables

- `project_id`: GCP project ID
- `region`: GCP region (default: `us-central1`)
- `zones`: List of zones (default: [`us-central1-a`, `us-central1-b`, `us-central1-c`])

## Outputs

- `vpc_name`
- `subnet_name`
- `cluster_name`
- `cluster_endpoint`
- `cluster_ca_certificate` 