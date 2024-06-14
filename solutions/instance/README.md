# Cloud Object Storage instance solution

This architecture creates a Cloud Object Storage instance and provisions the following resources:

- A resource group, if one is not passed in.
- A IBM Cloud Object Storage instance.

This solution is not intended to be called by one or more other modules because it contains a provider configurations, and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![cloud-object-storage-deployable-architecure](../../reference-architectures/instance.svg)
