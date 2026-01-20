# Financial Services compliant example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cos-fscloud-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/examples/fscloud"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


This example uses the [Profile for IBM Cloud Framework for Financial Services](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/fscloud) to provision an IBM Cloud Object Storage instance and a Hyper Protect Crypto Services (HPCS) bucket encrypted with KYOK. The resources include context-based restriction (CBR) rules.


The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- An IBM Cloud Object Storage instance in the given resource group and region.
- An IAM authorization policy to allow the Object Storage instance read access to the Key Protect instance.
- A regional bucket with KYOK Hyper Protect Crypto Services (HPCS) encryption enabled.
- A basic VPC and subnet.
- A Context-based restriction (CBR) network zone containing the VPC.
- A Context-based restriction network zone containing the schematics service.
- CBR rules that allow only the VPC and schematics to access the Object Storage instance and buckets over the private endpoint.

**Important:** In this example, only the IBM Cloud Object Storage instance and buckets complies with the IBM Cloud Framework for Financial Services. Other parts of the infrastructure do not necessarily comply.

## Before you begin

Before you run the example, make sure that you set up the following prerequisites:

- A Hyper Protect Crypto Service instance and root key.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
