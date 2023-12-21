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

output "resource_key_id" {
  description = "COS resource key ID"
  value       = data.ibm_resource_key.cos_resource_key.credentials["cos_hmac_keys.access_key_id"]
}

output "resource_key" {
  description = "COS resource key value"
  value       = data.ibm_resource_key.cos_resource_key.credentials["cos_hmac_keys.secret_access_key"]
  sensitive   = true
}
