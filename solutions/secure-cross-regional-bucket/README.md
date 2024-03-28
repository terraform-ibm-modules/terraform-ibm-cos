# Cloud Object Storage - Secure Cross Regional bucket solution

This architecture creates a Cloud Object Storage (COS) bucket on IBM Cloud® and supports provisioning the following resources:

- A cross region COS bucket in an existing COS instance.

NB: This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

![cloud-object-storage-deployable-architecure](../../reference-architectures/secure-cross-regional-bucket.svg)
