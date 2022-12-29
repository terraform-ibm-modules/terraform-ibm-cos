<!-- BEGIN MODULE HOOK -->
# Cloud Object Storage Module

 [![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
 [![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml)
 [![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
 [![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
 [![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/releases/latest)

This module can be used to provision and configure a [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) instance and bucket. It can also be used to just provision buckets.

You can configure the following aspects of your instances:
1. [Bucket encryption](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tutorial-kp-encrypt-bucket) - based on Key Protect keys
2. [Activity tracking](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tracking-cos-events) and auditing
3. [Monitoring](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-monitoring-cos)
4. Data retention, [lifecycle](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-archive) and archiving options


## Usage

### Example 1
An instance and a bucket with monitoring and encryption
```hcl
# Replace "main" with a GIT release version to lock into a specific release
module "cos_module" {
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  environment_name  = "us-staging"
  resource_group_id = var.resource_group_id
  ibm_region        = "us-south"
  sysdig_crn = var.sysdig_crn
  activity_tracker_crn = var.activity_tracker_crn
}
```

### Example 2
Two buckets only with monitoring and encryption using existing COS and Key Protect Instances

```hcl
# Replace "main" with a GIT release version to lock into a specific release
module "cos_bucket1" {
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  environment_name     = "us-staging"
  resource_group_id    = var.resource_group_id
  region               = "us-south"
  sysdig_crn           = var.sysdig_crn
  activity_tracker_crn = var.activity_tracker_crn
  bucket_infix         = "bucket1"
  create_cos_instance         = false
  create_key_protect_instance = false
  cos_instance_name           = "us-staging-cos"
  key_protect_instance_name   = "us-staging-kms"
}

# Replace "main" with a GIT release version to lock into a specific release
module "cos_bucket2" {
  source               = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  environment_name     = "us-staging"
  resource_group_id    = var.resource_group_id
  region               = "us-south"
  sysdig_crn           = var.sysdig_crn
  activity_tracker_crn = var.activity_tracker_crn
  bucket_infix         = "bucket2"
  create_cos_instance         = false
  create_key_protect_instance = false
  cos_instance_name           = "us-staging-cos"
  key_protect_instance_name   = "us-staging-kms"
}
```
### Note
You will need to configure the RESTAPI provider which is needed for encryption. [See a full example here](examples/bucket-without-tracking-monitoring/providers.tf)
```hcl
# used by the restapi provider to authenticate the API call based on API key
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false # set to true to show detailed logs, but use carefully as it might print sensitive values.
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.cos.key_protect_instance_id
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}

```

## Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **IBM Cloud Activity Tracker** service
        - `Editor` platform access
        - `Manager` service access
    - **IBM Cloud Monitoring** service
        - `Editor` platform access
        - `Manager` service access
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access


<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Complete Example (multiple COS Buckets with retention, encryption, tracking and monitoring enabled)](examples/complete)
- [ COS Bucket without encryption using an existing COS instance and Key Protect instance + Keys](examples/existing-resources)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
