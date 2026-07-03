# Replication Module

This module configures replication between IBM Cloud Object Storage (COS) buckets. It creates the necessary IAM authorization policies (via the [s2s-auth module](https://github.com/terraform-ibm-modules/terraform-ibm-s2s-auth)) and replication rules to enable data replication from a source bucket to one or more target buckets.

The source COS instance GUID and source bucket name are parsed automatically from `source_bucket_crn`. The target COS instance GUID and target bucket name are parsed from each rule's `destination_bucket_crn`. You do not need to supply those values separately.

## Features

- Creates IAM authorization policies to allow source COS instance to write to target buckets
- Supports multiple replication rules to different destinations
- Configurable replication settings per rule (priority, prefix filtering, delete marker replication)
- Optional IAM authorization policy creation per rule

## Usage

### Single Replication Rule

```hcl
module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn = module.source_bucket.bucket_crn
  source_bucket_region = "us-south"

  # Replication rules
  replication_rules = [
    {
      rule_id                         = "replicate-everything"
      enable                          = true
      priority                        = 50
      prefix                          = null
      deletemarker_replication_status = false
      destination_bucket_crn          = module.target_bucket.bucket_crn
    }
  ]
}
```

### Multiple Replication Rules

```hcl
module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn    = module.source_bucket.bucket_crn
  source_bucket_region = "us-east"

  # Replication rules
  replication_rules = [
    {
      rule_id                         = "replicate-logs"
      enable                          = true
      priority                        = 100
      prefix                          = "logs/"
      deletemarker_replication_status = false
      destination_bucket_crn          = module.logs_bucket.bucket_crn
    },
    {
      rule_id                         = "replicate-data"
      enable                          = true
      priority                        = 50
      prefix                          = "data/"
      deletemarker_replication_status = true
      destination_bucket_crn          = module.data_bucket.bucket_crn
    }
  ]
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.88.0, < 3.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s2s_auth"></a> [s2s\_auth](#module\_s2s\_auth) | terraform-ibm-modules/s2s-auth/ibm | 2.3.0 |
| <a name="module_source_bucket_crn_parser"></a> [source\_bucket\_crn\_parser](#module\_source\_bucket\_crn\_parser) | terraform-ibm-modules/common-utilities/ibm//modules/crn-parser | 1.9.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_cos_bucket_replication_rule.cos_replication_rule](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/cos_bucket_replication_rule) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_endpoint_type"></a> [bucket\_endpoint\_type](#input\_bucket\_endpoint\_type) | The endpoint type of the bucket. Possible values are `public`, `private`, or `direct`. | `string` | `"public"` | no |
| <a name="input_replication_rules"></a> [replication\_rules](#input\_replication\_rules) | List of replication rules to configure. Each rule requires:<br/>- rule\_id: Unique identifier for the rule.<br/>- enable: Whether the rule is enabled.<br/>- priority: (Optional) Priority of the rule, higher number = higher priority.<br/>- prefix: (Optional) Prefix filter to replicate a subset of objects in the source bucket.<br/>- deletemarker\_replication\_status: (Optional) Whether to replicate delete markers.<br/>- destination\_bucket\_crn: The CRN of the destination bucket. The target COS instance GUID and target bucket name are parsed from this CRN.<br/>- skip\_iam\_authorization\_policy: (Optional) Set it to `true` to skip IAM policy creation for this rule. Default value is `false`. | <pre>list(object({<br/>    rule_id                         = string<br/>    enable                          = bool<br/>    priority                        = optional(number)<br/>    prefix                          = optional(string)<br/>    deletemarker_replication_status = optional(bool)<br/>    destination_bucket_crn          = string<br/>    skip_iam_authorization_policy   = optional(bool, false)<br/>  }))</pre> | n/a | yes |
| <a name="input_source_bucket_crn"></a> [source\_bucket\_crn](#input\_source\_bucket\_crn) | The CRN of the source bucket. The instance GUID, bucket name, and account ID are parsed from this CRN. | `string` | n/a | yes |
| <a name="input_source_bucket_region"></a> [source\_bucket\_region](#input\_source\_bucket\_region) | The region of the source bucket. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_authorization_policy_ids"></a> [iam\_authorization\_policy\_ids](#output\_iam\_authorization\_policy\_ids) | Map of IAM authorization policy IDs keyed by rule\_id (only for rules where skip\_iam\_authorization\_policy is false) |
| <a name="output_replication_resource_id"></a> [replication\_resource\_id](#output\_replication\_resource\_id) | The resource ID of the replication configuration |
| <a name="output_replication_rule_ids"></a> [replication\_rule\_ids](#output\_replication\_rule\_ids) | List of replication rule IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
