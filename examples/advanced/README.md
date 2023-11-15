# Advanced example

An advanced example which demonstrates creating BYOK KMS encrypted buckets with activity tracking, monitoring and CBR rules enabled.

Resources provisioned by this example:
- A new resource group, if existing one is not passed in.
- A service ID which will be used for resource key generation.
- A Sysdig and Activity Tracker instance (if existing one is not passed in) in the given resource group and region.
- A Key Protect instance (with metrics enabled), key ring, and root key in the given resource group and region.
- A Cloud Object Storage instance in the given resource group and region.
- An IAM auth policy to allow the COS instance read access to the Key Protect instance.
- A regional bucket with BYOK KMS encryption, monitoring and activity tracking enabled
- A cross-regional bucket with KMS encryption, monitoring and activity tracking enabled
- A basic VPC and subnet.
- A Context Based Restriction (CBR) network zone containing the VPC.
- Context Based Restriction (CBR) rules to only allow the COS instance and buckets to be accessible from within VPC over the private endpoint.
