output "source_bucket_name" {
  description = "Source bucket name"
  value       = module.cos_source_bucket.bucket_name
}

output "target_bucket_name" {
  description = "Target bucket name"
  value       = module.cos_target_bucket.bucket_name
}

output "replication_rule_ids" {
  description = "List of replication rule IDs"
  value       = module.cos_replication.replication_rule_ids
}

output "replication_resource_id" {
  description = "The resource ID of the replication configuration"
  value       = module.cos_replication.replication_resource_id
}
