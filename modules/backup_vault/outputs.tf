output "backup_vault_crn" {
  description = "The CRN of the Object Storage Backup Vault instance."
  value       = ibm_cos_backup_vault.backup_vault.backup_vault_crn
}

output "backup_vault_id" {
  description = "The ID of the Object Storage Backup Vault instance."
  value       = ibm_cos_backup_vault.backup_vault.id
}

output "cos_instance_id" {
  description = "The ID of the Object Storage instance in which the Backup Vault exists."
  value       = var.existing_cos_instance_id
}

output "cos_instance_crn" {
  description = "The CRN of the Object Storage instance in which the Backup Vault exists."
  value       = var.existing_cos_instance_id # NOTE: ID and CRN value are the same for COS instance
}

output "cos_instance_guid" {
  description = "The GUID of the Object Storage instance in which the Backup Vault exists."
  value       = local.cos_instance_guid
}
