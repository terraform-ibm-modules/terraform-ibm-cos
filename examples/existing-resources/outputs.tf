output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = module.buckets.buckets
}

output "bucket_configs" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = module.buckets.bucket_configs
}
