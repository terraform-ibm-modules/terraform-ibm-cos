# Cloud Object Storage - Secure Cross Regional bucket solution

This architecture creates an IBM Cloud Object Storage bucket and provisions a cross-region bucket in an existing Object Storage instance.

This solution is not intended to be called by one or more other modules because it contains a provider configurations, and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![cloud-object-storage-deployable-architecure](../../reference-architectures/secure-cross-regional-bucket.svg)

// Test comment
