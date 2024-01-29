# Financial Services compliant example

This example uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/fscloud) to provision an IBM Cloud Object Storage instance and a Hyper Protect Crypto Services (HPCS) bucket encrypted with KYOK. The resources include activity tracking, monitoring, and context-based restriction (CBR) rules.


The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- An IBM Cloud Monitoring instance in the given resource group and region.
- An IBM Cloud Activity Tracker instance, if existing ones is not passed in, in the given resource group and region.
- An IBM Cloud Object Storage instance in the given resource group and region.
- An IAM authorization policy to allow the Object Storage instance read access to the Key Protect instance.
- A regional bucket with KYOK Hyper Protect Crypto Services (HPCS) encryption, monitoring, and activity tracking enabled.
- A basic VPC and subnet.
- A Context-based restriction (CBR) network zone containing the VPC.
- A Context-based restriction network zone containing the schematics service.
- CBR rules that allow only the VPC and schematics to access the Object Storage instance and buckets over the private endpoint.

**Important:** In this example, only the IBM Cloud Object Storage instance and buckets complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

Before you run the example, make sure that you set up the following prerequisites:

- A Hyper Protect Crypto Service instance and root key.