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
  value       = var.existing_cos_instance_id == null ? module.cos_instance[0].cos_instance_id : var.existing_cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = var.existing_cos_instance_id == null ? module.cos_instance[0].cos_instance_guid : data.ibm_resource_instance.existing_cos_instance_details[0].guid
}

output "cos_instance_name" {
  description = "COS instance name"
  value       = var.existing_cos_instance_id == null ? module.cos_instance[0].cos_instance_name : data.ibm_resource_instance.existing_cos_instance_details[0].name
}

output "cos_instance_crn" {
  description = "COS instance crn"
  value       = var.existing_cos_instance_id == null ? module.cos_instance[0].cos_instance_crn : data.ibm_resource_instance.existing_cos_instance_details[0].crn
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
