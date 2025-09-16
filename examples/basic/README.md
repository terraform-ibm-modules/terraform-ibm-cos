# Basic example

A simple example that shows how to provision a basic Object Storage instance and buckets.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A standard IBM Cloud Object Storage instance (One Rate plan) and a regional public bucket (using one rate storage) in the given resource group and region.
- A second one rate storage bucket in the newly provisioned Object Storage instance from the [buckets](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/buckets) submodule.
