#####################################################
# COS Instance
# Copyright 2020 IBM
#####################################################

output "cos_instance_id" {
  description = "The ID of the cos instance"
  value       = module.cos.cos_instance_id
}

output "cos_instance_guid" {
  description = "The GUID of the cos instance"
  value       = module.cos.cos_instance_guid
}

output "cos_key_id" {
  description = "The ID of the key"
  value       = concat(module.cos.*.cos_key_id, [""])[0]
}

output "cos_key_credentials" {
  description = "The credentials of the key"
  value       = concat(module.cos.*.cos_key_credentials, [""])[0]
}
