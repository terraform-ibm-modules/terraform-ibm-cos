output "bucket_crn" {
  value       = module.advance_lifecycle_rules.bucket_crn
  description = "Bucket CRN"
}

output "bucket_location" {
  value       = module.advance_lifecycle_rules.bucket_location
  description = "Bucket location"
}

output "bucket_id" {
  value       = module.advance_lifecycle_rules.bucket_id
  description = "Bucket ID"
}
