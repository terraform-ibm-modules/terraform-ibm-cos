output "bucket_name" {
  description = "Bucket Name"
  value       = module.cos_bucket.bucket_name
}

output "bucket_crn" {
  description = "Bucket CRN"
  value       = module.cos_bucket.bucket_crn
}

output "bucket_id" {
  description = "Bucket id"
  value       = module.cos_bucket.bucket_id
}
