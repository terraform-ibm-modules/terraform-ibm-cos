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

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| ibm | >= 1.88.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| source_bucket_crn | The CRN of the source bucket. The instance GUID, bucket name, and account ID are parsed from this CRN. | `string` | n/a | yes |
| bucket_endpoint_type | The endpoint type of the bucket. Possible values are `public`, `private`, or `direct`. | `string` | `"public"` | no |
| replication_rules | List of replication rules to configure. Each rule requires: rule_id, enable, priority, prefix, deletemarker_replication_status, destination_bucket_crn, skip_iam_authorization_policy | `list(object)` | n/a | yes |

### Replication Rule Object

Each object in the `replication_rules` list supports:

| Field | Description | Type | Default | Required |
|-------|-------------|------|---------|:--------:|
| rule_id | Unique identifier for the rule | `string` | n/a | yes |
| enable | Whether the rule is enabled | `bool` | n/a | yes |
| priority | Priority of the rule (higher number = higher priority) | `number` | `null` | no |
| prefix | Optional prefix filter for objects to replicate | `string` | `null` | no |
| deletemarker_replication_status | Whether to replicate delete markers | `bool` | `null` | no |
| destination_bucket_crn | CRN of the destination bucket. Target COS instance GUID and bucket name are parsed from this value. | `string` | n/a | yes |
| skip_iam_authorization_policy | Set to `true` to skip IAM policy creation for this rule | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| replication_rule_ids | List of replication rule IDs |
| replication_resource_id | The resource ID of the replication configuration |
| iam_authorization_policy_ids | Map of IAM authorization policy IDs keyed by `rule_id` (only for rules where `skip_iam_authorization_policy` is false) |
| source_bucket_crn | The CRN of the source bucket |
| replication_rules_count | Number of replication rules configured |
