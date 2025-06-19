variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region (e.g. us-central1)"
  type        = string
  default     = "us-central1"
}

variable "zones" {
  description = "List of GCP zones for the regional cluster"
  type        = list(string)
  default     = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "gitops_repo_url" {
  description = "Git repository URL for ArgoCD applications"
  type        = string
}

variable "gitops_repo_branch" {
  description = "Git branch to target for ArgoCD applications"
  type        = string
  default     = "main"
}

variable "gitops_repo_path_envs" {
  description = "Path within the GitOps repo to environment folders"
  type        = string
  default     = "envs"
} 