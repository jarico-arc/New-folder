resource "google_compute_network" "vpc" {
  name                    = "yugabyte-secure-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name                     = "yugabyte-subnet-us-central1"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.vpc.id
  private_ip_google_access = true
}

resource "google_container_cluster" "dev" {
  name                     = "codet-dev-gke"
  location                 = var.region
  remove_default_node_pool = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  node_locations = var.zones

  network_policy {
    enabled = true
  }

  enable_shielded_nodes = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}

resource "google_container_node_pool" "baseline" {
  name     = "baseline"
  cluster  = google_container_cluster.dev.name
  location = var.region

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 15
  }
}

resource "google_container_node_pool" "surge" {
  name     = "surge"
  cluster  = google_container_cluster.dev.name
  location = var.region

  node_config {
    machine_type = "c2-standard-8"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }
}

resource "google_container_node_pool" "spot" {
  name     = "spot"
  cluster  = google_container_cluster.dev.name
  location = var.region

  node_config {
    machine_type = "e2-medium"
    preemptible  = true
    labels       = { tier = "spot" }
    taint {
      key    = "spot"
      value  = "true"
      effect = "PREFER_NO_SCHEDULE"
    }
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }
} 