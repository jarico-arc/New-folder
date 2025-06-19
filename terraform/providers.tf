terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.7"
    }
  }
  required_version = ">= 1.0"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

data "google_client_config" "current" {}

// Kubernetes & Helm providers for dev cluster
provider "kubernetes" {
  alias                  = "dev"
  host                   = "https://${google_container_cluster.dev.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.dev.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  alias = "dev"
  kubernetes {
    host                   = "https://${google_container_cluster.dev.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.dev.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

// Kubernetes & Helm providers for stage cluster
provider "kubernetes" {
  alias                  = "stage"
  host                   = "https://${google_container_cluster.stage.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.stage.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  alias = "stage"
  kubernetes {
    host                   = "https://${google_container_cluster.stage.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.stage.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

// Kubernetes & Helm providers for prod cluster
provider "kubernetes" {
  alias                  = "prod"
  host                   = "https://${google_container_cluster.prod.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.prod.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  alias = "prod"
  kubernetes {
    host                   = "https://${google_container_cluster.prod.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.prod.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

// Kubernetes & Helm providers for dr cluster
provider "kubernetes" {
  alias                  = "dr"
  host                   = "https://${google_container_cluster.dr.endpoint}"
  cluster_ca_certificate = base64decode(google_container_cluster.dr.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  alias = "dr"
  kubernetes {
    host                   = "https://${google_container_cluster.dr.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.dr.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
} 