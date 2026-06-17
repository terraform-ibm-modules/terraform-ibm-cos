output "source_bucket_name" {
  description = "Source bucket name"
  value       = module.cos_source_bucket.bucket_name
}

output "target_bucket_name" {
  description = "Target bucket name"
  value       = module.cos_target_bucket.bucket_name
}

output "replication_rule_resource_id" {
  description = "The resource ID of the replication rule"
  value       = module.cos_replication.replication_rule_resource_id
}

output "iam_authorization_policy_id" {
  description = "The ID of the IAM authorization policy"
  value       = module.cos_replication.iam_authorization_policy_id
}
