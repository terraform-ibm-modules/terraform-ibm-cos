##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = var.resource_group_id
}

output "s3_endpoint_private" {
  description = "S3 private endpoint"
  value       = module.cos_module.s3_endpoint_private
}

output "bucket_id" {
  description = "Bucket id"
  value       = module.cos_module.bucket_id
}

output "bucket_name" {
  description = "Bucket Name"
  value       = module.cos_module.bucket_name
}

output "key_protect_key_crn" {
  description = "The CRN of the Key Protect Key used to encrypt the COS Bucket"
  value       = var.hpcs_crn
}

output "cos_instance_id" {
  description = "The ID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_module.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Cloud Object Storage Instance where the buckets are created"
  value       = module.cos_module.cos_instance_guid
}
