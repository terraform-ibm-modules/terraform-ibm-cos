#####################################################
# COS Bucket
# Copyright 2020 IBM
#####################################################

output "cos_instance_id" {
  description = "ID of the cos instance"
  value       = concat(ibm_resource_instance.cos_instance.*.id, [""])[0]
}

output "cos_instance_guid" {
  description = " GUID of the cos instance"
  value       = concat(ibm_resource_instance.cos_instance.*.guid, [""])[0]
}

output "cos_key_id" {
  description = " ID of the key"
  value       = concat(ibm_resource_key.key.*.id, [""])[0]
}

output "cos_key_credentials" {
  description = " credentials of the key"
  value       = concat(ibm_resource_key.key.*.credentials, [""])[0]
}

output "cos_bucket_id" {
  description = " ID of the cos bucket"
  value       = [for bucket in ibm_cos_bucket.bucket : bucket.id]
  //value       = concat(ibm_cos_bucket.bucket.*.id, [""])[0]
}