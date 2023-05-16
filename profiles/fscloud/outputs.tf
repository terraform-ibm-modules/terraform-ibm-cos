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

output "primary_bucket_id" {
  description = "Primary Bucket id"
  value       = module.buckets.buckets[var.primary_bucket_name].bucket_id
}

output "secondary_bucket_id" {
  description = "Secondary Bucket id"
  value       = module.buckets.buckets[var.secondary_bucket_name].bucket_id
}

output "primary_bucket_name" {
  description = "Primary Bucket Name"
  value       = module.buckets.buckets[var.primary_bucket_name].bucket_name
}

output "secondary_bucket_name" {
  description = "Secondary Bucket Name"
  value       = module.buckets.buckets[var.secondary_bucket_name].bucket_name
}

output "cos_instance_id" {
  description = "The ID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_instance.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_instance.cos_instance_guid
}

output "buckets" {
  description = "Bucket module output"
  value       = module.buckets.buckets
}
