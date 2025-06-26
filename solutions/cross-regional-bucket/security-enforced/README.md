# Cloud Object Storage - Cross Regional bucket (Fully Configurable)

This solution configures the following infrastructure -
- KMS key ring
- KMS key for Cloud Object Storage encryption

This solution is not intended to be called by one or more other modules because it contains a provider configurations, and is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information, see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers).

![cloud-object-storage-deployable-architecure](../../../reference-architectures/cross-regional-bucket.svg)
