# Backup & DR configuration

resource "google_storage_bucket" "yb_snapshots" {
  name                        = "${var.project_id}-yb-snapshots"
  location                    = "US"
  force_destroy               = false
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

resource "kubernetes_service_account" "snapshot" {
  provider = kubernetes.dev
  metadata {
    name      = "yb-snapshot-sa"
    namespace = kubernetes_namespace.yb_prod.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = "${var.project_id}-snapshot-sa@${var.project_id}.iam.gserviceaccount.com"
    }
  }
}

resource "kubernetes_manifest" "snapshot_daily" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "yb-snapshot-daily"
      namespace = kubernetes_namespace.yb_prod.metadata[0].name
    }
    spec = {
      schedule                   = "0 3 * * *"
      successfulJobsHistoryLimit = 7
      failedJobsHistoryLimit     = 3
      jobTemplate = {
        spec = {
          template = {
            spec = {
              serviceAccountName = kubernetes_service_account.snapshot.metadata[0].name
              containers = [
                {
                  name    = "backup"
                  image   = "yugabytedb/yugabyte:latest"
                  command = ["sh", "-c", "yb-admin --master_addresses=$MASTERS create_snapshot"]
                  env = [
                    {
                      name  = "MASTERS"
                      value = "yb-master-0.yb-master-headless.yb-prod.svc.cluster.local:7100,yb-master-1.yb-master-headless.yb-prod.svc.cluster.local:7100,yb-master-2.yb-master-headless.yb-prod.svc.cluster.local:7100"
                    }
                  ]
                }
              ]
              restartPolicy = "OnFailure"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "snapshot_weekly" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "yb-snapshot-weekly"
      namespace = kubernetes_namespace.yb_prod.metadata[0].name
    }
    spec = {
      schedule                   = "0 4 * * 0"
      successfulJobsHistoryLimit = 4
      failedJobsHistoryLimit     = 1
      jobTemplate = {
        spec = {
          template = {
            spec = {
              serviceAccountName = kubernetes_service_account.snapshot.metadata[0].name
              containers = [
                {
                  name    = "backup"
                  image   = "yugabytedb/yugabyte:latest"
                  command = ["sh", "-c", "yb-admin --master_addresses=$MASTERS create_snapshot"]
                  env = [
                    {
                      name  = "MASTERS"
                      value = "yb-master-0.yb-master-headless.yb-prod.svc.cluster.local:7100,yb-master-1.yb-master-headless.yb-prod.svc.cluster.local:7100,yb-master-2.yb-master-headless.yb-prod.svc.cluster.local:7100"
                    }
                  ]
                }
              ]
              restartPolicy = "OnFailure"
            }
          }
        }
      }
    }
  }
}

resource "google_container_cluster" "dr" {
  name                     = "codet-dr-gke"
  location                 = "us-east1"
  network                  = google_compute_network.vpc.name
  subnetwork               = google_compute_subnetwork.subnet.name
  remove_default_node_pool = true
  node_locations           = ["us-east1-b", "us-east1-c", "us-east1-d"]

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

resource "google_container_node_pool" "dr_baseline" {
  name     = "baseline"
  cluster  = google_container_cluster.dr.name
  location = google_container_cluster.dr.location

  node_config {
    machine_type = "e2-standard-4"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 3
  }
} 