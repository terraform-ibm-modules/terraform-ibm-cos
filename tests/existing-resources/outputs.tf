output "kp_standard_cross_region_instance_id" {
  description = "GUID of the Key Protect Standard Cross-region Resiliency instance."
  value       = module.key_protect.kms_guid
}

output "kp_standard_cross_region_instance_crn" {
  description = "CRN of the Key Protect Standard Cross-region Resiliency instance."
  value       = module.key_protect.key_protect_crn
}

output "kp_standard_cross_region_root_key_id" {
  description = "ID of the root key in the Key Protect Standard Cross-region Resiliency instance."
  value       = module.key_protect.keys["${var.prefix}-cos-key-ring.${var.prefix}-cos-root-key"].key_id
}

output "kp_standard_cross_region_root_key_crn" {
  description = "CRN of the root key in the Key Protect Standard Cross-region Resiliency instance."
  value       = module.key_protect.keys["${var.prefix}-cos-key-ring.${var.prefix}-cos-root-key"].crn
}
