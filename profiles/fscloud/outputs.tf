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
  value       = module.cos_primary_bucket.bucket_id
}

output "secondary_bucket_id" {
  description = "Secondary Bucket id"
  value       = module.cos_secondary_bucket.bucket_id
}

output "primary_bucket_name" {
  description = "Primary Bucket Name"
  value       = module.cos_primary_bucket.bucket_name
}

output "secondary_bucket_name" {
  description = "Primary Bucket Name"
  value       = module.cos_secondary_bucket.bucket_name
}

output "cos_instance_id" {
  description = "The ID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_instance.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_instance.cos_instance_guid
}
