# Basic example

A simple example showing how to provision a basic Object Storage instance and buckets.

Resources provisioned by this example:
- A new resource group, if existing one is not passed in.
- A standard Cloud Object Storage instance and a regional public bucket in the given resource group and region.
- A second bucket in the newly provisioned COS instance using the [buckets](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/buckets) submodule.
