resource "kubernetes_storage_class" "pd_ssd_regional" {
  metadata {
    name = "pd-ssd-regional"
  }

  storage_provisioner  = "pd.csi.storage.gke.io"
  parameters = {
    type             = "pd-ssd"
    replication-type = "regional-pd"
  }

  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
} 