#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

output "cos_bucket_id" {
  description = "The ID of the cos instance"
  value       = ibm_cos_bucket.testBucket.id 
}
