##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "List of buckets created"
  value       = module.cross_regional_bucket.buckets
}

output "s3_endpoint_direct" {
  description = "The s3 direct endpoint of the created bucket."
  value       = try(module.cross_regional_bucket.buckets[var.bucket_name].s3_endpoint_direct, null)
}

output "s3_endpoint_private" {
  description = "The s3 private endpoint of the created bucket."
  value       = try(module.cross_regional_bucket.buckets[var.bucket_name].s3_endpoint_private, null)
}

output "bucket_name" {
  description = "The name of the bucket that was created. Includes the optional suffix if enabled."
  value       = try(module.cross_regional_bucket.buckets[var.bucket_name].bucket_name, null)
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance containing the created bucket."
  value       = var.existing_cos_instance_crn
}
