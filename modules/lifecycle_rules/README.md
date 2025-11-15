# Profile for IBM Cloud Framework for Financial Services


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
| <a name="input_abort_multipart_rules"></a> [abort\_multipart\_rules](#input\_abort\_multipart\_rules) | List of abort incomplete multipart upload rules | <pre>list(object({<br/>    rule_id                 = optional(string)<br/>    status                  = optional(string, "enable")<br/>    days_after_initiation   = number<br/>    prefix                  = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_bucket_crn"></a> [bucket\_crn](#input\_bucket\_crn) | The CRN of an existing Cloud Object Storage bucket. | `string` | n/a | yes |
| <a name="input_cos_region"></a> [cos\_region](#input\_cos\_region) | The region of existing Cloud Object Storage bucket. | `string` | n/a | yes |
| <a name="input_cross_region_location"></a> [cross\_region\_location](#input\_cross\_region\_location) | Specify the cross-region bucket location. Possible values are `us`, `eu`, or `ap`. If specified, set `region` and `single_site_location` to `null`. | `string` | `null` | no |
| <a name="input_expiry_rules"></a> [expiry\_rules](#input\_expiry\_rules) | List of expiry rules | <pre>list(object({<br/>    rule_id = optional(string)<br/>    status  = optional(string, "enable")<br/>    days    = number<br/>    prefix  = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_management_endpoint_type_for_bucket"></a> [management\_endpoint\_type\_for\_bucket](#input\_management\_endpoint\_type\_for\_bucket) | The type of endpoint for the IBM terraform provider to manage the bucket. Possible values are `public`, `private`, or `direct`. | `string` | `"public"` | no |
| <a name="input_noncurrent_expiry_rules"></a> [noncurrent\_expiry\_rules](#input\_noncurrent\_expiry\_rules) | List of noncurrent version expiration rules | <pre>list(object({<br/>    rule_id          = optional(string)<br/>    status           = optional(string, "enable")<br/>    noncurrent_days  = number<br/>    prefix           = optional(string, "")<br/>  }))</pre> | `[]` | no |
| <a name="input_object_versioning_enabled"></a> [object\_versioning\_enabled](#input\_object\_versioning\_enabled) | Whether to enable object versioning to keep multiple versions of an object in a bucket. | `bool` | `false` | no |
| <a name="input_transition_rules"></a> [transition\_rules](#input\_transition\_rules) | List of transition rules (archival) | <pre>list(object({<br/>    rule_id       = optional(string)<br/>    status        = optional(string, "enable")<br/>    days          = number<br/>    storage_class = string            <br/>    prefix        = optional(string, "")<br/>  }))</pre> | `[]` | no |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->