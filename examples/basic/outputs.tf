output "bucket_name" {
  description = "Bucket name"
  value       = module.cos.bucket_name
}

output "bucket_crn" {
  description = "Bucket CRN"
  value       = module.cos.bucket_crn
}

output "bucket_id" {
  description = "Bucket id"
  value       = module.cos.bucket_id
}

output "bucket_resource_key" {
  description = "Bucket resource key"
  value       = module.cos.bucket_resource_key
  sensitive   = true
}

output "buckets" {
  description = "Bucket from sub module"
  value       = module.buckets.buckets
}

output "buckets_resource_keys" {
  description = "Bucket resource keys from sub module"
  value       = module.buckets.bucket_resource_keys
  sensitive   = true
}
