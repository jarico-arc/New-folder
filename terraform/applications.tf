resource "kubernetes_namespace" "yb_prod" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  metadata {
    name = "yb-prod"
  }
}

resource "helm_release" "yugabyte" {
  provider    = helm.dev
  depends_on  = [google_container_cluster.dev]
  name             = "yb-prod"
  repository       = "https://charts.yugabyte.com"
  chart            = "yugabyte"
  namespace        = kubernetes_namespace.yb_prod.metadata[0].name
  create_namespace = false
  values           = [file("${path.module}/yugabyte_values.yaml")]
}

resource "kubernetes_namespace" "kafka" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  metadata {
    name = "kafka"
  }
}

resource "helm_release" "redpanda" {
  provider    = helm.dev
  depends_on  = [google_container_cluster.dev]
  name             = "rp"
  repository       = "https://charts.redpanda.com"
  chart            = "redpanda"
  namespace        = kubernetes_namespace.kafka.metadata[0].name
  create_namespace = false

  set {
    name  = "statefulset.replicas"
    value = "3"
  }
  set {
    name  = "storage.persistentVolume.size"
    value = "200Gi"
  }
  set {
    name  = "tolerations[0].key"
    value = "node-role.kubernetes.io/control-plane"
  }
  set {
    name  = "resources.requests.cpu"
    value = "2"
  }
  set {
    name  = "resources.requests.memory"
    value = "4Gi"
  }
  set {
    name  = "configuration.cluster.auto_create_topics_enabled"
    value = "true"
  }
  set {
    name  = "configuration.rpk.cloud_storage_enabled"
    value = "true"
  }
  set {
    name  = "configuration.rpk.cloud_storage_provider"
    value = "gcs"
  }
  set {
    name  = "configuration.rpk.cloud_storage_bucket"
    value = google_storage_bucket.redpanda_nearline.name
  }
  set {
    name  = "configuration.rpk.cloud_storage_region"
    value = var.region
  }
  set {
    name  = "configuration.rpk.cloud_storage_storage_class"
    value = "NEARLINE"
  }
  set {
    name  = "configuration.rpk.cloud_storage_retention_time_sec"
    value = "604800"
  }
}

resource "kubernetes_service_account" "debezium" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  metadata {
    name      = "debezium-sa"
    namespace = kubernetes_namespace.kafka.metadata[0].name
  }
}

resource "kubernetes_deployment" "debezium" {
  provider    = kubernetes.dev
  depends_on  = [google_container_cluster.dev]
  metadata {
    name      = "debezium-gke"
    namespace = kubernetes_namespace.kafka.metadata[0].name
    labels = {
      app = "debezium"
    }
  }

  spec {
    replicas = 3
    selector {
      match_labels = {
        app = "debezium"
      }
    }
    template {
      metadata {
        labels = {
          app = "debezium"
        }
      }
      spec {
        service_account_name = kubernetes_service_account.debezium.metadata[0].name

        container {
          name  = "connector"
          image = "quay.io/yugabyte/debezium-connector:yb.grpc.2024.2"

          env {
            name  = "CONNECT_TASKS_MAX"
            value = "4"
          }
          env {
            name  = "BOOTSTRAP_SERVERS"
            value = "rp-redpanda:9092"
          }

          resources {
            requests = {
              cpu    = "1"
              memory = "2Gi"
            }
            limits = {
              cpu    = "2"
              memory = "4Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/connectors"
              port = 8083
            }
            initial_delay_seconds = 60
          }
        }
      }
    }
  }
} 