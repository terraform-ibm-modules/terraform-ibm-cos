##############################################################################
# Outputs
##############################################################################

output "replication_rule_ids" {
  description = "List of replication rule IDs"
  value       = ibm_cos_bucket_replication_rule.cos_replication_rule.replication_rule[*].rule_id
}

output "iam_authorization_policy_ids" {
  description = "Map of IAM authorization policy IDs keyed by rule_id (only for rules where skip_iam_authorization_policy is false)"
  value       = { for k, v in module.s2s_auth.auth_policies : k => v.id }
}

output "replication_resource_id" {
  description = "The resource ID of the replication configuration"
  value       = ibm_cos_bucket_replication_rule.cos_replication_rule.id
}
