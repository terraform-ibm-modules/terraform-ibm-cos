# Cloud-Object-Storage for IBM Cloud - Financial Services Cloud solution

This architecture creates an Cloud-Object-Storage bucket on IBM Cloud® and supports provisioning the following resources:

- A Cross Region COS Bucket
- Context Based Restriction rules for the bucket.

NB: This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

![cloud-object-storage-deployable-architecure](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/reference-architectures/secure-cross-regional-bucket.svg)
