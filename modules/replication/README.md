# Replication Module

This module configures replication between two IBM Cloud Object Storage (COS) buckets. It creates the necessary IAM authorization policy and replication rule to enable data replication from a source bucket to a target bucket.

## Features

- Creates IAM authorization policy to allow source COS instance to write to target bucket
- Configures replication rule with customizable settings
- Supports optional delete marker replication
- Configurable replication priority

## Usage

```hcl
module "cos_replication" {
  source = "../../modules/replication"

  # Source bucket configuration
  source_bucket_crn          = module.source_bucket.bucket_crn
  source_bucket_location     = "us-south"
  source_bucket_name         = module.source_bucket.bucket_name
  source_cos_instance_guid   = module.source_bucket.cos_instance_guid

  # Target bucket configuration
  target_bucket_crn          = module.target_bucket.bucket_crn
  target_bucket_name         = module.target_bucket.bucket_name
  target_cos_instance_guid   = module.target_bucket.cos_instance_guid

  # Replication rule configuration
  replication_rule_id                = "replicate-everything"
  replication_enabled                = true
  replication_priority               = 50
  deletemarker_replication_status    = false
  create_iam_authorization_policy    = true
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
| source_bucket_location | The location/region of the source bucket | `string` | n/a | yes |
| source_bucket_name | The name of the source bucket | `string` | n/a | yes |
| source_cos_instance_guid | The GUID of the source COS instance | `string` | n/a | yes |
| target_bucket_crn | The CRN of the target/destination bucket | `string` | n/a | yes |
| target_bucket_name | The name of the target bucket | `string` | n/a | yes |
| target_cos_instance_guid | The GUID of the target COS instance | `string` | n/a | yes |
| replication_rule_id | The ID/name for the replication rule | `string` | `"replicate-everything"` | no |
| replication_enabled | Whether to enable the replication rule | `bool` | `true` | no |
| replication_priority | The priority of the replication rule (higher number = higher priority) | `number` | `50` | no |
| deletemarker_replication_status | Whether to replicate delete markers | `bool` | `false` | no |
| create_iam_authorization_policy | Whether to create the IAM authorization policy for replication. Set to false if the policy already exists. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| replication_rule_id | The ID of the replication rule |
| replication_rule_status | The status of the replication rule |
| iam_authorization_policy_id | The ID of the IAM authorization policy (if created) |

## Notes

- Both source and target buckets must have object versioning enabled for replication to work
- The source and target buckets can be in the same or different COS instances
- The source and target buckets can be in the same or different regions
- For cross-account replication, additional IAM configuration may be required
