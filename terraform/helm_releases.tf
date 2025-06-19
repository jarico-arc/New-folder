resource "helm_release" "argocd" {
  provider = helm.dev
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.43.1"
  namespace        = "argocd"
  create_namespace = true

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}

resource "helm_release" "gatekeeper" {
  provider = helm.dev
  name             = "gatekeeper"
  repository       = "https://open-policy-agent.github.io/gatekeeper/charts"
  chart            = "gatekeeper"
  version          = "3.14.0"
  namespace        = "gatekeeper-system"
  create_namespace = true
}

resource "helm_release" "falco" {
  provider = helm.dev
  name             = "falco"
  repository       = "https://falcosecurity.github.io/charts"
  chart            = "falco"
  version          = "1.17.0"
  namespace        = "falco"
  create_namespace = true
  values           = [file("${path.module}/falco-values.yaml")]
} 