##############################################################################
# Outputs
##############################################################################
# expand buckets, pull all elements except bucket_resource_key
# iterate over list (...) and merge() back to map
output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value = merge([for name, bucket in module.buckets : { (name) = {
    "resource_group_id"    = bucket.resource_group_id
    "s3_endpoint_private"  = bucket.s3_endpoint_private
    "s3_endpoint_public"   = bucket.s3_endpoint_public
    "s3_endpoint_direct"   = bucket.s3_endpoint_direct
    "bucket_id"            = bucket.bucket_id
    "bucket_crn"           = bucket.bucket_crn
    "bucket_name"          = bucket.bucket_name
    "bucket_storage_class" = bucket.bucket_storage_class
    # skip bucket_resource_key because it is sensitive
    "kms_key_crn"        = bucket.kms_key_crn
    "cos_instance_id"    = bucket.cos_instance_id
    "cos_instance_guid"  = bucket.cos_instance_guid
    "bucket_cbr_rules"   = bucket.bucket_cbr_rules
    "instance_cbr_rules" = bucket.instance_cbr_rules
    "cbr_rule_ids"       = bucket.cbr_rule_ids
  } }]...)
}

output "bucket_resource_keys" {
  description = "Map of bucket resource keys"
  value = merge([for name, bucket in module.buckets : { (name) = {
    # skip resource_group_id, s3_endpoint_private, s3_endpoint_public, s3_endpoint_direct, bucket_id, bucket_crn, bucket_name, bucket_storage_class
    "bucket_resource_key" = bucket.bucket_resource_key
    # skip kms_key_crn, cos_instance_id, cos_instance_guid, bucket_cbr_rules, instance_cbr_rules, cbr_rule_ids
  } }]...)
  sensitive = true
}

output "bucket_configs" {
  description = "List of bucket config definitions"
  value       = var.bucket_configs
}

output "cbr_rules" {
  description = "List of COS bucket CBR rules"
  value       = flatten([for _, bucket in module.buckets : bucket.bucket_cbr_rules])
}

output "cbr_rule_ids" {
  description = "List of bucket CBR rule ids"
  value       = local.bucket_rule_ids
}
