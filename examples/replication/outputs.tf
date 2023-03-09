output "source_bucket_name" {
  description = "Bucket Name"
  value       = module.cos_source_bucket.bucket_names
}

output "target_bucket_name" {
  description = "Bucket Name"
  value       = module.cos_target_bucket.bucket_names
}
