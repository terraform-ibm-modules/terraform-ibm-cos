##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = module.resource_group.resource_group_id
}

output "buckets" {
  description = "List of buckets created"
  value       = module.cos.buckets
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos.cos_instance_guid
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.cos.bucket_cbr_rules
}

output "instance_cbr_rules" {
  description = "COS instance rules"
  value       = module.cos.instance_cbr_rules
}

output "cbr_rule_ids" {
  description = "List of all rule ids"
  value       = module.cos.cbr_rule_ids
}
