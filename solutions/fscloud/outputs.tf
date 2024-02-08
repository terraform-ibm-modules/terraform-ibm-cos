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
  value       = module.cos_instance.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos_instance.cos_instance_guid
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.buckets.cbr_rules
}

output "instance_cbr_rules" {
  description = "COS instance rules"
  value       = module.instance_cbr_rules[*]
}

