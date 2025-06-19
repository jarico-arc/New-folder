resource "google_storage_bucket" "redpanda_nearline" {
  name                      = "${var.project_id}-redpanda-nearline"
  location                  = var.region
  storage_class             = "NEARLINE"
  uniform_bucket_level_access = true
}

resource "kubernetes_manifest" "scale_surge_up" {
  provider    = kubernetes.prod
  depends_on  = [google_container_cluster.prod]
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "scale-surge-up"
      namespace = "default"
    }
    spec = {
      schedule = "0 13 * * *"
      jobTemplate = {
        spec = {
          template = {
            spec = {
              containers = [
                {
                  name    = "scale-up"
                  image   = "google/cloud-sdk:slim"
                  command = [
                    "sh", "-c", 
                    "gcloud container clusters resize ${google_container_cluster.prod.name} --region ${var.region} --node-pool surge --max-nodes=5 --quiet"
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

resource "kubernetes_manifest" "scale_surge_down" {
  provider    = kubernetes.prod
  depends_on  = [google_container_cluster.prod]
  manifest = {
    apiVersion = "batch/v1"
    kind       = "CronJob"
    metadata = {
      name      = "scale-surge-down"
      namespace = "default"
    }
    spec = {
      schedule = "0 23 * * *"
      jobTemplate = {
        spec = {
          template = {
            spec = {
              containers = [
                {
                  name    = "scale-down"
                  image   = "google/cloud-sdk:slim"
                  command = [
                    "sh", "-c", 
                    "gcloud container clusters resize ${google_container_cluster.prod.name} --region ${var.region} --node-pool surge --max-nodes=0 --quiet"
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

resource "helm_release" "carbon_footprint" {
  provider = helm.prod
  name             = "cloud-carbon-footprint"
  repository       = "https://helm.cloud-carbon-footprint.com"
  chart            = "cloud-carbon-footprint"
  version          = "0.3.2"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  values           = [file("${path.module}/carbon_exporter_values.yaml")]
} 