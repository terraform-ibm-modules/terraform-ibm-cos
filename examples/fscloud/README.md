# Financial Services compliant example

This example uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/fscloud) to provision a Cloud Object Storage instance and a KYOK HPCS encrypted bucket with activity tracking, monitoring and CBR rules enabled.


Resources provisioned by this example:
- A new resource group, if existing one is not passed in.
- A Sysdig and Activity Tracker instance (if existing one is not passed in) in the given resource group and region.
- A Cloud Object Storage instance in the given resource group and region.
- An IAM auth policy to allow the COS instance read access to the given HPCS instance.
- A regional bucket with KYOK HPCS encryption, monitoring and activity tracking enabled
- A basic VPC and subnet.
- A Context Based Restriction (CBR) network zone containing the VPC.
- Context Based Restriction (CBR) rules to only allow the COS instance and bucket to be accessible from within VPC over the private endpoint.

:exclamation: **Important:** In this example, only the IBM Cloud Object Storage instance and buckets complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

Before you run the example, make sure that you set up the following prerequisites:

- A Hyper Protect Crypto Service instance and root key.
