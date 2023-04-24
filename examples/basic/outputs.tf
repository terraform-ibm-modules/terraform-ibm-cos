output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos_bucket1.cos_instance_id
}

output "bucket_name1" {
  description = "Bucket Name"
  value       = module.cos_bucket1.bucket_name
}

output "bucket_name2" {
  description = "Bucket Name"
  value       = module.cos_bucket2.bucket_name
}
