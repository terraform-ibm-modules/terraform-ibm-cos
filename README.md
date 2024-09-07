# Cloud Object Storage module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![Catalog release](https://img.shields.io/badge/release-IBM%20Cloud%20Catalog-3662FF?logo=ibm)](https://cloud.ibm.com/catalog/modules/terraform-ibm-cos-18cdd8f4-40c5-4fbf-9d62-1dd86a2deab3-global)

Use this module to provision and configure an IBM [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) instance and bucket.

In addition, a [buckets](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/modules/buckets) submodule supports creating multiple buckets in an existing instance.

You can configure the following aspects of your instances:
- [Key management service (KMS) encryption](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-encryption)
- [Activity tracking](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tracking-cos-events) and auditing
- [Monitoring](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-monitoring-cos)
- Data retention, [lifecycle](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-archive) and archiving options

<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-cos](#terraform-ibm-cos)
* [Submodules](./modules)
    * [buckets](./modules/buckets)
    * [fscloud](./modules/fscloud)
* [Examples](./examples)
    * [Advanced example](./examples/advanced)
    * [Basic example](./examples/basic)
    * [Bucket replication example](./examples/replication)
    * [Financial Services compliant example](./examples/fscloud)
    * [One Rate plan example](./examples/one-rate-plan)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->

## terraform-ibm-cos

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

# Creates:
# - COS instance
# - COS buckets with retention, encryption, monitoring and activity tracking
module "cos_module" {
  source                     = "terraform-ibm-modules/cos/ibm"
  version                    = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id          = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                     = "us-south"
  cos_instance_name          = "my-cos-instance"
  bucket_name                = "my-cos-bucket"
  existing_kms_instance_guid = "xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx"
  kms_key_crn                = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
}

# Creates additional buckets in existing instance:
module "additional_cos_bucket" {
  source                   = "terraform-ibm-modules/cos/ibm"
  version                  = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  region                   = "us-south"
  create_cos_instance      = false
  existing_cos_instance_id = module.cos_module.cos_instance_id
  kms_key_crn              = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
}

# Creates additional Cloud Object Storage buckets using the buckets sub module
module "cos_buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  bucket_configs = [
    {
      bucket_name          = "my-encrypted-bucket"
      kms_key_crn          = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
      region_location      = "us-south"
      resource_instance_id = module.cos_module.cos_instance_id
    },
    {
      bucket_name            = "my-versioned-bucket"
      kms_encryption_enabled = false
      region_location        = "us-south"
      resource_instance_id   = module.cos_module.cos_instance_id
      object_versioning = {
        enable = true
      }
    },
    {
      bucket_name            = "my-archive-bucket"
      kms_encryption_enabled = false
      region_location        = "us-south"
      resource_instance_id   = module.cos_module.cos_instance_id
      archive_rule = {
        days   = 90
        enable = true
        type   = "Accelerated"
      }
      expire_rule = {
        days   = 90
        enable = true
      }
    }
  ]
}
```

### Required IAM access policies

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

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.67.0, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket_cbr_rule"></a> [bucket\_cbr\_rule](#module\_bucket\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.24.1 |
| <a name="module_instance_cbr_rule"></a> [instance\_cbr\_rule](#module\_instance\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.24.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket.cos_bucket](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_cos_bucket.cos_bucket1](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_cos_bucket_object_lock_configuration.lock_configuration](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket_object_lock_configuration) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.cos_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_keys](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.cos_access_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [random_string.bucket_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | The CRN of an Activity Tracker instance to send Object Storage bucket events to. If no value passed, events are sent to the instance associated to the container's location unless otherwise specified in the Activity Tracker Event Routing service configuration. Bucket management events are always enabled if a value is passed, regardless of the value of `activity_tracker_management_events`. | `string` | `null` | no |
| <a name="input_activity_tracker_management_events"></a> [activity\_tracker\_management\_events](#input\_activity\_tracker\_management\_events) | If set to true, all Object Storage management events will be sent to Activity Tracker. Only applies if `activity_tracker_crn` is not populated. | `bool` | `true` | no |
| <a name="input_activity_tracker_read_data_events"></a> [activity\_tracker\_read\_data\_events](#input\_activity\_tracker\_read\_data\_events) | If set to true, all Object Storage bucket read events (i.e. downloads) will be sent to Activity Tracker. | `bool` | `true` | no |
| <a name="input_activity_tracker_write_data_events"></a> [activity\_tracker\_write\_data\_events](#input\_activity\_tracker\_write\_data\_events) | If set to true, all Object Storage bucket write events (i.e. uploads) will be sent to Activity Tracker. | `bool` | `true` | no |
| <a name="input_add_bucket_name_suffix"></a> [add\_bucket\_name\_suffix](#input\_add\_bucket\_name\_suffix) | Whether to add a randomly generated 4-character suffix to the new bucket name. | `bool` | `false` | no |
| <a name="input_archive_days"></a> [archive\_days](#input\_archive\_days) | The number of days before the `archive_type` rule action takes effect. Applies only if `create_cos_bucket` is true. Set to `null` if you specify a bucket location in `cross_region_location` because archive data is not supported with cross-region buckets. | `number` | `90` | no |
| <a name="input_archive_type"></a> [archive\_type](#input\_archive\_type) | The storage class or archive type to which you want the object to transition. Possible values: `Glacier`, `Accelerated`. Applies only if `create_cos_bucket` is true. | `string` | `"Glacier"` | no |
| <a name="input_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#input\_bucket\_cbr\_rules) | The list of context-based restriction rules to create for the bucket. | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name for the new Object Storage bucket. Applies only if `create_cos_bucket` is true. | `string` | `null` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | The storage class of the new bucket. Required only if `create_cos_bucket` is true. Possible values: `standard`, `vault`, `cold`, `smart`, `onerate_active`. | `string` | `"standard"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name for the IBM Cloud Object Storage instance provisioned by this module. Applies only if `create_cos_instance` is true. | `string` | `null` | no |
| <a name="input_cos_location"></a> [cos\_location](#input\_cos\_location) | The location for the Object Storage instance. Applies only if `create_cos_instance` is true. | `string` | `"global"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | The plan to use when Object Storage instances are created. Possible values: `standard`, `cos-one-rate-plan`. Applies only if `create_cos_instance` is true. For more details refer https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | A list of tags to apply to the Object Storage instance. | `list(string)` | `[]` | no |
| <a name="input_create_cos_bucket"></a> [create\_cos\_bucket](#input\_create\_cos\_bucket) | Whether to create an Object Storage bucket. | `bool` | `true` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Whether to create a IBM Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_cross_region_location"></a> [cross\_region\_location](#input\_cross\_region\_location) | Specify the cross-region bucket location. Possible values: `us`, `eu` `ap`. If specified, set `region` and `single_site_location` to `null`. | `string` | `null` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if `create_cos_instance` is false. | `string` | `null` | no |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Key Protect or Hyper Protect Crypto Services instance that holds the key specified in `kms_key_crn`. Required if `skip_iam_authorization_policy` is false. | `string` | `null` | no |
| <a name="input_expire_days"></a> [expire\_days](#input\_expire\_days) | The number of days before the expire rule action takes effect. Applies only if `create_cos_bucket` is true. | `number` | `365` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | Whether to delete all the objects in the Object Storage bucket before the bucket is deleted. | `bool` | `true` | no |
| <a name="input_hard_quota"></a> [hard\_quota](#input\_hard\_quota) | The maximum amount of available storage in bytes for a bucket. If set to `null`, the quota is disabled. | `number` | `null` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | The list of context-based restriction rules to create for the instance. | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Whether to use KMS key encryption to encrypt data in Object Storage buckets. Applies only if `create_cos_bucket` is true. | `bool` | `true` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | The CRN of the KMS key to encrypt the data in the Object Storage bucket. Required if `kms_encryption_enabled` and `create_cos_bucket` are true. | `string` | `null` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to manage the bucket. Possible values: `public`, `private`, `direct`. | `string` | `"public"` | no |
| <a name="input_monitoring_crn"></a> [monitoring\_crn](#input\_monitoring\_crn) | The CRN of an IBM Cloud Monitoring instance to to send Object Storage bucket metrics to. If no value passed, metrics are sent to the instance associated to the container's location unless otherwise specified in the Metrics Router service configuration. | `string` | `null` | no |
| <a name="input_object_lock_duration_days"></a> [object\_lock\_duration\_days](#input\_object\_lock\_duration\_days) | The number of days for the object lock duration. If you specify a number of days, do not specify a value for `object_lock_duration_years`. Applies only if `create_cos_bucket` is true. | `number` | `0` | no |
| <a name="input_object_lock_duration_years"></a> [object\_lock\_duration\_years](#input\_object\_lock\_duration\_years) | The number of years for the object lock duration. If you specify a number of years, do not specify a value for `object_lock_duration_days`. Applies only if `create_cos_bucket` is true. | `number` | `0` | no |
| <a name="input_object_locking_enabled"></a> [object\_locking\_enabled](#input\_object\_locking\_enabled) | Whether to create an object lock configuration. Applies only if `object_versioning_enabled` and `create_cos_bucket` are true. | `bool` | `false` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Whether to enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Applies only if `create_cos_bucket` is true. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the bucket. If specified, set `cross_region_location` and `single_site_location` to `null`. | `string` | `"us-south"` | no |
| <a name="input_request_metrics_enabled"></a> [request\_metrics\_enabled](#input\_request\_metrics\_enabled) | If set to `true`, all Object Storage bucket request metrics will be sent to the monitoring service. | `bool` | `true` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID for the new Object Storage instance. Required only if `create_cos_instance` is true. | `string` | `null` | no |
| <a name="input_resource_keys"></a> [resource\_keys](#input\_resource\_keys) | The definition of the resource keys to generate. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/resource_key). | <pre>list(object({<br>    name                      = string<br>    key_name                  = optional(string, null)<br>    generate_hmac_credentials = optional(bool, false)<br>    role                      = optional(string, "Reader")<br>    service_id_crn            = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_retention_default"></a> [retention\_default](#input\_retention\_default) | The number of days that an object can remain unmodified in an Object Storage bucket. Applies only if `create_cos_bucket` is true. | `number` | `90` | no |
| <a name="input_retention_enabled"></a> [retention\_enabled](#input\_retention\_enabled) | Whether retention for the Object Storage bucket is enabled. Applies only if `create_cos_bucket` is true. | `bool` | `false` | no |
| <a name="input_retention_maximum"></a> [retention\_maximum](#input\_retention\_maximum) | The maximum number of days that an object can be kept unmodified in the bucket. Applies only if `create_cos_bucket` is true. | `number` | `350` | no |
| <a name="input_retention_minimum"></a> [retention\_minimum](#input\_retention\_minimum) | The minimum number of days that an object must be kept unmodified in the bucket. Applies only if `create_cos_bucket` is true. | `number` | `90` | no |
| <a name="input_retention_permanent"></a> [retention\_permanent](#input\_retention\_permanent) | Whether permanent retention status is enabled for the Object Storage bucket. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-immutable). Applies only if `create_cos_bucket` is true. | `bool` | `false` | no |
| <a name="input_single_site_location"></a> [single\_site\_location](#input\_single\_site\_location) | The single site bucket location. If specified, set the value of `region` and `cross_region_location` to `null`. | `string` | `null` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Whether to create an IAM authorization policy that permits the Object Storage instance to read the encryption key from the KMS instance. An authorization policy must exist before an encrypted bucket can be created. Set to `true` to avoid creating the policy. If set to `false`, specify a value for the KMS instance in `existing_kms_guid`. | `bool` | `false` | no |
| <a name="input_usage_metrics_enabled"></a> [usage\_metrics\_enabled](#input\_usage\_metrics\_enabled) | If set to `true`, all Object Storage bucket usage metrics will be sent to the monitoring service. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#output\_bucket\_cbr\_rules) | COS bucket rules |
| <a name="output_bucket_crn"></a> [bucket\_crn](#output\_bucket\_crn) | Bucket CRN |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket id |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket name |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | Bucket region if you create a regional bucket |
| <a name="output_bucket_storage_class"></a> [bucket\_storage\_class](#output\_bucket\_storage\_class) | Bucket Storage Class |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | List of all rule ids |
| <a name="output_cos_instance_crn"></a> [cos\_instance\_crn](#output\_cos\_instance\_crn) | The CRN of the Cloud Object Storage instance |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | The GUID of the Cloud Object Storage instance |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Cloud Object Storage instance |
| <a name="output_cos_instance_name"></a> [cos\_instance\_name](#output\_cos\_instance\_name) | The name of the Cloud Object Storage instance |
| <a name="output_instance_cbr_rules"></a> [instance\_cbr\_rules](#output\_instance\_cbr\_rules) | COS instance rules |
| <a name="output_kms_key_crn"></a> [kms\_key\_crn](#output\_kms\_key\_crn) | The CRN of the KMS key used to encrypt the COS bucket |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
| <a name="output_resource_keys"></a> [resource\_keys](#output\_resource\_keys) | List of resource keys |
| <a name="output_s3_endpoint_direct"></a> [s3\_endpoint\_direct](#output\_s3\_endpoint\_direct) | S3 direct endpoint |
| <a name="output_s3_endpoint_private"></a> [s3\_endpoint\_private](#output\_s3\_endpoint\_private) | S3 private endpoint |
| <a name="output_s3_endpoint_public"></a> [s3\_endpoint\_public](#output\_s3\_endpoint\_public) | S3 public endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
