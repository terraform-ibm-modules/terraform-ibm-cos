# Basic Example

This example creates the following infrastructure:
- A new resource group, if one is not passed in.
- A new service ID which will be used for resource key generation.
- A new standard Cloud Object Storage instance and a regional public bucket in the given resource group and region.
- A second bucket in the newly provisioned COS instance using the [buckets](../../modules/buckets) submodule
