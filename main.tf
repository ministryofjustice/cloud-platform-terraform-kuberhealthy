resource "kubernetes_namespace" "kuberhealthy" {
  metadata {
    name = "kuberhealthy"

    labels = {
      "name"                                           = "kuberhealthy"
      "component"                                      = "kuberhealthy"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
      "cloud-platform.justice.gov.uk/environment-name" = "production"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "Kuberhealthy"
      "cloud-platform.justice.gov.uk/business-unit" = "Platforms"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
# potentially "https://github.com/ministryofjustice/cloud-platform-infrastructure/blob/master/terraform/cloud-platform-components/kuberhealthy.tf"
      "cloud-platform.justice.gov.uk/slack-channel" = "cloud-platform"
      "cloud-platform-out-of-hours-alert"           = "true"
    }
  }
}

resource "helm_release" "kuberhealthy" {
  name       = "kuberhealthy"
  namespace  = kubernetes_namespace.kuberhealthy.id
  repository = "https://github.com/kuberhealthy/kuberhealthy/tree/master/deploy/helm"
  chart      = "kuberhealthy"
  version    = "87"
  appversion = "2.7.1"

  set {
    name  = "auditFromCache"
    value = "true"
  }

  set {
    name  = "postInstall.labelNamespace.enabled"
    value = "false"
  }

  lifecycle {
    ignore_changes = [keyring]
  }
}

