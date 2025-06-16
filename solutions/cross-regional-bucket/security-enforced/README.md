# Cloud Object Storage - Cross Regional Bucket (Security Enforced)

This solution supports the following:
- Provisioning and configuring of a Cloud Object Storage bucket.
- Configuring KMS encryption using a newly created key, or passing an existing key.

**NB:** This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)
