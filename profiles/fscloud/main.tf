module "cos_module" {
  # Replace "main" with a GIT release version to lock into a specific release
  source                             = "../../"
  resource_group_id                  = var.resource_group_id
  region                             = null
  cross_region_location              = var.cross_region_location
  create_cos_instance                = var.create_cos_instance
  cos_instance_name                  = var.cos_instance_name
  create_hmac_key                    = var.create_hmac_key
  hmac_key_name                      = var.hmac_key_name
  hmac_key_role                      = var.hmac_key_role
  cos_location                       = var.cos_location
  cos_plan                           = "standard"
  cos_tags                           = var.cos_tags
  existing_cos_instance_id           = var.existing_cos_instance_id
  service_endpoints                  = "private"
  bucket_endpoint                    = "private"
  create_cos_bucket                  = var.create_cos_bucket
  bucket_name                        = var.bucket_name
  retention_enabled                  = var.retention_enabled
  retention_default                  = var.retention_default
  retention_minimum                  = var.retention_minimum
  retention_maximum                  = var.retention_maximum
  retention_permanent                = var.retention_permanent
  archive_days                       = null
  object_versioning_enabled          = var.object_versioning_enabled
  expire_days                        = var.expire_days
  existing_key_protect_instance_guid = var.existing_key_protect_instance_guid
  key_protect_key_crn                = var.hpcs_crn
  encryption_enabled                 = "true"
  sysdig_crn                         = var.sysdig_crn
  activity_tracker_crn               = var.activity_tracker_crn
  bucket_cbr_rules                   = var.bucket_cbr_rules
  instance_cbr_rules                 = var.instance_cbr_rules
}
