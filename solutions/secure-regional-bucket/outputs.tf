##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "List of buckets created"
  value       = module.cos.buckets
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.cos.bucket_cbr_rules
}

output "cbr_rule_ids" {
  description = "List of all rule ids"
  value       = module.cos.cbr_rule_ids
}
