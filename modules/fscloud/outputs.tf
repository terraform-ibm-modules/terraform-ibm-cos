##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = var.resource_group_id
}

output "s3_endpoint_private" {
  description = "S3 private endpoint"
  value       = module.cos_instance.s3_endpoint_private
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
  value       = module.bucket_cbr_rules
}

output "instance_cbr_rule" {
  description = "COS instance rules"
  value       = module.instance_cbr_rule
}

output "cbr_rule_ids" {
  description = "List of all rule ids"
  value       = local.all_rule_ids
}
