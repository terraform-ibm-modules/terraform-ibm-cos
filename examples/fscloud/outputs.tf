output "buckets" {
  description = "COS buckets"
  value       = module.cos_fscloud.buckets
}
output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos_fscloud.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos_fscloud.cos_instance_guid
}
output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.cos_fscloud.bucket_cbr_rules
}

output "instance_cbr_rule" {
  description = "COS instance rule"
  value       = module.cos_fscloud.instance_cbr_rule
}

output "cbr_rule_ids" {
  description = "List of all CBR rule ids generated"
  value       = module.cos_fscloud.cbr_rule_ids
}
