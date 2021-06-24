#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################
output "bucket_ids" {
  description = "List of bucket ids"
  value       = module.cos_bucket.*.cos_bucket_id
}