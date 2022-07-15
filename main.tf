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
  repository = "https://kuberhealthy.github.io/kuberhealthy/helm-repos/"
  chart      = "kuberhealthy"
  version    = "87"

  set {
    name  = "auditFromCache"
    value = "true"
  }

  set {
    name  = "postInstall.labelNamespace.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name = "prometheus.prometheusRule.enabled"
    value = "false"
  }

  lifecycle {
    ignore_changes = [keyring]
  }
}
#########################
# kuberhealthy placeholder for our future custom alerts#
#########################

data "kubectl_path_documents" "namespace_check_manifests" {
  pattern = "${path.module}/resources/namespace-check.yaml"
}

resource "kubectl_manifest" "namespacecheck_rule_alert" {
  count     = length(data.kubectl_path_documents.namespace_check_manifests.documents)
  yaml_body = element(data.kubectl_path_documents.namespace_check_manifests.documents, count.index)
}
