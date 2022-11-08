##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = var.resource_group_id
}

output "s3_endpoint_private" {
  description = "S3 private endpoint"
  value       = local.s3_endpoint_private
}

output "s3_endpoint_public" {
  description = "S3 public endpoint"
  value       = local.s3_endpoint_public
}

output "bucket_id" {
  description = "Bucket id"
  value       = local.bucket_id
}

output "bucket_name" {
  description = "Bucket Name"
  value       = local.bucket_name
}

output "key_protect_key_crn" {
  description = "The CRN of the Key Protect Key used to encrypt the COS Bucket"
  value       = local.key_crn
}

output "cos_instance_id" {
  description = "The GUID of the Cloud Object Storage Instance where the buckets are created"
  value       = local.cos_instance_id
}
