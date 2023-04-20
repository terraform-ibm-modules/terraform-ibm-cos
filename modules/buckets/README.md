<!-- BEGIN MODULE HOOK -->
# Cloud Object Storage Buckets Module

### THIS NEEDS TO BE UPDATED

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

# Create:
# - COS buckets, one with encryption and another with versioning
module "buckets" {
  # Replace "main" with a GIT release version to lock into a specific release
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-cos.git//modules/buckets?ref=main"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX"
  bucket_configs = [
    {
      bucket_name          = "my-encrypted-bucket"
      kms_key_crn          = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
      region_location      = "us-south"
      resource_instance_id = "crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx::"
    },
    {
      bucket_name          = "my-versioned-bucket"
      region_location      = "us-south"
      resource_instance_id = ""crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx::""
      object_versioning = {
        enable = true
      }
    }
  ]
}
```

## Known issues

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
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access


<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ COS Buckets without encryption using an existing COS instance and Key Protect instance + Keys](examples/existing-resources)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.51.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_configs"></a> [bucket\_configs](#input\_bucket\_configs) | Cloud Object Storage bucket configurations | <pre>list(object({<br>    bucket_name           = string<br>    kms_key_crn           = optional(string, null)<br>    cross_region_location = optional(string, null)<br>    storage_class         = optional(string, "smart")<br>    region_location       = optional(string, null)<br>    resource_instance_id  = optional(string, null)<br><br>    activity_tracking = optional(object({<br>      read_data_events     = optional(bool, true)<br>      write_data_events    = optional(bool, true)<br>      activity_tracker_crn = optional(string, null)<br>    }))<br>    archive_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 20)<br>      type   = optional(string, "Glacier")<br>    }))<br>    expire_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 365)<br>    }))<br>    metrics_monitoring = optional(object({<br>      usage_metrics_enabled   = optional(bool, true)<br>      request_metrics_enabled = optional(bool, true)<br>      metrics_monitoring_crn  = optional(string, null)<br>    }))<br>    object_versioning = optional(object({<br>      enable = optional(bool, false)<br>    }))<br>    retention_rule = optional(object({<br>      default   = optional(number, 90)<br>      maximum   = optional(number, 350)<br>      minimum   = optional(number, 90)<br>      permanent = optional(bool, false)<br>    }))<br>    cbr_rules = optional(list(object({<br>      description = string<br>      account_id  = string<br>      rule_contexts = list(object({<br>        attributes = optional(list(object({<br>          name  = string<br>          value = string<br>      }))) }))<br>      enforcement_mode = string<br>      tags = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>      operations = optional(list(object({<br>        api_types = list(object({<br>          api_type_id = string<br>        }))<br>      })))<br>    })), [])<br><br>  }))</pre> | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The resource group ID where resources will be provisioned. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_configs"></a> [bucket\_configs](#output\_bucket\_configs) | List of bucket config definitions |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Map of buckets created in the Cloud Object Storage Instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- Source for this readme file: https://github.com/terraform-ibm-modules/common-dev-assets/tree/main/module-assets/ci/module-template-automation -->
<!-- END CONTRIBUTING HOOK -->
