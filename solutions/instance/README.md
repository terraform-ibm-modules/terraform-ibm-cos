# Cloud Object Storage instance solution

This architecture creates a Cloud Object Storage instance on IBM Cloud® and supports provisioning the following resources:

- A resource group, if one is not passed in.
- A Cloud Object Storage instance on IBM Cloud.
- Context based restriction rules for the instance, if specified.

NB: This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

![cloud-object-storage-deployable-architecure](../../reference-architectures/instance.svg)
