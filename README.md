
```shell
# When referencing something that is not defined.
Error:
  unable to find dependent resource in module: '', error: 'Resource not found:
  resource.network.cloud.id'

  /Users/erik/code/instruqt/phoenix/module/main.hcl:1,1
      1 | module "consul_dc1" {
      2 |   source =
        : "github.com/jumppad-labs/jumppad//examples/multiple_k3s_clusters/module_k3s"
      3 | 
```

```shell
# When trying to create something that already exists outside of your blueprint
Error:
  unable to create resource "resource.network.main" a Network already exists with
  the name: main ref:resource.network.main

  /Users/erik/code/instruqt/phoenix/module/main.hcl:1,1
      1 | resource "network" "main" {
      2 |   subnet = "10.0.0.0/16"
      3 | }
```

```shell
# Health checks on resources
DEBU Loading chart ref=consul path=/Users/erik/.jumppad/helm_charts/github.com/hashicorp/consul-k8s/ref/v0.34.1/charts/consul
DEBU Validate chart ref=consul
DEBU Run chart ref=consul
DEBU Helm debug name=consul chart=/Users/erik/.jumppad/helm_charts/github.com/hashicorp/consul-k8s/ref/v0.34.1/charts/consul message="creating 27 resource(s)"
DEBU Helm chart applied ref=consul
DEBU Health checking pods selector=release=consul
DEBU Pod not running pod=consul-consul-server-0 namespace=default status=Pending
DEBU Pod not ready pod=consul-consul-sgzkx namespace=default type=Ready value=False
DEBU Pod not running pod=consul-consul-server-0 namespace=default status=Pending
DEBU Pod not ready pod=consul-consul-sgzkx namespace=default type=Ready value=False
DEBU Pod not ready pod=consul-consul-server-0 namespace=default type=Ready value=False
DEBU Pods ready selector=release=consul
```