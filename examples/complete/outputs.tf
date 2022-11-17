output "key_protect_instance_id" {
  description = "The GUID of the Key Protect Instance where the Key to encrypt the COS Bucket is stored"
  value       = module.complete.key_protect_instance_id
}

output "bucket_name" {
  description = "Bucket Name"
  value       = module.complete.bucket_name
}
