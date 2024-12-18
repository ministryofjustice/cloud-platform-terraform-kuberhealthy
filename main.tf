resource "kubernetes_namespace" "kuberhealthy" {
  metadata {
    name = "kuberhealthy"

    labels = {
      "name"                                           = "kuberhealthy"
      "component"                                      = "kuberhealthy"
      "cloud-platform.justice.gov.uk/is-production"    = "true"
      "cloud-platform.justice.gov.uk/environment-name" = "production"
      "pod-security.kubernetes.io/enforce"             = "privileged"
    }

    annotations = {
      "cloud-platform.justice.gov.uk/application"   = "Kuberhealthy"
      "cloud-platform.justice.gov.uk/business-unit" = "Platforms"
      "cloud-platform.justice.gov.uk/owner"         = "Cloud Platform: platforms@digital.justice.gov.uk"
      "cloud-platform.justice.gov.uk/source-code"   = "https://github.com/ministryofjustice/cloud-platform-infrastructure"
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
  version    = "104"

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.prometheusRule.enabled"
    value = "false"
  }

  set {
    name = "check.daemonset.extraEnvs.DAEMONSET_PRIORITY_CLASS_NAME"
    value = "cluster-critical"
  }

  set {
    name = "check.deployment.extraEnvs.CHECK_DEPLOYMENT_REPLICAS"
    value = "2"
  }

  set {
    name = "checkReaper.logLevel"
    value = "debug"
  }

  lifecycle {
    ignore_changes = [keyring]
  }
}

resource "kubectl_manifest" "namespacecheck_rule_alert_crb" {
  yaml_body = file("${path.module}/resources/cluster-role-binding.yaml")

  wait = true

  depends_on = [helm_release.kuberhealthy]
}

resource "kubectl_manifest" "namespacecheck_rule_alert_cr" {
  yaml_body = file("${path.module}/resources/cluster-role.yaml")

  wait = true

  depends_on = [helm_release.kuberhealthy]
}

resource "kubectl_manifest" "namespacecheck_rule_alert_sa" {
  yaml_body = file("${path.module}/resources/serviceaccount.yaml")

  wait = true

  depends_on = [
    helm_release.kuberhealthy,
    kubectl_manifest.namespacecheck_rule_alert_crb
  ]
}

resource "kubectl_manifest" "namespace_check" {
  wait = true

  yaml_body = templatefile("${path.module}/templates/namespace-check.yaml.tmpl", {
    cluster_env = var.cluster_env
  })


  depends_on = [helm_release.kuberhealthy, kubectl_manifest.namespacecheck_rule_alert_sa]

}
