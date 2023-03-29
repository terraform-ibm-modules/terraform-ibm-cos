##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = var.resource_group_id
}
output "kms_key_crn" {
  description = "The CRN of the Key Protect Key used to encrypt the COS Bucket"
  value       = var.kms_key_crn
}

output "cos_instance_id" {
  description = "The ID of the Cloud Object Storage Instance where the buckets are created"
  value       = local.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Cloud Object Storage Instance where the buckets are created"
  value       = local.cos_instance_guid
}

output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = var.encryption_enabled == true ? ibm_cos_bucket.cos_bucket[*] : ibm_cos_bucket.cos_bucket1[*]
}
