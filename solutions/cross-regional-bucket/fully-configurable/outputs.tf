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
  value       = "Your cross-regional bucket is created."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to your cross-regional bucket"
  description = "Primary label"
}

output "next_step_primary_url" {
  value = "https://cloud.ibm.com/objectstorage/${urlencode(var.existing_cos_instance_crn)}?&bucket=${module.cos.buckets[local.bucket_config[0].bucket_name].bucket_name}&bucketRegion=${local.bucket_config[0].cross_region_location}&endpoint=s3.direct.${local.bucket_config[0].cross_region_location}.cloud-object-storage.appdomain.cloud&paneId=bucket_overview"
  description = "Primary URL"
}

output "next_step_secondary_label" {
  value       = "Learn how to add some objects to your bucket"
  description = "Secondary label"
}

output "next_step_secondary_url" {
  value       = "https://cloud.ibm.com/docs/cloud-object-storage"
  description = "Secondary URL"
}

##############################################################################
