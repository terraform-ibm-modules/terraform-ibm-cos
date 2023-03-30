##############################################################################
# Outputs
##############################################################################
output "buckets" {
  description = "Map of buckets created in the Cloud Object Storage Instance"
  value       = ibm_cos_bucket.cos_bucket
}

output "bucket_configs" {
  description = "List of bucket config definitions"
  value       = var.bucket_configs
}
