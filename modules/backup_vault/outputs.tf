output "backup_vault_crn" {
  description = "The CRN of the Object Storage Backup Vault instance."
  value       = ibm_cos_backup_vault.backup_vault.backup_vault_crn
}

output "backup_vault_id" {
  description = "The ID of the Object Storage Backup Vault instance."
  value       = ibm_cos_backup_vault.backup_vault.id
}

output "backup_vault_name" {
  description = "The name of the Object Storage Backup Vault instance."
  value       = local.backup_vault_name
  # only return name after the vault is created
  depends_on = [ibm_cos_backup_vault.backup_vault]
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
