<!-- BEGIN MODULE HOOK -->
# Cloud Object Storage Module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module can be used to provision and configure a [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) instance and bucket. It can also be used to just provision buckets.

You can configure the following aspects of your instances:
1. [Bucket encryption](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tutorial-kp-encrypt-bucket) - based on Key Protect keys
2. [Activity tracking](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tracking-cos-events) and auditing
3. [Monitoring](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-monitoring-cos)
4. Data retention, [lifecycle](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-archive) and archiving options


## Usage
There is currently an [enhancement request](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4256) open with the IBM terraform provider to support enabling metrics for Key Protect. Until then, this module uses the restapi provider to enable metrics since it support provisioning and configuring Key Protect for COS encryption.

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# Retrieve IAM access token (required for restapi provider)
data "ibm_iam_auth_token" "token_data" {
}

provider "restapi" {
  uri                   = "https:"
  write_returns_object  = false
  create_returns_object = false
  debug                 = false
  headers = {
    Authorization    = data.ibm_iam_auth_token.token_data.iam_access_token
    Bluemix-Instance = module.cos_module.key_protect_instance_guid
    Content-Type     = "application/vnd.ibm.kms.policy+json"
  }
}

# Creates:
# - Key Protect + Key Ring + Key
# - COS instance
# - COS bucket with retention, encryption, monitoring and activity tracking
module "cos_module" {
  # Replace "main" with a GIT release version to lock into a specific release
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  resource_group_id         = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                    = "us-south"
  cos_instance_name         = "my-cos-instance"
  bucket_name               = "my-cos-bucket"
  key_protect_instance_name = "my-key-protect-instance"
  cos_key_ring_name         = "cos-key-ring"
  cos_key_name              = "cos-key"
  sysdig_crn                = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn      = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
}

# Creates additional bucket in instance created above:
module "additional_cos_bucket" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  bucket_name                        = "additional-bucket"
  resource_group_id                  = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                             = "us-south"
  sysdig_crn                         = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn               = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  create_cos_instance                = false
  create_key_protect_instance        = false
  existing_cos_instance_id           = module.cos_module.cos_instance_id
  key_protect_key_crn                = module.cos_module.key_protect_key_crn
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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.48.0 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | >= 1.18.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kp_all_inclusive"></a> [kp\_all\_inclusive](#module\_kp\_all\_inclusive) | git::https://github.com/terraform-ibm-modules/terraform-ibm-key-protect-all-inclusive.git | v3.0.0 |

## Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket.cos_bucket](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_cos_bucket.cos_bucket1](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.cos_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | Activity tracker crn for COS bucket (Optional) | `string` | `null` | no |
| <a name="input_archive_days"></a> [archive\_days](#input\_archive\_days) | Specifies the number of days when the archive rule action takes effect. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_archive_type"></a> [archive\_type](#input\_archive\_type) | Specifies the storage class or archive type to which you want the object to transition. Only used if 'create\_cos\_bucket' is true. | `string` | `"Glacier"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name to give the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create\_cos\_instance' is true. | `string` | `null` | no |
| <a name="input_cos_key_name"></a> [cos\_key\_name](#input\_cos\_key\_name) | The name of the Key Protect Key to create. This key will be used to encrypt the data in the COS Bucket, and will be created in the specified Key Ring passed to this module using either var.cos\_key\_ring\_name or var.existing\_cos\_key\_ring\_name. | `string` | `"cos-key"` | no |
| <a name="input_cos_key_ring_name"></a> [cos\_key\_ring\_name](#input\_cos\_key\_ring\_name) | The name of a new Key Ring to create in the Key Protect instance. The Key name specified in var.cos\_key\_name will be created in this Key Ring. | `string` | `"cos-key-ring"` | no |
| <a name="input_cos_location"></a> [cos\_location](#input\_cos\_location) | Location to provision the cloud object storage instance. Only used if 'create\_cos\_instance' is true. | `string` | `"global"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan to be used for creating cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | Optional list of tags to be added to cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_bucket"></a> [create\_cos\_bucket](#input\_create\_cos\_bucket) | Set as true to create a new Cloud Object Storage bucket | `bool` | `true` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Set as true to create a new Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_create_key_protect_instance"></a> [create\_key\_protect\_instance](#input\_create\_key\_protect\_instance) | Set as true to create a new Key Protect instance. This instance will store the Key used to encrypt the data in the COS Bucket | `bool` | `true` | no |
| <a name="input_create_key_protect_key"></a> [create\_key\_protect\_key](#input\_create\_key\_protect\_key) | Set as true to create a new Key Protect Key. This key is used to encrypt the COS Bucket | `bool` | `true` | no |
| <a name="input_enable_key_protect_metrics"></a> [enable\_key\_protect\_metrics](#input\_enable\_key\_protect\_metrics) | Enable Key Protect metrics. Only used if if 'var.create\_key\_protect\_instance' is true. | `string` | `true` | no |
| <a name="input_encryption_enabled"></a> [encryption\_enabled](#input\_encryption\_enabled) | Set as true to use Key Protect encryption to encrypt data in COS bucket | `bool` | `true` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if 'var.create\_cos\_instance' is false. | `string` | `null` | no |
| <a name="input_existing_cos_key_ring_name"></a> [existing\_cos\_key\_ring\_name](#input\_existing\_cos\_key\_ring\_name) | The name of an existing Key Ring in which to create the new Key specified in var.cos\_key\_name | `string` | `null` | no |
| <a name="input_existing_key_protect_instance_guid"></a> [existing\_key\_protect\_instance\_guid](#input\_existing\_key\_protect\_instance\_guid) | The GUID of an existing Key Protect instance. Required if 'var.create\_key\_protect\_instance' is false. | `string` | `null` | no |
| <a name="input_expire_days"></a> [expire\_days](#input\_expire\_days) | Specifies the number of days when the expire rule action takes effect. Only used if 'create\_cos\_bucket' is true. | `number` | `365` | no |
| <a name="input_key_protect_instance_name"></a> [key\_protect\_instance\_name](#input\_key\_protect\_instance\_name) | The name to give the Key Protect instance that will be provisioned by this module. Required if 'var.create\_key\_protect\_instance' is true | `string` | `null` | no |
| <a name="input_key_protect_key_crn"></a> [key\_protect\_key\_crn](#input\_key\_protect\_key\_crn) | CRN of the Key Protect Key to use if not creating a Key in this module, this Key Protect Key is used to encrypt the data in the COS Bucket | `string` | `null` | no |
| <a name="input_key_protect_tags"></a> [key\_protect\_tags](#input\_key\_protect\_tags) | Optional list of tags to be added to Key Protect instance. Only used if 'var.create\_key\_protect\_instance' is true. | `list(string)` | `[]` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to provision COS bucket. Also used when creating Key Protect / Key Protect Keys for encryption. NOTE: If 'var.encryption\_enabled' is true and an existing Key Protect instance is passed in using 'var.existing\_key\_protect\_instance\_guid', this must be the region of the existing Key Protect instance. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_retention_default"></a> [retention\_default](#input\_retention\_default) | Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_enabled"></a> [retention\_enabled](#input\_retention\_enabled) | Retention enabled for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `true` | no |
| <a name="input_retention_maximum"></a> [retention\_maximum](#input\_retention\_maximum) | Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `350` | no |
| <a name="input_retention_minimum"></a> [retention\_minimum](#input\_retention\_minimum) | Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_permanent"></a> [retention\_permanent](#input\_retention\_permanent) | Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_sysdig_crn"></a> [sysdig\_crn](#input\_sysdig\_crn) | Sysdig Monitoring crn for COS bucket (Optional) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket id |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket Name |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_key_protect_instance_guid"></a> [key\_protect\_instance\_guid](#output\_key\_protect\_instance\_guid) | The GUID of the Key Protect Instance where the Key to encrypt the COS Bucket is stored |
| <a name="output_key_protect_key_crn"></a> [key\_protect\_key\_crn](#output\_key\_protect\_key\_crn) | The CRN of the Key Protect Key used to encrypt the COS Bucket |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
| <a name="output_s3_endpoint_private"></a> [s3\_endpoint\_private](#output\_s3\_endpoint\_private) | S3 private endpoint |
| <a name="output_s3_endpoint_public"></a> [s3\_endpoint\_public](#output\_s3\_endpoint\_public) | S3 public endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
