# Profile for IBM Cloud Framework for Financial Services

This code is a version of the [parent root module](../../) that includes a default configuration that complies with the relevant controls from the [IBM Cloud Framework for Financial Services](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about). See the [Example for IBM Cloud Framework for Financial Services](/examples/fscloud/) for logic that uses this module. The profile assumes you are deploying into an account that is in compliance with the framework.

The default values in this profile were scanned by [IBM Code Risk Analyzer (CRA)](https://cloud.ibm.com/docs/code-risk-analyzer-cli-plugin?topic=code-risk-analyzer-cli-plugin-cra-cli-plugin#terraform-command) for compliance with the IBM Cloud Framework for Financial Services profile that is specified by the IBM Security and Compliance Center. The scan passed for all applicable rules with the following exceptions:

> rule-8cbd597c-7471-42bd-9c88-36b2696456e9 - Check whether Cloud Object Storage network access is restricted to a specific IP range

The IBM Cloud Framework for Financial Services mandates the application of an inbound network-based allowlist in front of the IBM Cloud Object Storage instance. You can comply with this requirement with the `bucket_cbr_rules` and `instance_cbr_rules` variables in the module. Use these variables to create a narrow context-based restriction rule that is scoped to the IBM Cloud Storage instance. CRA does not support checking for context-based restrictions, so you can ignore the failing rule after you set the context-based restrictions.

### Usage

```hcl
provider "ibm" {
  # pragma: allowlist secret
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.56.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cos_destination_bucket"></a> [cos\_destination\_bucket](#module\_cos\_destination\_bucket) | ../../ | n/a |
| <a name="module_cos_origin_bucket"></a> [cos\_origin\_bucket](#module\_cos\_origin\_bucket) | ../../ | n/a |
| <a name="module_origin_rules"></a> [origin\_rules](#module\_origin\_rules) | ../replication_rule/ | n/a |
| <a name="module_reverse_rules"></a> [reverse\_rules](#module\_reverse\_rules) | ../replication_rule/ | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_replication_rule.cos_replication_rule](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/resources/cos_bucket_replication_rule) | resource |
| [ibm_iam_authorization_policy.policy](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_account_settings.iam_account_settings](https://registry.terraform.io/providers/ibm-cloud/ibm/1.56.1/docs/data-sources/iam_account_settings) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_bucket_config"></a> [destination\_bucket\_config](#input\_destination\_bucket\_config) | Cloud Object Storage replication target bucket configuration | <pre>object({<br>    access_tags              = optional(list(string), [])<br>    bucket_name              = string<br>    kms_encryption_enabled   = optional(bool, true)<br>    kms_guid                 = optional(string, null)<br>    kms_key_crn              = optional(string, null)<br>    management_endpoint_type = optional(string, "public")<br>    cross_region_location    = optional(string, null)<br>    storage_class            = optional(string, "smart")<br>    region_location          = optional(string, null)<br>    resource_group_id        = string<br>    resource_instance_id     = string<br><br>    activity_tracking = optional(object({<br>      read_data_events     = optional(bool, true)<br>      write_data_events    = optional(bool, true)<br>      activity_tracker_crn = optional(string, null)<br>    }))<br>    archive_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 20)<br>      type   = optional(string, "Glacier")<br>    }))<br>    expire_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 365)<br>    }))<br>    metrics_monitoring = optional(object({<br>      usage_metrics_enabled   = optional(bool, true)<br>      request_metrics_enabled = optional(bool, true)<br>      metrics_monitoring_crn  = optional(string, null)<br>    }))<br>    object_versioning = optional(object({<br>      enable = optional(bool, false)<br>    }))<br>    retention_rule = optional(object({<br>      default   = optional(number, 90)<br>      maximum   = optional(number, 350)<br>      minimum   = optional(number, 90)<br>      permanent = optional(bool, false)<br>    }))<br>    cbr_rules = optional(list(object({<br>      description = string<br>      account_id  = string<br>      rule_contexts = list(object({<br>        attributes = optional(list(object({<br>          name  = string<br>          value = string<br>      }))) }))<br>      enforcement_mode = string<br>      tags = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>      operations = optional(list(object({<br>        api_types = list(object({<br>          api_type_id = string<br>        }))<br>      })))<br>    })), [])<br><br>  })</pre> | n/a | yes |
| <a name="input_origin_bucket_config"></a> [origin\_bucket\_config](#input\_origin\_bucket\_config) | Cloud Object Storage replication source bucket configuration | <pre>object({<br>    access_tags              = optional(list(string), [])<br>    bucket_name              = string<br>    kms_encryption_enabled   = optional(bool, true)<br>    kms_guid                 = optional(string, null)<br>    kms_key_crn              = optional(string, null)<br>    management_endpoint_type = optional(string, "public")<br>    cross_region_location    = optional(string, null)<br>    storage_class            = optional(string, "smart")<br>    region_location          = optional(string, null)<br>    resource_group_id        = string<br>    resource_instance_id     = string<br><br>    activity_tracking = optional(object({<br>      read_data_events     = optional(bool, true)<br>      write_data_events    = optional(bool, true)<br>      activity_tracker_crn = optional(string, null)<br>    }))<br>    archive_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 20)<br>      type   = optional(string, "Glacier")<br>    }))<br>    expire_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 365)<br>    }))<br>    metrics_monitoring = optional(object({<br>      usage_metrics_enabled   = optional(bool, true)<br>      request_metrics_enabled = optional(bool, true)<br>      metrics_monitoring_crn  = optional(string, null)<br>    }))<br>    object_versioning = optional(object({<br>      enable = optional(bool, false)<br>    }))<br>    retention_rule = optional(object({<br>      default   = optional(number, 90)<br>      maximum   = optional(number, 350)<br>      minimum   = optional(number, 90)<br>      permanent = optional(bool, false)<br>    }))<br>    cbr_rules = optional(list(object({<br>      description = string<br>      account_id  = string<br>      rule_contexts = list(object({<br>        attributes = optional(list(object({<br>          name  = string<br>          value = string<br>      }))) }))<br>      enforcement_mode = string<br>      tags = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>      operations = optional(list(object({<br>        api_types = list(object({<br>          api_type_id = string<br>        }))<br>      })))<br>    })), [])<br><br>  })</pre> | n/a | yes |
| <a name="input_replication_rules"></a> [replication\_rules](#input\_replication\_rules) | List of rules for replication from source to target, default all excluding delete requests | <pre>list(object({<br>    # rule_id- (Optional, String) The rule id.<br>    # enable- (Required, Bool) Specifies whether the rule is enabled. Specify true for Enabling it or false for Disabling it.<br>    # prefix- (Optional, String) An object key name prefix that identifies the subset of objects to which the rule applies.<br>    # priority- (Optional, Int) A priority is associated with each rule. The rule will be applied in a higher priority if there are multiple rules configured. The higher the number, the higher the priority<br>    # deletemarker_replication_status- (Optional, Bool) Specifies whether Object storage replicates delete markers.Specify true for Enabling it or false for Disabling it.<br>    rule_id                         = optional(string)<br>    enable                          = optional(bool)<br>    prefix                          = optional(string)<br>    priority                        = optional(number)<br>    deletemarker_replication_status = optional(bool)<br>  }))</pre> | n/a | yes |
| <a name="input_reverse_replication_rules"></a> [reverse\_replication\_rules](#input\_reverse\_replication\_rules) | List of rules for replication from target back to source, default none | <pre>list(object({<br>    rule_id                         = optional(string)<br>    enable                          = optional(bool)<br>    prefix                          = optional(string)<br>    priority                        = optional(number)<br>    deletemarker_replication_status = optional(bool)<br>  }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_replicated_bucket"></a> [replicated\_bucket](#output\_replicated\_bucket) | Replicated buckets, the origin bucket, the destination bucket and all replication rules |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
