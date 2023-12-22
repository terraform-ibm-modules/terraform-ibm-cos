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
  version                               = "X.X.X" # Replace "latest" with a release version to lock into a specific release
  resource_group_id                     = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  cos_instance_name                     = "my-cos-instance"
  primary_bucket_name                   = "my-bucket-primary"
  primary_region                        = "us-south"
  primary_existing_hpcs_instance_guid   = "xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx"
  primary_hpcs_key_crn                  = "crn:v1:bluemix:public:hs-crypto:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
  secondary_bucket_name                 = "my-bucket-secondary"
  secondary_existing_hpcs_instance_guid = "xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx"
  secondary_region                      = "us-east"
  secondary_hpcs_key_crn                = "crn:v1:bluemix:public:hs-crypto:us-east:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
  sysdig_crn                            = "crn:v1:bluemix:public:sysdig-monitor:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  activity_tracker_crn                  = "crn:v1:bluemix:public:logdnaat:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX::"
  bucket_cbr_rules = [
    {
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
        }]
      }]
    }
  ]
  instance_cbr_rules = [
    {
      description      = "sample rule for the instance"
      enforcement_mode = "report"
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
        }]
      }]
    }
  ]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | ../../modules/buckets | n/a |
| <a name="module_cos_instance"></a> [cos\_instance](#module\_cos\_instance) | ../../ | n/a |
| <a name="module_instance_cbr_rules"></a> [instance\_cbr\_rules](#module\_instance\_cbr\_rules) | terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module | 1.17.1 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tags"></a> [access\_tags](#input\_access\_tags) | Optional list of access tags to be added to the created resources | `list(string)` | `[]` | no |
| <a name="input_activity_tracker_crn"></a> [activity\_tracker\_crn](#input\_activity\_tracker\_crn) | Activity tracker crn for COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |
| <a name="input_bucket_configs"></a> [bucket\_configs](#input\_bucket\_configs) | Cloud Object Storage bucket configurations | <pre>list(object({<br>    access_tags                   = optional(list(string), [])<br>    bucket_name                   = string<br>    kms_encryption_enabled        = optional(bool, true)<br>    kms_guid                      = optional(string, null)<br>    kms_key_crn                   = string<br>    skip_iam_authorization_policy = optional(bool, false)<br>    management_endpoint_type      = string<br>    cross_region_location         = optional(string, null)<br>    storage_class                 = optional(string, "smart")<br>    region_location               = optional(string, null)<br>    resource_group_id             = string<br>    resource_instance_id          = optional(string, null)<br><br>    activity_tracking = optional(object({<br>      read_data_events     = optional(bool, true)<br>      write_data_events    = optional(bool, true)<br>      activity_tracker_crn = optional(string, null)<br>    }))<br>    archive_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 20)<br>      type   = optional(string, "Glacier")<br>    }))<br>    expire_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 365)<br>    }))<br>    metrics_monitoring = optional(object({<br>      usage_metrics_enabled   = optional(bool, true)<br>      request_metrics_enabled = optional(bool, true)<br>      metrics_monitoring_crn  = optional(string, null)<br>    }))<br>    object_versioning = optional(object({<br>      enable = optional(bool, false)<br>    }))<br>    retention_rule = optional(object({<br>      default   = optional(number, 90)<br>      maximum   = optional(number, 350)<br>      minimum   = optional(number, 90)<br>      permanent = optional(bool, false)<br>    }))<br>    cbr_rules = optional(list(object({<br>      description = string<br>      account_id  = string<br>      rule_contexts = list(object({<br>        attributes = optional(list(object({<br>          name  = string<br>          value = string<br>      }))) }))<br>      enforcement_mode = string<br>      tags = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>      operations = optional(list(object({<br>        api_types = list(object({<br>          api_type_id = string<br>        }))<br>      })))<br>    })), [])<br><br>  }))</pre> | `[]` | no |
| <a name="input_cos_instance_name"></a> [cos\_instance\_name](#input\_cos\_instance\_name) | The name to give the cloud object storage instance that will be provisioned by this module. Only required if 'create\_cos\_instance' is true. | `string` | `null` | no |
| <a name="input_cos_plan"></a> [cos\_plan](#input\_cos\_plan) | Plan to be used for creating cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `string` | `"standard"` | no |
| <a name="input_cos_tags"></a> [cos\_tags](#input\_cos\_tags) | Optional list of tags to be added to cloud object storage instance. Only used if 'create\_cos\_instance' it true. | `list(string)` | `[]` | no |
| <a name="input_create_cos_instance"></a> [create\_cos\_instance](#input\_create\_cos\_instance) | Set as true to create a new Cloud Object Storage instance. | `bool` | `true` | no |
| <a name="input_create_hmac_key"></a> [create\_hmac\_key](#input\_create\_hmac\_key) | Set as true to create a new HMAC key for the Cloud Object Storage instance. | `bool` | `false` | no |
| <a name="input_existing_cos_instance_id"></a> [existing\_cos\_instance\_id](#input\_existing\_cos\_instance\_id) | The ID of an existing cloud object storage instance. Required if 'var.create\_cos\_instance' is false. | `string` | `null` | no |
| <a name="input_hmac_key_name"></a> [hmac\_key\_name](#input\_hmac\_key\_name) | The name of the hmac key to be created. | `string` | `"hmac-cos-key"` | no |
| <a name="input_hmac_key_role"></a> [hmac\_key\_role](#input\_hmac\_key\_role) | The role you want to be associated with your new hmac key. Valid roles are 'Writer', 'Reader', 'Manager', 'Content Reader', 'Object Reader', 'Object Writer'. | `string` | `"Manager"` | no |
| <a name="input_instance_cbr_rules"></a> [instance\_cbr\_rules](#input\_instance\_cbr\_rules) | (Optional, list) List of CBR rule to create for the instance | <pre>list(object({<br>    description = string<br>    account_id  = string<br>    rule_contexts = list(object({<br>      attributes = optional(list(object({<br>        name  = string<br>        value = string<br>    }))) }))<br>    enforcement_mode = string<br>    tags = optional(list(object({<br>      name  = string<br>      value = string<br>    })), [])<br>    operations = optional(list(object({<br>      api_types = list(object({<br>        api_type_id = string<br>      }))<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |
| <a name="input_sysdig_crn"></a> [sysdig\_crn](#input\_sysdig\_crn) | Sysdig Monitoring crn for COS bucket. Only required if 'create\_cos\_bucket' is true. | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_cbr_rules"></a> [bucket\_cbr\_rules](#output\_bucket\_cbr\_rules) | COS bucket rules |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | List of buckets created |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | List of all rule ids |
| <a name="output_cos_instance_guid"></a> [cos\_instance\_guid](#output\_cos\_instance\_guid) | COS instance guid |
| <a name="output_cos_instance_id"></a> [cos\_instance\_id](#output\_cos\_instance\_id) | COS instance id |
| <a name="output_instance_cbr_rules"></a> [instance\_cbr\_rules](#output\_instance\_cbr\_rules) | COS instance rules |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | Resource Group ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
