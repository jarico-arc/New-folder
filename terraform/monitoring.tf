resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "kube_prometheus_stack" {
  provider = helm.dev
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "45.0.1"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  values           = [file("${path.module}/monitoring_values.yaml")]
} 