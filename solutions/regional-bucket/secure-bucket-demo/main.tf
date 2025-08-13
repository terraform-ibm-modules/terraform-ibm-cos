##############################################################################
# Secure COS Bucket Demo - Minimal DA for Private Catalog Demo
##############################################################################

module "secure_regional_bucket" {
  source              = "../fully-configurable"
  ibmcloud_api_key    = var.ibmcloud_api_key
  prefix              = "sec-buc-demo"
  provider_visibility = "private"

  # KMS Configuration
  kms_encryption_enabled    = true
  existing_kms_instance_crn = var.existing_kms_instance_crn

  # COS Configuration
  existing_cos_instance_crn           = var.existing_cos_instance_crn
  bucket_name                         = var.bucket_name
  management_endpoint_type_for_bucket = "private"

  # Hard-coded Security Settings
  region                 = "br-sao"
  bucket_storage_class   = "standard"
  force_delete           = false
  add_bucket_name_suffix = true

  # Compliance Features
  enable_object_versioning  = true
  enable_retention          = false
  enable_object_locking     = true
  object_lock_duration_days = 30 # 1 month immutable

  # Lifecycle Management
  archive_days = 30  # Archive after 1 month
  expire_days  = 365 # Delete after 1 year

  # Hard Quota
  bucket_hard_quota = 107374182400 # 100 GB limit
}
