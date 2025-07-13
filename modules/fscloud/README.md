# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module. The profile assumes you are deploying into an account that is in compliance with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules with the following exceptions:

> rule-8cbd597c-7471-42bd-9c88-36b2696456e9 - Check whether Cloud Object Storage network access is restricted to a specific IP range

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Object Storage instance. You can comply with this requirement with the `bucket_cbr_rules` and `instance_cbr_rules` variables in the module. Use these variables to create a narrow context-based restriction rule that is scoped to the IBM Cloud Storage instance. CRA does not support checking for context-based restrictions, so you can ignore the failing rule after you set the context-based restrictions.

### Usage

```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

module "cos_fscloud" {
  source                                = "terraform-ibm-modules/cos/ibm//modules/fscloud"
  version                               = "latest" # Replace "latest" with a release version to lock into a specific release
  resource_group_id                     = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  cos_instance_name                     = "my-cos-instance"
  bucket_configs = [
    {
      bucket_name              = "services-bucket"
      kms_guid                 = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
      kms_key_crn              = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
      management_endpoint_type = "private"
      metrics_monitoring = {
        metrics_monitoring_crn = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
      }
      region_location      = "us-south"
      cbr_rules = [{
        description      = "sample rule for buckets"
        enforcement_mode = "enabled"
        account_id       = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
        rule_contexts = [{
          attributes = [
            {
              "name" : "endpointType",
              "value" : "private"
            },
            {
              name  = "networkZoneId"
              value = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
            }
          ]
        }]
        operations = [{
          api_types = [{
            api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
          }]
        }]
      }]
    }
  ]
  instance_cbr_rules = [{
    description      = "sample rule for the instance"
    enforcement_mode = "enabled"
    account_id       = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
    rule_contexts = [{
      attributes = [
        {
          "name" : "endpointType",
          "value" : "private"
        },
        {
          name  = "networkZoneId"
          value = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
        }
      ]
    }]
    operations = [{
      api_types = [{
        api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::api-type:"
      }]
    }]
  }]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | ../../modules/buckets | n/a |
| <a name="module_cos_instance"></a> [cos\_instance](#module\_cos\_instance) | ../../ | n/a |
| <a name="module_instance_cbr_rules"></a> [instance\_cbr\_rules](#module\_instance\_cbr\_rules) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.32.3 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | A list of access tags to apply to the Object Storage instance created by the module. [Learn more](https://cloud.ibm.com/docs/account?topic=account-access-tags-tutorial). | `list(string)` | `[]` | no |
| <a name="input_bucket_configs"></a> [bucket\_configs](#input\_bucket\_configs) | Object Storage bucket configurations | <pre>list(object({<br/>    access_tags                   = optional(list(string), [])<br/>    add_bucket_name_suffix        = optional(bool, false)<br/>    bucket_name                   = string<br/>    kms_encryption_enabled        = optional(bool, true)<br/>    kms_guid                      = optional(string, null)<br/>    kms_key_crn                   = string<br/>    skip_iam_authorization_policy = optional(bool, false)<br/>    management_endpoint_type      = string<br/>    cross_region_location         = optional(string, null)<br/>    storage_class                 = optional(string, "smart")<br/>    region_location               = optional(string, null)<br/>    resource_instance_id          = optional(string, null)<br/>    force_delete                  = optional(bool, true)<br/>    single_site_location          = optional(string, null)<br/>    hard_quota                    = optional(number, null)<br/>    expire_filter_prefix          = optional(string, null)<br/>    archive_filter_prefix         = optional(string, null)<br/>    object_locking_enabled        = optional(bool, false)<br/>    object_lock_duration_days     = optional(number, 0)<br/>    object_lock_duration_years    = optional(number, 0)<br/><br/>    activity_tracking = optional(object({<br/>      read_data_events  = optional(bool, true)<br/>      write_data_events = optional(bool, true)<br/>      management_events = optional(bool, true)<br/>    }))<br/>    archive_rule = optional(object({<br/>      enable = optional(bool, false)<br/>      days   = optional(number, 20)<br/>      type   = optional(string, "Glacier")<br/>    }))<br/>    expire_rule = optional(object({<br/>      enable = optional(bool, false)<br/>      days   = optional(number, 365)<br/>    }))<br/>    metrics_monitoring = optional(object({<br/>      usage_metrics_enabled   = optional(bool, true)<br/>      request_metrics_enabled = optional(bool, true)<br/>      metrics_monitoring_crn  = optional(string, null)<br/>    }))<br/>    object_versioning = optional(object({<br/>      enable = optional(bool, false)<br/>    }))<br/>    retention_rule = optional(object({<br/>      default   = optional(number, 90)<br/>      maximum   = optional(number, 350)<br/>      minimum   = optional(number, 90)<br/>      permanent = optional(bool, false)<br/>    }))<br/>    cbr_rules = optional(list(object({<br/>      description = string<br/>      account_id  = string<br/>      rule_contexts = list(object({<br/>        attributes = optional(list(object({<br/>          name  = string<br/>          value = string<br/>      }))) }))<br/>      enforcement_mode = string<br/>      tags = optional(list(object({<br/>        name  = string<br/>        value = string<br/>      })), [])<br/>      operations = optional(list(object({<br/>        api_types = list(object({<br/>          api_type_id = string<br/>        }))<br/>      })))<br/>    })), [])<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the Object Storage instance provisioned by this module. Applies only if `create_cos_instance` is true. | `string` | `null` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | The plan to use when Object Storage instances are created. Possible values: `standard`, `cos-one-rate-plan`. Applies only if `create_cos_instance` is true. For more details refer https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | The list of tags to add to the Object Storage instance. Applies only if `create_cos_instance` is true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Specify `true` to create an Object Storage instance. | `bool` | `true` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing Object Storage instance. Required only if `var.create_cos_instance` is false. | `string` | `null` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | The list of context-based restriction rules to create for the instance. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    tags = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_resource_keys"></a> [resource\_keys](#input\_resource\_keys) | The definition of any resource keys to generate. | <pre>list(object({<br/>    name                      = string<br/>    generate_hmac_credentials = optional(bool, false)<br/>    role                      = optional(string, "Reader")<br/>    service_id_crn            = string<br/>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#output\_bucket\_cbr\_rules) | COS bucket rules |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | List of buckets created |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | List of all rule ids |
| <a name="output_cos_account_id"></a> [cos\_account\_id](#output\_cos\_account\_id) | The account ID in which the Cloud Object Storage instance is created. |
| <a name="output_cos_instance_crn"></a> [cos\_instance\_crn](#output\_cos\_instance\_crn) | COS instance crn |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | COS instance guid |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | COS instance id |
| <a name="output_cos_instance_name"></a> [cos\_instance\_name](#output\_cos\_instance\_name) | COS instance name |
| <a name="output_instance_cbr_rules"></a> [instance\_cbr\_rules](#output\_instance\_cbr\_rules) | COS instance rules |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
| <a name="output_resource_keys"></a> [resource\_keys](#output\_resource\_keys) | List of resource keys |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
