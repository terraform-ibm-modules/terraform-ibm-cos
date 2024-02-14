##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = module.resource_group.resource_group_id
}

output "buckets" {
  description = "List of buckets created"
  value       = module.cos_fscloud_da.buckets
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos_fscloud_da.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos_fscloud_da.cos_instance_guid
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.cos_fscloud_da.bucket_cbr_rules
}

output "instance_cbr_rules" {
  description = "COS instance rules"
  value       = module.cos_fscloud_da.instance_cbr_rules
}

output "cbr_rule_ids" {
  description = "List of all rule ids"
  value       = module.cos_fscloud_da.cbr_rule_ids
}
