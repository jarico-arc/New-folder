resource "google_container_cluster" "prod" {
  name                     = "codet-prod-gke"
  location                 = var.region

  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name

  remove_default_node_pool = true
  node_locations           = var.zones

  network_policy {
    enabled = true
  }
  enable_shielded_nodes    = true

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  vertical_pod_autoscaling {
    enabled = true
  }
}

resource "google_container_node_pool" "prod_baseline" {
  name     = "baseline"
  cluster  = google_container_cluster.prod.name
  location = var.region

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = { tier = "base" }
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 15
  }
}

resource "google_container_node_pool" "prod_surge" {
  name     = "surge"
  cluster  = google_container_cluster.prod.name
  location = var.region

  node_config {
    machine_type = "c2-standard-8"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    labels       = { tier = "surge" }
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 5
  }
}

resource "google_container_node_pool" "prod_spot" {
  name     = "spot"
  cluster  = google_container_cluster.prod.name
  location = var.region

  node_config {
    machine_type = "e2-medium"
    preemptible  = true
    labels       = { tier = "spot" }
    taints       = [{ key = "spot", value = "true", effect = "PreferNoSchedule" }]
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }
} 