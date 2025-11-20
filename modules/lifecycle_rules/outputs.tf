output "bucket_crn" {
  value       = ibm_cos_bucket_lifecycle_configuration.advance_bucket_lifecycle.bucket_crn
  description = "Bucket CRN"
}

output "bucket_location" {
  value       = ibm_cos_bucket_lifecycle_configuration.advance_bucket_lifecycle.bucket_location
  description = "Bucket location"
}

output "bucket_id" {
  value       = ibm_cos_bucket_lifecycle_configuration.advance_bucket_lifecycle.id
  description = "Bucket ID"
}
