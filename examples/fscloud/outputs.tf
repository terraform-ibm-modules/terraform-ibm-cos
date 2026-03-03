output "buckets" {
  description = "COS buckets"
  value       = module.cos_fscloud.buckets
}

output "cos_instance_id" {
  description = "COS instance id"
  value       = module.cos_fscloud.cos_instance_id
}

output "cos_instance_guid" {
  description = "COS instance guid"
  value       = module.cos_fscloud.cos_instance_guid
}

output "cos_instance_crn" {
  description = "COS instance crn"
  value       = module.cos_fscloud.cos_instance_crn
}

output "bucket_cbr_rules" {
  description = "COS bucket rules"
  value       = module.cos_fscloud.bucket_cbr_rules
}

output "instance_cbr_rules" {
  description = "COS instance rule"
  value       = module.cos_fscloud.instance_cbr_rules
}

output "cbr_rule_ids" {
  description = "List of all CBR rule ids generated"
  value       = module.cos_fscloud.cbr_rule_ids
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
