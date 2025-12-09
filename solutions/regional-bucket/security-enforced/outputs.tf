##############################################################################
# Outputs
##############################################################################

output "s3_endpoint_public" {
  description = "The s3 direct endpoint of the created bucket."
  value       = module.regional_bucket.s3_endpoint_public
}

output "s3_endpoint_direct" {
  description = "The s3 direct endpoint of the created bucket."
  value       = module.regional_bucket.s3_endpoint_direct
}

output "s3_endpoint_private" {
  description = "The s3 private endpoint of the created bucket."
  value       = module.regional_bucket.s3_endpoint_private
}

output "bucket_name" {
  description = "The name of the bucket that was created. Includes the optional suffix if enabled."
  value       = module.regional_bucket.bucket_name
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance containing the created bucket."
  value       = module.regional_bucket.cos_instance_crn
}

output "cos_instance_guid" {
  description = "The CRN of the COS instance containing the created bucket."
  value       = module.regional_bucket.cos_instance_guid
}

##############################################################################
# REGIONAL BUCKET Next Steps URLs outputs
##############################################################################

output "next_steps_text" {
  value       = module.regional_bucket.next_steps_text
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = module.regional_bucket.next_step_primary_label
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = module.regional_bucket.next_step_primary_url
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = module.regional_bucket.next_step_secondary_label
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = module.regional_bucket.next_step_secondary_url
  description = "Secondary URL"
}

##############################################################################
