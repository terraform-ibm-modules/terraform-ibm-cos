# Basic example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cos-basic-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/examples/basic"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


A simple example that shows how to provision a basic Object Storage instance and buckets.

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A standard IBM Cloud Object Storage instance (One Rate plan) and a regional public bucket (using one rate storage) in the given resource group and region.
- A second one rate storage bucket in the newly provisioned Object Storage instance from the [buckets](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/buckets) submodule.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
