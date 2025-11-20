# Cloud Object Storage lifecycle_rules module

You can use this submodule to configure multiple lifecycle rules to existing IBM [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage) buckets.

You can configure the following multiple rules to your buckets:
- [expiration](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-expiry)
- [noncurrent version expiration](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-expiry#noncurrentversionexpiration)
- [abort incomplete multipart](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-lifecycle-cleanup-mpu)

### Usage
```hcl
module "advance_lifecycle_rules" {
  source = "terraform-ibm-modules/cos/ibm//modules/lifecycle_rules"
  cos_region = "region of the existing bucket"
  bucket_crn = "crn:v1:bluemix:public:cloud-object-storage:global:a/xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX:bucket:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx" # existing bucket crn
  object_versioning_enabled = false # False by default , must be set to true for noncurrent version expiration lifecycle rule
  expiry_rules = [
        {
            rule_id = "expiry-info-7d"
            days    = 7
            prefix  = "info-"
        },
        {
            rule_id = "expiry-error-30d"
            days    = 30
            prefix  = "error-"
        }
    ]

  noncurrent_expiry_rules = [
        {
            rule_id         = "ncv-expire-45d"
            noncurrent_days = 45
            prefix          = "data/"
        },
        {
            rule_id         = "ncv-expire-90d"
            noncurrent_days = 90
            prefix          = "archive/"
        }
    ]

  abort_multipart_rules = [
        {
            rule_id               = "abort-stale-7d"
            days_after_initiation = 7
            prefix                = ""
        },
        {
            rule_id               = "abort-temp-3d"
            days_after_initiation = 3
            prefix                = "tmp/"
        }
    ]

}
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, < 2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_lifecycle_configuration.advance_bucket_lifecycle](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket_lifecycle_configuration) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_multipart_rules"></a> [abort\_multipart\_rules](#input\_abort\_multipart\_rules) | List of abort incomplete multipart upload rules | <pre>list(object({<br/>    rule_id               = optional(string)<br/>    status                = optional(string, "enable")<br/>    days_after_initiation = number<br/>    prefix                = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_bucket_crn"></a> [bucket\_crn](#input\_bucket\_crn) | The CRN of an existing Cloud Object Storage bucket. | `string` | n/a | yes |
| <a name="input_cos_region"></a> [cos\_region](#input\_cos\_region) | The region of existing Cloud Object Storage bucket. | `string` | n/a | yes |
| <a name="input_expiry_rules"></a> [expiry\_rules](#input\_expiry\_rules) | List of expiry rules | <pre>list(object({<br/>    rule_id = optional(string)<br/>    status  = optional(string, "enable")<br/>    days    = number<br/>    prefix  = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`. | `string` | `"public"` | no |
| <a name="input_noncurrent_expiry_rules"></a> [noncurrent\_expiry\_rules](#input\_noncurrent\_expiry\_rules) | List of noncurrent version expiration rules | <pre>list(object({<br/>    rule_id         = optional(string)<br/>    status          = optional(string, "enable")<br/>    noncurrent_days = number<br/>    prefix          = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Whether to enable object versioning to keep multiple versions of an object in a bucket. | `bool` | `false` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_crn"></a> [bucket\_crn](#output\_bucket\_crn) | Bucket CRN |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket ID |
| <a name="output_bucket_location"></a> [bucket\_location](#output\_bucket\_location) | Bucket location |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
