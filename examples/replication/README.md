# Bucket replication example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=cos-replication-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/examples/replication"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An example that shows how to configure replication between two buckets.

:information_source: This basic example creates the IBM Cloud Object Storage instances and buckets in the same account, resource group, and region. It is not designed for production use cases, where replication often requires different regions or accounts. This example uses a single rule to a single destination. Other options are available, including multiple rules, multiple destinations, selective replication, replication of deletes and bi-directional replication (add a rule to the target destination to write to the source).

The following resources are provisioned by this example:

- A new resource group, if an existing one is not passed in.
- One target and one source IBM Cloud Object Storage instance in the given resource group and region.
- One target and one source Object Storage bucket.
- An IAM authorization policy for the source instance to write to the target bucket.
- A replication rule to copy everything from the source bucket to the target bucket.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
