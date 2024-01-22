# Basic example

A simple example that shows how to provision a basic Object Storage instance and buckets.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A standard IBM Cloud Object Storage instance and a regional public bucket in the given resource group and region.
- A second bucket in the newly provisioned Object Storage instance from the [buckets](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/buckets) submodule.

## Note:

To run this exammple, you have to set the values for the environment variables being used in variables.tf or can pass them at the time of running the example.