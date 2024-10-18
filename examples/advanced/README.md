# Advanced example

This example creates buckets that are encrypted with your own keys (BYOK). The buckets include context-based restriction (CBR) rules.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A service ID that is used to generate resource keys.
- A Key Protect instance (with metrics enabled), a key ring, and a root key in the given resource group and region.
- An IBM Cloud Object Storage instance in the given resource group and region.
- An IAM authorization policy to allow the Object Storage instance read access to the Key Protect instance.
- A regional bucket with BYOK KMS encryption.
- A cross-regional bucket with KMS encryption.
- A single-site-location bucket with hard quota.
- A basic VPC and subnet.
- A Context-based restriction (CBR) network zone containing the VPC.
- CBR rules that allow only the VPC to access the Object Storage instance and buckets over the private endpoint.
