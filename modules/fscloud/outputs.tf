##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = var.resource_group_id
}

output "buckets" {
  description = "List of buckets created"
  value       = module.buckets.buckets
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = local.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = local.cos_instance_guid
}

output "cos_instance_name" {
  description = "COS instance name"
  value       = local.cos_instance_name
}

output "cos_instance_crn" {
  description = "COS instance crn"
  value       = local.cos_instance_crn
}

output "cos_account_id" {
  description = "The account ID in which the Cloud Object Storage instance is created."
  value       = var.create_cos_instance ? module.cos_instance[0].cos_account_id : null
}

output "resource_keys" {
  description = "List of resource keys"
  value       = local.resource_keys
  sensitive   = true
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.buckets.cbr_rules
}

output "instance_cbr_rules" {
  description = "COS instance rules"
  value       = module.instance_cbr_rules[*]
}

output "cbr_rule_ids" {
  description = "List of all rule ids"
  value       = local.all_rule_ids
}
