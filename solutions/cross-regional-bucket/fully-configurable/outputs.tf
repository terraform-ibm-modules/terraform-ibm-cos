##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "The list of buckets created by this DA."
  value       = module.cos.buckets
}

output "s3_endpoint_direct" {
  description = "The s3 direct endpoint of the created bucket."
  value       = try(module.cos.buckets[var.bucket_name].s3_endpoint_direct, null)
}

output "s3_endpoint_private" {
  description = "The s3 private endpoint of the created bucket."
  value       = try(module.cos.buckets[var.bucket_name].s3_endpoint_private, null)
}

output "bucket_name" {
  description = "The name of the bucket that was created. Includes the optional suffix if enabled."
  value       = try(module.cos.buckets[var.bucket_name].bucket_name, null)
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance containing the created bucket."
  value       = var.existing_cos_instance_crn
}

output "cos_instance_guid" {
  description = "The guid of the COS instance containing the created bucket."
  value       = local.cos_instance_guid
}

##############################################################################
# CROSS REGIONAL BUCKET Next Steps URLs outputs
##############################################################################

output "next_steps_text" {
  value       = "Your Cross Regional Bucket is created."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Your Cross Regional Bucket" 
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/objectstorage/${var.existing_cos_instance_crn}?paneId=manage"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "Learn more about Cloud Object Storage"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-getting-started-cloud-object-storage"
  description = "Secondary URL"
}

##############################################################################
