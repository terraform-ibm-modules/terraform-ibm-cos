# Cloud Object Storage buckets module

You can use this submodule to provision and configure IBM [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) buckets.

You can configure the following aspects of your instances:
- [Bucket encryption](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tutorial-kp-encrypt-bucket) - based on Key Protect keys
- [Activity tracking](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-tracking-cos-events) and auditing
- [Monitoring](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-monitoring-cos)
- Data retention, [lifecycle](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-archive) and archiving options

The submodule extends the root module by including support for multiple buckets. When multiple buckets are required, you keep all the bucket definitions in one place and the deployment information is available in a map that can be iterated over.

### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"
  region           = "us-south"
}

# Create:
# - COS buckets, one with encryption and another with versioning
module "buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  bucket_configs = [
    {
      bucket_name            = "my-encrypted-bucket"
      kms_key_crn            = "crn:v1:bluemix:public:kms:us-south:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxx-XXXX-XXXX-XXXX-xxxxxx:key:xxxxxx-XXXX-XXXX-XXXX-xxxxxx"
      kms_encryption_enabled = true # Must be set, as well as passing key crn, to avoid terraform count issues during plan and apply
      region_location        = "us-south"
      resource_instance_id   = "crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx::"
    },
    {
      bucket_name            = "my-versioned-bucket"
      kms_encryption_enabled = false
      region_location        = "us-south"
      resource_instance_id   = ""crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:xxxxxxxx-XXXX-XXXX-XXXX-xxxxxxxx::""
      object_versioning = {
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
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4.0, <1.6.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.56.1, < 2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_buckets"></a> [buckets](#module\_buckets) | ../../ | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_configs"></a> [bucket\_configs](#input\_bucket\_configs) | Cloud Object Storage bucket configurations | <pre>list(object({<br>    access_tags                   = optional(list(string), [])<br>    bucket_name                   = string<br>    kms_encryption_enabled        = optional(bool, true)<br>    kms_guid                      = optional(string, null)<br>    kms_key_crn                   = optional(string, null)<br>    skip_iam_authorization_policy = optional(bool, false)<br>    management_endpoint_type      = optional(string, "public")<br>    cross_region_location         = optional(string, null)<br>    storage_class                 = optional(string, "smart")<br>    region_location               = optional(string, null)<br>    resource_instance_id          = string<br>    force_delete                  = optional(bool, true)<br>    single_site_location          = optional(string, null)<br>    hard_quota                    = optional(number, null)<br><br>    activity_tracking = optional(object({<br>      read_data_events     = optional(bool, true)<br>      write_data_events    = optional(bool, true)<br>      activity_tracker_crn = optional(string, null)<br>    }))<br>    archive_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 20)<br>      type   = optional(string, "Glacier")<br>    }))<br>    expire_rule = optional(object({<br>      enable = optional(bool, false)<br>      days   = optional(number, 365)<br>    }))<br>    metrics_monitoring = optional(object({<br>      usage_metrics_enabled   = optional(bool, true)<br>      request_metrics_enabled = optional(bool, true)<br>      metrics_monitoring_crn  = optional(string, null)<br>    }))<br>    object_versioning = optional(object({<br>      enable = optional(bool, false)<br>    }))<br>    retention_rule = optional(object({<br>      default   = optional(number, 90)<br>      maximum   = optional(number, 350)<br>      minimum   = optional(number, 90)<br>      permanent = optional(bool, false)<br>    }))<br>    cbr_rules = optional(list(object({<br>      description = string<br>      account_id  = string<br>      rule_contexts = list(object({<br>        attributes = optional(list(object({<br>          name  = string<br>          value = string<br>      }))) }))<br>      enforcement_mode = string<br>      tags = optional(list(object({<br>        name  = string<br>        value = string<br>      })), [])<br>      operations = optional(list(object({<br>        api_types = list(object({<br>          api_type_id = string<br>        }))<br>      })))<br>    })), [])<br><br>  }))</pre> | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_configs"></a> [bucket\_configs](#output\_bucket\_configs) | List of bucket config definitions |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Map of buckets created in the Cloud Object Storage Instance |
| <a name="output_cbr_rule_ids"></a> [cbr\_rule\_ids](#output\_cbr\_rule\_ids) | List of bucket CBR rule ids |
| <a name="output_cbr_rules"></a> [cbr\_rules](#output\_cbr\_rules) | List of COS bucket CBR rules |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
