#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

output "cos_instance_id" {
  description = "The ID of the cos instance"
  value       = concat(ibm_resource_instance.cos_instance.*.id, [""])[0]
}

output "cos_key_id" {
  description = "The ID of the key"
  value       = concat(ibm_resource_key.key.*.id, [""])[0]
}

output "cos_key_credentials" {
  description = "The credentials of the key"
  value       = concat(ibm_resource_key.key.*.credentials, [""])[0]
}