output "primary_bucket_id" {
  description = "Primary bucket id"
  value       = module.cos_fscloud.primary_bucket_id
}

output "secondary_bucket_id" {
  description = "Secondary bucket id"
  value       = module.cos_fscloud.secondary_bucket_id
}

output "primary_bucket_name" {
  description = "Primary bucket name"
  value       = module.cos_fscloud.primary_bucket_name
}

output "secondary_bucket_name" {
  description = "Primary bucket name"
  value       = module.cos_fscloud.secondary_bucket_name
}
