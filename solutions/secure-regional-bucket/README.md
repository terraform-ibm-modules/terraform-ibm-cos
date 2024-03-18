# Cloud-Object-Storage for IBM Cloud - Financial Services Cloud solution

This architecture creates an Cloud-Object-Storage and bucket on IBM Cloud® and supports provisioning the following resources:

- A resource group, if one is not passed in.
- A Cloud-Object-Storage for IBM Cloud
- A Regional COS Bucket
- Context Based Restriction rules for the instance and buckets

NB: This solution is not intended to be called by one or more other modules since it contains a provider configurations, meaning it is not compatible with the `for_each`, `count`, and `depends_on` arguments. For more information see [Providers Within Modules](https://developer.hashicorp.com/terraform/language/modules/develop/providers)

![cloud-object-storage-deployable-architecure](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/reference-architectures/secure-regional-bucket.svg)
