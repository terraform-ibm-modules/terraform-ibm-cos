output "bucket_name1" {
  description = "Bucket name"
  value       = module.cos_bucket1.bucket_name
}

output "bucket_name2" {
  description = "Bucket name"
  value       = module.cos_bucket2.bucket_name
}

output "bucket_name3" {
  description = "Bucket name"
  value       = module.cos_bucket3.bucket_name
}

output "backup_vault_crn" {
  description = "The CRN of the Object Storage Backup Vault instance."
  value       = module.backup_vault.backup_vault_crn
}

output "backup_vault_id" {
  description = "The ID of the Object Storage Backup Vault instance."
  value       = module.backup_vault.backup_vault_id
}

output "backup_vault_name" {
  description = "The name of the Object Storage Backup Vault instance."
  value       = module.backup_vault.backup_vault_name
}
