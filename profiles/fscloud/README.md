# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module. The profile assumes you are deploying into an account that is in compliance with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable goals with the following exceptions:

> 3000107 - Check whether Cloud Object Storage network access is restricted to a specific IP range

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Object Storage instance. You can comply with this requirement with the `bucket_cbr_rules` and `instance_cbr_rules` variables in the module. Use these variables to create a narrow context-based restriction rule that is scoped to the IBM Cloud Storage instance. CRA does not support checking for context-based restrictions, so you can ignore the failing rule after you set the context-based restrictions.

> 3000116 - Check whether Cloud Object Storage bucket resiliency is set to cross region

This rule is ignored because the module achieves the same resiliency as cross-regional buckets by provisioning two regional buckets with replication in separate regions. CRA does not validate replication rules, which is why it fails.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.54.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | ../../modules/buckets | n/a |
| <a name="module_cos_instance"></a> [cos\_instance](#module\_cos\_instance) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_replication_rule.cos_replication_rule](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket_replication_rule) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/iam_account_settings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Optional list of access tags to be added to the created resources | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | Activity tracker crn for COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_archive_days"></a> [archive\_days](#input\_archive\_days) | Specifies the number of days when the archive rule action takes effect. Only used if 'create\_cos\_bucket' is true. | `number` | `90` | no |
| <a name="input_archive_type"></a> [archive\_type](#input\_archive\_type) | Specifies the storage class or archive type to which you want the object to transition. Only used if 'create\_cos\_bucket' is true. | `string` | `"Glacier"` | no |
| <a name="input_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#input\_bucket\_cbr\_rules) | (Optional, list) List of CBR rules to create for the bucket | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_bucket_storage_class"></a> [bucket\_storage\_class](#input\_bucket\_storage\_class) | the storage class of the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. Supported values are 'standard', 'vault', 'cold', and 'smart'. | `string` | `"standard"` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create\_cos\_instance' is true. | `string` | `null` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan to be used for creating cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | Optional list of tags to be added to cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_bucket"></a> [create\_cos\_bucket](#input\_create\_cos\_bucket) | Set as true to create a new Cloud Object Storage bucket | `bool` | `true` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Set as true to create a new Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_create_hmac_key"></a> [create\_hmac\_key](#input\_create\_hmac\_key) | Set as true to create a new HMAC key for the Cloud Object Storage instance. | `bool` | `false` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if 'var.create\_cos\_instance' is false. | `string` | `null` | no |
| <a name="input_hmac_key_name"></a> [hmac\_key\_name](#input\_hmac\_key\_name) | The name of the hmac key to be created. | `string` | `"hmac-cos-key"` | no |
| <a name="input_hmac_key_role"></a> [hmac\_key\_role](#input\_hmac\_key\_role) | The role you want to be associated with your new hmac key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'. | `string` | `"Manager"` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | (Optional, list) List of CBR rules to create for the instance | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_primary_bucket_name"></a> [primary\_bucket\_name](#input\_primary\_bucket\_name) | The name to give the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_primary_existing_hpcs_instance_guid"></a> [primary\_existing\_hpcs\_instance\_guid](#input\_primary\_existing\_hpcs\_instance\_guid) | The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs\_key\_crn is coming from. Required if var.create\_cos\_instance is true in order to create an IAM Access Policy to allow Key Protect to access the newly created COS instance. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_primary_hpcs_key_crn"></a> [primary\_hpcs\_key\_crn](#input\_primary\_hpcs\_key\_crn) | CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_primary_region"></a> [primary\_region](#input\_primary\_region) | region for the primary bucket | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_secondary_bucket_name"></a> [secondary\_bucket\_name](#input\_secondary\_bucket\_name) | The name to give the newly provisioned COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_secondary_existing_hpcs_instance_guid"></a> [secondary\_existing\_hpcs\_instance\_guid](#input\_secondary\_existing\_hpcs\_instance\_guid) | The GUID of the Hyper Protect Crypto service in which the key specified in var.hpcs\_key\_crn is coming from. Required if var.create\_cos\_instance is true in order to create an IAM Access Policy to allow Key Protect to access the newly created COS instance. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_secondary_hpcs_key_crn"></a> [secondary\_hpcs\_key\_crn](#input\_secondary\_hpcs\_key\_crn) | CRN of the Hyper Protect Crypto service to use to encrypt the data in the COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_secondary_region"></a> [secondary\_region](#input\_secondary\_region) | region for the secondary bucket | `string` | `"us-east"` | no |
| <a name="input_sysdig_crn"></a> [sysdig\_crn](#input\_sysdig\_crn) | Sysdig Monitoring crn for COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Buckets module output |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | The GUID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | The ID of the Cloud Object Storage Instance where the buckets are created |
| <a name="output_primary_bucket_id"></a> [primary\_bucket\_id](#output\_primary\_bucket\_id) | Primary bucket id |
| <a name="output_primary_bucket_name"></a> [primary\_bucket\_name](#output\_primary\_bucket\_name) | Primary bucket name |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
| <a name="output_s3_endpoint_private"></a> [s3\_endpoint\_private](#output\_s3\_endpoint\_private) | S3 private endpoint |
| <a name="output_secondary_bucket_id"></a> [secondary\_bucket\_id](#output\_secondary\_bucket\_id) | Secondary bucket id |
| <a name="output_secondary_bucket_name"></a> [secondary\_bucket\_name](#output\_secondary\_bucket\_name) | Secondary bucket name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
