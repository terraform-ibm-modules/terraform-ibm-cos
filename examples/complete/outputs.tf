output "bucket_names" {
  description = "Bucket Name"
  value       = module.cos_bucket1.bucket_names
}

output "cross_region_bucket_names" {
  description = "Bucket Name"
  value       = module.cos_bucket2.bucket_names
}
