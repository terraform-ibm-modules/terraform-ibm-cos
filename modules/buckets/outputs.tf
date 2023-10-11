##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = module.buckets
}

output "bucket_configs" {
  description = "List of bucket config definitions"
  value       = var.bucket_configs
}

output "cbr_rules" {
  description = "List of COS bucket CBR rules"
  value       = flatten([for _, bucket in module.buckets : bucket.bucket_cbr_rules])
}

output "cbr_rule_ids" {
  description = "List of bucket CBR rule ids"
  value       = local.bucket_rule_ids
}
