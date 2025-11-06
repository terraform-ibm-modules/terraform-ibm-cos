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

##############################################################################
# CROSS REGIONAL BUCKET Next Steps URLs outputs
##############################################################################

output "next_steps_text" {
  value       = module.cross_regional_bucket.next_steps_text
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = module.cross_regional_bucket.next_step_primary_label 
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.cross_regional_bucket.next_step_primary_url
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = module.cross_regional_bucket.next_step_secondary_label
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = module.cross_regional_bucket.next_step_secondary_url
  description = "Secondary URL"
}

##############################################################################
