##############################################################################
# Outputs
##############################################################################

output "replication_rule_ids" {
  description = "List of replication rule IDs"
  value       = [for rule in var.replication_rules : rule.rule_id]
}

output "replication_resource_id" {
  description = "The resource ID of the replication configuration"
  value       = ibm_cos_bucket_replication_rule.cos_replication_rule.id
}

output "source_bucket_crn" {
  description = "The CRN of the source bucket"
  value       = var.source_bucket_crn
}

output "replication_rules_count" {
  description = "Number of replication rules configured"
  value       = length(var.replication_rules)
}
