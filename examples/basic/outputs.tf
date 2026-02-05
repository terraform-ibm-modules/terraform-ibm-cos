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

output "buckets" {
  description = "Bucket from sub module"
  value       = module.buckets.buckets
}

output "cos_instance_id" {
  description = "The ID of the Object Storage instance"
  value       = module.cos.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Object Storage instance"
  value       = module.cos.cos_instance_guid
}

output "cos_instance_name" {
  description = "The name of the Object Storage instance"
  value       = module.cos.cos_instance_name
}

output "cos_instance_crn" {
  description = "The CRN of the Object Storage instance"
  value       = module.cos.cos_instance_crn
}

output "vaults" {
  value = module.cos.all_vaults
}