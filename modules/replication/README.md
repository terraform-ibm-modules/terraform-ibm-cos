# Replication Module

This module configures replication between IBM Cloud Object Storage (COS) buckets. It creates the necessary IAM authorization policies and replication rules to enable data replication from a source bucket to one or more target buckets.

## Features

- Creates IAM authorization policies to allow source COS instance to write to target buckets
- Supports multiple replication rules to different destinations
- Configurable replication settings per rule (priority, prefix filtering, delete marker replication)
- Optional IAM authorization policy creation

## Usage

### Single Replication Rule

```hcl
module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn        = module.source_bucket.bucket_crn
  source_bucket_location   = "us-south"
  source_bucket_name       = module.source_bucket.bucket_name
  source_cos_instance_guid = module.source_bucket.cos_instance_guid

  # Replication rules
  replication_rules = [
    {
      rule_id                         = "replicate-everything"
      enable                          = true
      priority                        = 50
      prefix                          = null
      deletemarker_replication_status = false
      destination_bucket_crn          = module.target_bucket.bucket_crn
      target_cos_instance_guid        = module.target_bucket.cos_instance_guid
      target_bucket_name              = module.target_bucket.bucket_name
      skip_iam_authorization_policy   = false
    }
  ]
}
```

### Multiple Replication Rules

```hcl
module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn        = module.source_bucket.bucket_crn
  source_bucket_location   = "us-south"
  source_bucket_name       = module.source_bucket.bucket_name
  source_cos_instance_guid = module.source_bucket.cos_instance_guid

  # Multiple replication rules
  replication_rules = [
    {
      rule_id                         = "replicate-logs"
      enable                          = true
      priority                        = 100
      prefix                          = "logs/"
      deletemarker_replication_status = false
      destination_bucket_crn          = module.logs_bucket.bucket_crn
      target_cos_instance_guid        = module.logs_bucket.cos_instance_guid
      target_bucket_name              = module.logs_bucket.bucket_name
      skip_iam_authorization_policy   = false
    },
    {
      rule_id                         = "replicate-data"
      enable                          = true
      priority                        = 50
      prefix                          = "data/"
      deletemarker_replication_status = true
      destination_bucket_crn          = module.data_bucket.bucket_crn
      target_cos_instance_guid        = module.data_bucket.cos_instance_guid
      target_bucket_name              = module.data_bucket.bucket_name
      skip_iam_authorization_policy   = false
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
| source_bucket_crn | The CRN of the source bucket | `string` | n/a | yes |
| source_bucket_location | The region of the source bucket | `string` | n/a | yes |
| source_bucket_name | The name of the source bucket | `string` | n/a | yes |
| source_cos_instance_guid | The GUID of the source COS instance | `string` | n/a | yes |
| bucket_endpoint_type | The endpoint type of the bucket | `string` | `"public"` | no |
| replication_rules | List of replication rules to configure. Each rule requires: rule_id, enable, priority, prefix, deletemarker_replication_status, destination_bucket_crn, target_cos_instance_guid, target_bucket_name | `list(object)` | n/a | yes |
| skip_iam_authorization_policy | Whether to skip the IAM authorization policy for replication. Set to true if the policy already exists. | `bool` | `false` | no |

### Replication Rule Object

Each object in the `replication_rules` list supports:

| Field | Description | Type | Default | Required |
|-------|-------------|------|---------|:--------:|
| rule_id | Unique identifier for the rule | `string` | n/a | yes |
| enable | Whether the rule is enabled | `bool` | `true` | no |
| priority | Priority of the rule (higher number = higher priority) | `number` | `50` | no |
| prefix | Optional prefix filter for objects to replicate | `string` | `null` | no |
| deletemarker_replication_status | Whether to replicate delete markers | `bool` | `false` | no |
| destination_bucket_crn | CRN of the destination bucket | `string` | n/a | yes |
| target_cos_instance_guid | GUID of the target COS instance (for IAM policy) | `string` | n/a | yes |
| target_bucket_name | Name of the target bucket (for IAM policy) | `string` | n/a | yes |
| skip_iam_authorization_policy | Skip IAM policy creation for this rule | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| replication_rule_ids | List of replication rule IDs |
| replication_resource_id | The resource ID of the replication configuration |
| iam_authorization_policy_ids | Map of IAM authorization policy IDs (if created), keyed by target bucket identifier |
| source_bucket_crn | The CRN of the source bucket |
| replication_rules_count | Number of replication rules configured |
