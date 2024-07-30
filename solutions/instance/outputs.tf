##############################################################################
# Outputs
##############################################################################
output "resource_group_id" {
  description = "Resource Group ID"
  value       = module.resource_group.resource_group_id
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos.cos_instance_id
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

output "service_credentials_secret" {
  description = "Service credentials secrets"
  value       = module.secrets_manager_service_credentails.secrets
}

output "service_credentials_secret_group" {
  description = "Service credentials secret groups"
  value       = module.secrets_manager_service_credentails.secret_groups
}
