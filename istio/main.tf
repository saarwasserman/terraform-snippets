terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "3.0.2"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}


# AWS Load Balancer Controller Helm Release
# used for managing AWS Load Balancer Controller in EKS 

# https://github.com/kubernetes-sigs/aws-load-balancer-controller
resource "helm_release" "istio-base" {
  name       = "istio-base"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  version    = "1.26.3"
}

resource "helm_release" "istiod" {
  name       = "istiod"
  namespace  = "istio-system"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  version    = "1.26.3"

  set = [
    {
      name = "autoscaleMin"
      value = 1
    }
  ]

  depends_on = [helm_release.istio-base]
}

resource "helm_release" "gateways" {
  name       = "gateway"
  namespace  = "istio-gateways"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  version    = "1.26.3"

  depends_on = [helm_release.istiod]
}
