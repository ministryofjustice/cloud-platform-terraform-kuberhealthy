## Namespace Check

The *Namespace* checks if all the vital namespaces exists in the cluster. It checks if the list of namespaces mentioned in the list `namespaces` exists in the cluster. If any of the namespaces doesnot exists, then this checks sends a status: `false` with message `Namespace check failed:namespaces [deleted-namespace] not found`

The check runs every 30 sec (spec.runInterval), with a check timeout set to 2m (spec.timeout). If the check
does not complete within the given timeout it will report a timeout error on the status page.


#### Example KuberhealthyCheck Spec:
```yaml
apiVersion: comcast.github.io/v1
kind: KuberhealthyCheck
metadata:
  name: namespace-kh-check
  namespace: kuberhealthy
spec:
  runInterval: 30s 
  timeout: 2m 
  podSpec: 
    containers:
      - env: 
        image: ministryofjustice/namespace-kh-check:1.3
        imagePullPolicy: Always 
        name: main
        securityContext:
          runAsUser: 999
    serviceAccountName: namespace-check-sa

The check also requires a ServiceAccount, ClusterRoleBinding and ClusterRole with permissions to get any namespace from the cluster.

#### How-to

To implement the Namespace Check with Kuberhealthy, run

`kubectl apply -f https://github.com/ministryofjustice/cloud-platform-terraform-kuberhealthy/tree/main/cmd/namespace-check/namespace-check.yaml`