# Cloud Object Storage - Regional bucket (Fully Configurable)

This solution configures the following infrastructure -
- optionally a KMS key ring
- optionally a KMS key for Cloud Object Storage encryption
- configuring a Cloud Object Storage bucket

This architecture creates an IBM Cloud Object Storage bucket and provisions a regional bucket in an existing Object Storage instance.

This solution is not intended to be called by one or more other modules because it contains a provider configurations, and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![cloud-object-storage-deployable-architecure](../../reference-architectures/regional-bucket.svg)
