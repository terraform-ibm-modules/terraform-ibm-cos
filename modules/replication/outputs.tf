##############################################################################
# Outputs
##############################################################################

output "replication_rule_resource_id" {
  description = "The resource ID of the replication rule"
  value       = ibm_cos_bucket_replication_rule.cos_replication_rule.id
}

output "iam_authorization_policy_id" {
  description = "The ID of the IAM authorization policy (if created)"
  value       = var.skip_iam_authorization_policy ? null : ibm_iam_authorization_policy.policy[0].id
}
