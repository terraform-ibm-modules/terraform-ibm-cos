output "key_protect_instance_id" {
  description = "The GUID of the Key Protect Instance where the Key to encrypt the COS Bucket is stored"
  value       = module.cos_bucket1.key_protect_instance_guid
}

output "bucket_name1" {
  description = "Bucket Name"
  value       = module.cos_bucket1.bucket_name
}

output "bucket_name2" {
  description = "Bucket Name"
  value       = module.cos_bucket2.bucket_name
}
