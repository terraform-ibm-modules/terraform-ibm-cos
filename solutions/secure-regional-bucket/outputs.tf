##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "List of buckets created"
  value       = module.cos.buckets
}

output "s3_endpoint_direct" {
  description = "The s3 direct endpoint of the created bucket."
  value       = try(local.process_bucket_configs[0].s3_endpoint_direct, "")
}

output "s3_endpoint_private" {
  description = "The s3 private endpoint of the created bucket."
  value       = try(local.process_bucket_configs[0].s3_endpoint_private, "")
}

output "s3_endpoint_public" {
  description = "The s3 private public of the created bucket."
  value       = try(local.process_bucket_configs[0].s3_endpoint_public, "")
}

output "bucket_name" {
  description = "The name of the bucket that was created."
  value       = try(local.process_bucket_configs[0].bucket_name, "")
}

output "cos_instance_crn" {
  description = "The CRN of the COS instance containing the created bucket."
  value       = var.existing_cos_instance_id
}
