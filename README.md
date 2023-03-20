<!-- BEGIN MODULE HOOK -->
# Cloud Object Storage Module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![Build Status](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-cos?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-cos/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

This module can be used to provision and configure a [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) instance and/or bucket.

You can configure the following aspects of your instances:
1. [Bucket encryption](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tutorial-kp-encrypt-bucket) - based on Key Protect keys
2. [Activity tracking](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tracking-cos-events) and auditing
3. [Monitoring](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-monitoring-cos)
4. Data retention, [lifecycle](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-archive) and archiving options

## Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

# Creates:
# - COS instance
# - COS bucket with retention, encryption, monitoring and activity tracking
module "cos_module" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                             = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos?ref=main"
  resource_group_id                  = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  region                             = "us-south"
  cos_instance_name                  = "my-cos-instance"
  bucket_name                        = "my-cos-bucket"
  existing_key_protect_instance_guid = "xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx"
  key_protect_key_crn                = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
  sysdig_crn                         = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn               = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
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
  existing_cos_instance_id           = module.cos_module.cos_instance_id
  key_protect_key_crn                = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
}
```

## Known issues

An IBM Cloud Provider issue [4357](https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4357) has been raised
to report that the use of bucket_types does not work. When 'private' is selected, the provider attempts to use private
endpoints (on the COS instance) to create the bucket which fails due to the endpoints being unreachable from deployment environment.

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
- [ Financial Services Cloud Profile example](examples/fscloud)
- [ Cloud Object Storage replication example](examples/replication)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bucket_cbr_rule"></a> [bucket\_cbr\_rule](#module\_bucket\_cbr\_rule) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module | v1.1.4 |
| <a name="module_instance_cbr_rule"></a> [instance\_cbr\_rule](#module\_instance\_cbr\_rule) | git::https://github.com/terraform-ibm-modules/terraform-ibm-cbr//cbr-rule-module | v1.1.4 |

## Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket.cos_bucket](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_cos_bucket.cos_bucket1](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_resource_instance.cos_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_instance) | resource |
| [ibm_resource_key.resource_key](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/resource_key) | resource |
| [null_resource.deprecation_notice](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | Activity tracker crn for COS bucket (Optional) | `string` | `null` | no |
| <a name="input_archive_days"></a> [archive\_days](#input\_archive\_days) | Specifies the number of days when the archive rule action takes effect. Only used if 'create\_cos\_bucket' is true. This must be set to null when when using var.cross\_region\_location as archive data is not supported with this feature. | `number` | `90` | no |
| <a name="input_archive_type"></a> [archive\_type](#input\_archive\_type) | Specifies the storage class or archive type to which you want the object to transition. Only used if 'create\_cos\_bucket' is true. | `string` | `"Glacier"` | no |
| <a name="input_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#input\_bucket\_cbr\_rules) | (Optional, list) List of CBR rules to create for the bucket | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_endpoint"></a> [bucket\_endpoint](#input\_bucket\_endpoint) | The type of endpoint to use for the bucket. (public, private, direct). Provider issue 4357 reports that private does not work | `string` | `"public"` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name to give the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | the storage class of the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. Supported values are 'standard', 'vault', 'cold', and 'smart'. | `string` | `"standard"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create\_cos\_instance' is true. | `string` | `null` | no |
| <a name="input_cos_location"></a> [cos\_location](#input\_cos\_location) | Location to provision the cloud object storage instance. Only used if 'create\_cos\_instance' is true. | `string` | `"global"` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan to be used for creating cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | Optional list of tags to be added to cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_bucket"></a> [create\_cos\_bucket](#input\_create\_cos\_bucket) | Set as true to create a new Cloud Object Storage bucket | `bool` | `true` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Set as true to create a new Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_create_hmac_key"></a> [create\_hmac\_key](#input\_create\_hmac\_key) | Set as true to create a new HMAC key for the Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_cross_region_location"></a> [cross\_region\_location](#input\_cross\_region\_location) | Specify the cross-regional bucket location. Supported values are 'us', 'eu', and 'ap'. If you pass a value for this, ensure to set the value of var.region to null. | `string` | `null` | no |
| <a name="input_encryption_enabled"></a> [encryption\_enabled](#input\_encryption\_enabled) | Set as true to use Key Protect encryption to encrypt data in COS bucket (only applicable when var.create\_cos\_bucket is true). | `bool` | `true` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if 'var.create\_cos\_instance' is false. | `string` | `null` | no |
| <a name="input_existing_key_protect_instance_guid"></a> [existing\_key\_protect\_instance\_guid](#input\_existing\_key\_protect\_instance\_guid) | The GUID of the Key Protect or Hyper Protect instance in which the key specified in var.key\_protect\_key\_crn is coming from. Required if var.skip\_iam\_authorization\_policy is false in order to create an IAM Access Policy to allow Key protect or Hyper Protect to access the newly created COS instance. | `string` | `null` | no |
| <a name="input_expire_days"></a> [expire\_days](#input\_expire\_days) | Specifies the number of days when the expire rule action takes effect. Only used if 'create\_cos\_bucket' is true. | `number` | `365` | no |
| <a name="input_hmac_key_name"></a> [hmac\_key\_name](#input\_hmac\_key\_name) | The name of the hmac key to be created. | `string` | `"hmac-cos-key"` | no |
| <a name="input_hmac_key_role"></a> [hmac\_key\_role](#input\_hmac\_key\_role) | The role you want to be associated with your new hmac key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'. | `string` | `"Manager"` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | (Optional, list) List of CBR rules to create for the instance | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_key_protect_key_crn"></a> [key\_protect\_key\_crn](#input\_key\_protect\_key\_crn) | CRN of the Key Protect Key to use to encrypt the data in the COS Bucket. Required if var.encryption\_enabled and var.create\_cos\_bucket are true. | `string` | `null` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Enable object versioning to keep multiple versions of an object in a bucket. Cannot be used with retention rule. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to provision the bucket. If you pass a value for this, do not pass one for var.cross\_region\_location. | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_key_existing_serviceid_crn"></a> [resource\_key\_existing\_serviceid\_crn](#input\_resource\_key\_existing\_serviceid\_crn) | CRN of existing serviceID to bind with resource key to be created. If null a new ServiceID is created for the resource key. | `string` | `null` | no |
| <a name="input_retention_default"></a> [retention\_default](#input\_retention\_default) | Specifies default duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_enabled"></a> [retention\_enabled](#input\_retention\_enabled) | Retention enabled for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `true` | no |
| <a name="input_retention_maximum"></a> [retention\_maximum](#input\_retention\_maximum) | Specifies maximum duration of time an object that can be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `350` | no |
| <a name="input_retention_minimum"></a> [retention\_minimum](#input\_retention\_minimum) | Specifies minimum duration of time an object must be kept unmodified for COS bucket. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_retention_permanent"></a> [retention\_permanent](#input\_retention\_permanent) | Specifies a permanent retention status either enable or disable for COS bucket. Only used if 'create\_cos\_bucket' is true. | `bool` | `false` | no |
| <a name="input_service_endpoints"></a> [service\_endpoints](#input\_service\_endpoints) | (Deprecated) Will be removed in the next major release | `string` | `null` | no |
| <a name="input_skip_iam_authorization_policy"></a> [skip\_iam\_authorization\_policy](#input\_skip\_iam\_authorization\_policy) | Set to true to skip the creation of an IAM authorization policy that permits the COS instance created to read the encryption key from the Key Protect instance in `existing_key_protect_instance_guid`. WARNING: An authorization policy must exist before an encrypted bucket can be created | `bool` | `false` | no |
| <a name="input_sysdig_crn"></a> [sysdig\_crn](#input\_sysdig\_crn) | Sysdig Monitoring crn for COS bucket (Optional) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_crn"></a> [bucket\_crn](#output\_bucket\_crn) | Bucket CRN |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket id |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Bucket Name |
| <a name="output_bucket_storage_class"></a> [bucket\_storage\_class](#output\_bucket\_storage\_class) | Bucket Storage Class |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | The GUID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Cloud Object Storage Instance where the buckets are created |
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
