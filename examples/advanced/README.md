# Advanced example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cos-advanced-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/examples/advanced"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- A service ID that is used to generate resource keys.
- A Key Protect instance, a key ring, and 2 root keys in the given resource group and region.
- An IBM Cloud Object Storage instance in the given resource group and region.
- An IBM Cloud Object Storage Backup Vault.
- An IAM authorization policy to allow the Object Storage instance read access to the Key Protect instance.
- A regional bucket with BYOK KMS encryption.
- A cross-regional bucket with KMS encryption.
- A single-site-location bucket with hard quota.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
