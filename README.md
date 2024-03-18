# cloud-platform-terraform-kuberhealthy

Terraform module that deploys kuberhealthy which is a Kubernetes operator for synthetic monitoring and continuous process verification.


## Usage

```hcl
module "kuberhealthy" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-kuberhealthy?ref=v1.0.1"

  cluster_env = terraform.workspace
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >=2.6.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | 2.0.4 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >=2.12.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >=2.6.0 |
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | 2.0.4 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >=2.12.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kuberhealthy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubectl_manifest.namespace_check](https://registry.terraform.io/providers/alekc/kubectl/2.0.4/docs/resources/manifest) | resource |
| [kubectl_manifest.namespacecheck_rule_alert](https://registry.terraform.io/providers/alekc/kubectl/2.0.4/docs/resources/manifest) | resource |
| [kubernetes_namespace.kuberhealthy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_env"></a> [cluster\_env](#input\_cluster\_env) | the name of the cluster | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
