output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = local.exisiting_buckets_map
}

output "bucket_configs" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = module.cos.bucket_configs
}
