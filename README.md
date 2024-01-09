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
  sysdig_crn                 = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn       = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
}

# Creates additional buckets in existing instance:
module "additional_cos_bucket" {
  source                   = "terraform-ibm-modules/cos/ibm"
  version                  = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  resource_group_id        = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                   = "us-south"
  create_cos_instance      = false
  sysdig_crn               = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn     = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
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
      resource_group_id    = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
      resource_instance_id = module.cos_module.cos_instance_id
    },
    {
      bucket_name            = "my-versioned-bucket"
      kms_encryption_enabled = false
      region_location        = "us-south"
      resource_group_id      = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
      resource_instance_id   = module.cos_module.cos_instance_id
      object_versioning = {
        enable = true
      }
    },
    {
      bucket_name            = "my-archive-bucket"
      kms_encryption_enabled = false
      region_location        = "us-south"
      resource_group_id      = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, < 2.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1, < 4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket_cbr_rule"></a> [bucket\_cbr\_rule](#module\_bucket\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.17.1 |
| <a name="module_instance_cbr_rule"></a> [instance\_cbr\_rule](#module\_instance\_cbr\_rule) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.17.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket.cos_bucket](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_cos_bucket.cos_bucket1](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.cos_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [ibm_resource_tag.cos_access_tag](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_tag) | resource |
| [random_string.bucket_name_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [terraform_data.generate_hmac_credentials](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.resource_key_existing_serviceid_crn](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_for_authorization_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the cos instance created by the module, see https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial for more details | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | Activity tracker crn for COS bucket (Optional) | `string` | `null` | no |
| <a name="input_add_bucket_name_suffix"></a> [add\_bucket\_name\_suffix](#input\_add\_bucket\_name\_suffix) | Add random generated suffix (4 characters long) to the newly provisioned COS bucket name (Optional). | `bool` | `false` | no |
| <a name="input_archive_days"></a> [archive\_days](#input\_archive\_days) | Specifies the number of days when the archive rule action takes effect. Only used if 'create\_cos\_bucket' is true. This must be set to null when when using var.cross\_region\_location as archive data is not supported with this feature. | `number` | `90` | no |
| <a name="input_archive_type"></a> [archive\_type](#input\_archive\_type) | Specifies the storage class or archive type to which you want the object to transition. Only used if 'create\_cos\_bucket' is true. | `string` | `"Glacier"` | no |
| <a name="input_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#input\_bucket\_cbr\_rules) | (Optional, list) List of CBR rules to create for the bucket | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name to give the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | the storage class of the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. Supported values are 'standard', 'vault', 'cold', 'smart' and `onerate_active`. | `string` | `"standard"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create\_cos\_instance' is true. | `string` | `null` | no |
| <a name="input_cos_location"></a> [cos\_location](#input\_cos\_location) | Location to provision the cloud object storage instance. Only used if 'create\_cos\_instance' is true. | `string` | `"global"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan to be used for creating cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | Optional list of tags to be added to cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_bucket"></a> [create\_cos\_bucket](#input\_create\_cos\_bucket) | Set as true to create a new Cloud Object Storage bucket | `bool` | `true` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Set as true to create a new Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_create_resource_key"></a> [create\_resource\_key](#input\_create\_resource\_key) | Set as true to create a new resource key for the Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_cross_region_location"></a> [cross\_region\_location](#input\_cross\_region\_location) | Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'. If you pass a value for this, ensure to set the value of var.region to null. | `string` | `null` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if 'var.create\_cos\_instance' is false. | `string` | `null` | no |
| <a name="input_existing_kms_instance_guid"></a> [existing\_kms\_instance\_guid](#input\_existing\_kms\_instance\_guid) | The GUID of the Key Protect or Hyper Protect instance in which the key specified in var.kms\_key\_crn is coming from. Required if var.skip\_iam\_authorization\_policy is false in order to create an IAM Access Policy to allow Key Protect or Hyper Protect to access the newly created COS instance. | `string` | `null` | no |
| <a name="input_expire_days"></a> [expire\_days](#input\_expire\_days) | Specifies the number of days when the expire rule action takes effect. Only used if 'create\_cos\_bucket' is true. | `number` | `365` | no |
| <a name="input_generate_hmac_credentials"></a> [generate\_hmac\_credentials](#input\_generate\_hmac\_credentials) | Set as true to generate an HMAC key in the resource key. Only used when create\_resource\_key is `true`. | `bool` | `false` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | (Optional, list) List of CBR rules to create for the instance | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_kms_encryption_enabled"></a> [kms\_encryption\_enabled](#input\_kms\_encryption\_enabled) | Set as true to use KMS key encryption to encrypt data in COS bucket (only applicable when var.create\_cos\_bucket is true). | `bool` | `true` | no |
| <a name="input_kms_key_crn"></a> [kms\_key\_crn](#input\_kms\_key\_crn) | CRN of the KMS key to use to encrypt the data in the COS bucket. Required if var.encryption\_enabled and var.create\_cos\_bucket are true. | `string` | `null` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to use to manage the bucket. (public, private or direct) | `string` | `"public"` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the bucket. If you pass a value for this, do not pass one for var.cross\_region\_location. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_key_existing_serviceid_crn"></a> [resource\_key\_existing\_serviceid\_crn](#input\_resource\_key\_existing\_serviceid\_crn) | CRN of existing serviceID to bind with resource key to be created. If null a new ServiceID is created for the resource key. | `string` | `null` | no |
| <a name="input_resource_key_name"></a> [resource\_key\_name](#input\_resource\_key\_name) | The name of the resource key to be created. | `string` | `"hmac-cos-key"` | no |
| <a name="input_resource_key_role"></a> [resource\_key\_role](#input\_resource\_key\_role) | The role you want to be associated with your new resource key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'. | `string` | `"Manager"` | no |
| <a name="input_retention_default"></a> [retention\_default](#input\_retention\_default) | Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_enabled"></a> [retention\_enabled](#input\_retention\_enabled) | Retention enabled for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_retention_maximum"></a> [retention\_maximum](#input\_retention\_maximum) | Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `350` | no |
| <a name="input_retention_minimum"></a> [retention\_minimum](#input\_retention\_minimum) | Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_permanent"></a> [retention\_permanent](#input\_retention\_permanent) | Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the KMS instance in `existing_kms_instance_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created | `bool` | `false` | no |
| <a name="input_sysdig_crn"></a> [sysdig\_crn](#input\_sysdig\_crn) | Sysdig Monitoring crn for COS bucket (Optional) | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#output\_bucket\_cbr\_rules) | COS bucket rules |
| <a name="output_bucket_crn"></a> [bucket\_crn](#output\_bucket\_crn) | Bucket CRN |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket id |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket name |
| <a name="output_bucket_storage_class"></a> [bucket\_storage\_class](#output\_bucket\_storage\_class) | Bucket Storage Class |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | List of all rule ids |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | The GUID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_instance_cbr_rules"></a> [instance\_cbr\_rules](#output\_instance\_cbr\_rules) | COS instance rules |
| <a name="output_kms_key_crn"></a> [kms\_key\_crn](#output\_kms\_key\_crn) | The CRN of the KMS key used to encrypt the COS bucket |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
| <a name="output_s3_endpoint_direct"></a> [s3\_endpoint\_direct](#output\_s3\_endpoint\_direct) | S3 direct endpoint |
| <a name="output_s3_endpoint_private"></a> [s3\_endpoint\_private](#output\_s3\_endpoint\_private) | S3 private endpoint |
| <a name="output_s3_endpoint_public"></a> [s3\_endpoint\_public](#output\_s3\_endpoint\_public) | S3 public endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
