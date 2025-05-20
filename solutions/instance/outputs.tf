##############################################################################
# Outputs
##############################################################################

output "resource_group_id" {
  description = "Resource Group ID"
  value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.resource_group_name
}

output "cos_instance_name" {
  description = "The name of the Cloud Object Storage instance"
  value       = module.cos.cos_instance_name
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos.cos_instance_id
}

output "cos_instance_crn" {
  description = "COS instance crn"
  value       = module.cos.cos_instance_crn
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos.cos_instance_guid
}

output "resource_keys" {
  description = "List of resource keys"
  value       = module.cos.resource_keys
  sensitive   = true
}

output "service_credential_secrets" {
  description = "Service credential secrets"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secrets : null
}

output "service_credential_secret_groups" {
  description = "Service credential secret groups"
  value       = length(local.service_credential_secrets) > 0 ? module.secrets_manager_service_credentials[0].secret_groups : null
}
