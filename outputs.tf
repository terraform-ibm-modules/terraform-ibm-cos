##############################################################################
# Outputs
##############################################################################

output "resource_group_id" {
  description = "Resource group ID"
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

output "s3_endpoint_direct" {
  description = "S3 direct endpoint"
  value       = local.s3_endpoint_direct
}

output "bucket_id" {
  description = "Bucket ID"
  value       = local.bucket_id
}

output "bucket_crn" {
  description = "Bucket CRN"
  value       = local.bucket_crn
}

output "bucket_name" {
  description = "Bucket name"
  value       = local.bucket_name
  # Don't output the bucket name until it exists (see https://github.com/terraform-ibm-modules/terraform-ibm-cos/issues/558)
  depends_on = [local.bucket_crn]
}

output "bucket_storage_class" {
  description = "Bucket storage class"
  value       = local.bucket_storage_class
}

output "bucket_region" {
  description = "Bucket region if a regional bucket is created"
  value       = local.bucket_region
}

output "kms_key_crn" {
  description = "The CRN of the KMS key used to encrypt the bucket"
  value       = var.kms_key_crn
}

output "cos_instance_id" {
  description = "The ID of the Object Storage instance"
  value       = local.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the Object Storage instance"
  value       = local.cos_instance_guid
}

output "cos_instance_name" {
  description = "The name of the Object Storage instance"
  value       = local.cos_instance_name
}

output "cos_instance_crn" {
  description = "The CRN of the Object Storage instance"
  value       = local.cos_instance_crn
}

output "cos_account_id" {
  description = "The account ID in which the Object Storage instance is created."
  value       = var.create_cos_instance ? ibm_resource_instance.cos_instance[0].account_id : null
}

output "bucket_cbr_rules" {
  description = "Object Storage bucket context-based restriction rules"
  value       = module.bucket_cbr_rule
}

output "instance_cbr_rules" {
  description = "Object Storage instance context-based restriction rules"
  value       = module.instance_cbr_rule
}

output "cbr_rule_ids" {
  description = "List of all rule IDs"
  value       = local.all_rule_ids
}

output "resource_keys" {
  description = "List of resource keys"
  value       = ibm_resource_key.resource_keys
  sensitive   = true
}
