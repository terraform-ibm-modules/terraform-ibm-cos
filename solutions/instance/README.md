# Cloud Object Storage instance solution

This architecture supports provisioning the following resources:

- An IBM Cloud Object Storage instance.
- Resource keys
- Service credentials managed by Secrets Manager

This solution is not intended to be invoked by other modules, as it includes provider configuration. As a result, it is incompatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![cloud-object-storage-deployable-architecure](../../reference-architectures/instance.svg)
