resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  version          = "1.22.0"
  namespace        = "istio-system"
  create_namespace = true
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.22.0"
  namespace  = "istio-system"

  set {
    name  = "meshConfig.mode"
    value = "ambient"
  }
}

resource "helm_release" "istio_gateway" {
  name             = "istio-ingressgateway"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  version          = "1.22.0"
  namespace        = "istio-system"

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
} 